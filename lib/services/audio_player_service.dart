import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/hymn.dart';
import '../models/mixer_state.dart';
import '../utils/constants.dart';
import 'download_service.dart';

/// Describes why a hymn could not be loaded.
enum LoadFailureReason {
  /// The hymn has no audio paths defined at all.
  noAudioDefined,

  /// On native: the user has not downloaded the tracks yet.
  notDownloaded,

  /// The audio files could not be loaded from disk/network.
  loadError,
}

class HymnLoadResult {
  final bool success;
  final LoadFailureReason? failureReason;

  /// Which tracks are missing (not downloaded) on native.
  final List<String> missingTracks;

  const HymnLoadResult._({
    required this.success,
    this.failureReason,
    this.missingTracks = const [],
  });

  factory HymnLoadResult.ok() => const HymnLoadResult._(success: true);

  factory HymnLoadResult.notDownloaded(List<String> missing) =>
      HymnLoadResult._(
        success: false,
        failureReason: LoadFailureReason.notDownloaded,
        missingTracks: missing,
      );

  factory HymnLoadResult.noAudio() => const HymnLoadResult._(
    success: false,
    failureReason: LoadFailureReason.noAudioDefined,
  );

  factory HymnLoadResult.error() => const HymnLoadResult._(
    success: false,
    failureReason: LoadFailureReason.loadError,
  );
}

/// Service that manages synchronized playback of multiple audio tracks
/// with individual volume control for each voice part.
///
/// Audio is streamed on web. On native it is played from local files only —
/// the user must download the hymn first via [DownloadService].
class AudioPlayerService {
  final Map<String, AudioPlayer> _players = {};
  AudioPlayer? _primaryPlayer;
  MixerState _mixerState = MixerState.initial();
  Hymn? _currentHymn;
  StreamSubscription<Duration>? _syncSubscription;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;

  Duration get currentPosition => _primaryPlayer?.position ?? Duration.zero;
  Duration get totalDuration => _primaryPlayer?.duration ?? Duration.zero;
  bool get isPlaying => _primaryPlayer?.playing ?? false;
  MixerState get mixerState => _mixerState;
  Hymn? get currentHymn => _currentHymn;
  bool get hasLoadedPlayers => _players.isNotEmpty;

  /// Initialises the audio session.
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
  }

  /// Attempts to load a hymn's audio tracks.
  ///
  /// Returns a [HymnLoadResult] describing success or the reason for failure.
  /// On native: if any tracks are not yet downloaded the method returns
  /// [LoadFailureReason.notDownloaded] without loading anything — the caller
  /// should direct the user to download first.
  Future<HymnLoadResult> loadHymn(Hymn hymn) async {
    // Always clear previous hymn players first so we never keep stale audio
    // loaded when the next hymn is unavailable locally.
    await _disposeAllPlayers();
    _currentHymn = hymn;

    if (hymn.audioPaths.isEmpty) {
      return HymnLoadResult.noAudio();
    }

    // ── Native: verify all tracks are downloaded before loading ────────────
    if (!kIsWeb) {
      final missingTracks = <String>[];
      for (final trackName in AppConstants.allTracks) {
        final url = hymn.audioPaths[trackName];
        if (url == null || url.isEmpty) continue;

        final downloaded = await DownloadService().isTrackDownloaded(
          hymn.id,
          trackName,
        );
        if (!downloaded) {
          missingTracks.add(trackName);
        }
      }

      if (missingTracks.isNotEmpty) {
        debugPrint(
          'AudioPlayerService: hymn ${hymn.id} has ${missingTracks.length} '
          'track(s) not downloaded: $missingTracks',
        );
        return HymnLoadResult.notDownloaded(missingTracks);
      }
    }

    // ── Load each track ─────────────────────────────────────────────────────
    bool anyLoaded = false;
    for (final trackName in AppConstants.allTracks) {
      final audioPath = hymn.audioPaths[trackName];
      if (audioPath == null || audioPath.isEmpty) continue;

      final player = AudioPlayer();
      try {
        if (kIsWeb) {
          // Web: stream directly from Supabase.
          await player.setUrl(audioPath);
        } else {
          // Native: play from local file (already verified above).
          final localPath = await DownloadService().getLocalTrackPath(
            hymn.id,
            trackName,
          );
          await player.setFilePath(localPath);
          debugPrint('AudioPlayerService: loaded local track "$trackName"');
        }

        final effectiveVolume = _mixerState.getEffectiveVolume(trackName);
        await player.setVolume(effectiveVolume);

        _players[trackName] = player;
        anyLoaded = true;
      } catch (e) {
        debugPrint('AudioPlayerService: error loading "$trackName": $e');
        await player.dispose();
      }
    }

    if (!anyLoaded) {
      return HymnLoadResult.error();
    }

    // ── Wire up primary player streams ──────────────────────────────────────
    _primaryPlayer =
        _players[AppConstants.sopranoTrack] ?? _players.values.first;

    _primaryPlayer!.positionStream.listen(_positionController.add);
    _primaryPlayer!.durationStream.listen((d) {
      if (d != null) _durationController.add(d);
    });
    _primaryPlayer!.playingStream.listen(_playingController.add);

    return HymnLoadResult.ok();
  }

  /// Starts synchronised playback of all loaded tracks.
  Future<void> play() async {
    if (_primaryPlayer == null || _players.isEmpty) return;

    final position = _primaryPlayer!.position;
    await Future.wait(_players.values.map((p) => p.seek(position)));
    await Future.wait(_players.values.map((p) => p.play()));
    _startSyncMonitoring();
  }

  /// Pauses all tracks.
  Future<void> pause() async {
    if (_players.isEmpty) return;
    await _syncSubscription?.cancel();
    _syncSubscription = null;
    await Future.wait(_players.values.map((p) => p.pause()));
  }

  /// Stops playback and resets to the beginning.
  Future<void> stop() async {
    await pause();
    await seek(Duration.zero);
  }

  /// Seeks all tracks to [position].
  Future<void> seek(Duration position) async {
    if (_players.isEmpty) return;
    await Future.wait(_players.values.map((p) => p.seek(position)));
  }

  Future<void> seekBackward() async {
    final next = currentPosition - AppConstants.seekBackwardDuration;
    await seek(next < Duration.zero ? Duration.zero : next);
  }

  Future<void> seekForward() async {
    final next = currentPosition + AppConstants.seekForwardDuration;
    final max = totalDuration;
    await seek(next > max ? max : next);
  }

  Future<void> setTrackVolume(String trackName, double volume) async {
    _mixerState = _mixerState.setVolume(trackName, volume);
    await _applyVolume(trackName);
  }

  Future<void> toggleMute(String trackName) async {
    _mixerState = _mixerState.toggleMute(trackName);
    await _applyVolume(trackName);
  }

  Future<void> setMute(String trackName, bool muted) async {
    _mixerState = _mixerState.setMute(trackName, muted);
    await _applyVolume(trackName);
  }

  Future<void> _applyVolume(String trackName) async {
    final player = _players[trackName];
    if (player != null) {
      await player.setVolume(_mixerState.getEffectiveVolume(trackName));
    }
  }

  void _startSyncMonitoring() {
    if (_primaryPlayer == null) return;
    _syncSubscription?.cancel();
    _syncSubscription = _primaryPlayer!.positionStream
        .where((_) => _primaryPlayer!.playing)
        .listen(_checkAndResync);
  }

  Future<void> _checkAndResync(Duration primaryPosition) async {
    for (final entry in _players.entries) {
      final player = entry.value;
      if (player == _primaryPlayer) continue;

      final drift = (player.position - primaryPosition).abs();

      if (drift > AppConstants.hardSyncTolerance) {
        debugPrint(
          'AudioPlayerService: hard resync "${entry.key}" '
          '(${drift.inMilliseconds}ms drift)',
        );
        await _resyncAll(primaryPosition);
        return;
      }

      if (drift > AppConstants.syncTolerance) {
        debugPrint(
          'AudioPlayerService: soft resync "${entry.key}" '
          '(${drift.inMilliseconds}ms drift)',
        );
        await player.seek(primaryPosition);
      }
    }
  }

  Future<void> _resyncAll(Duration position) async {
    await Future.wait(_players.values.map((p) => p.pause()));
    await Future.wait(_players.values.map((p) => p.seek(position)));
    await Future.wait(_players.values.map((p) => p.play()));
  }

  Future<void> _disposeAllPlayers() async {
    await _syncSubscription?.cancel();
    _syncSubscription = null;
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _primaryPlayer = null;
  }

  Future<void> dispose() async {
    await _disposeAllPlayers();
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
  }
}
