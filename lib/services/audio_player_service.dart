import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/hymn.dart';
import '../models/mixer_state.dart';
import '../utils/constants.dart';

/// Service that manages synchronized playback of multiple audio tracks
/// with individual volume control for each track
class AudioPlayerService {
  // Map of track name to AudioPlayer instance
  final Map<String, AudioPlayer> _players = {};
  
  // Primary player used for position reference
  AudioPlayer? _primaryPlayer;
  
  // Current mixer state
  MixerState _mixerState = MixerState.initial();
  
  // Current hymn being played
  Hymn? _currentHymn;
  
  // Sync monitoring subscription
  StreamSubscription<Duration>? _syncSubscription;
  
  // State streams
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  
  // Getters for state streams
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  
  // Current state getters
  Duration get currentPosition => _primaryPlayer?.position ?? Duration.zero;
  Duration get totalDuration => _primaryPlayer?.duration ?? Duration.zero;
  bool get isPlaying => _primaryPlayer?.playing ?? false;
  MixerState get mixerState => _mixerState;
  Hymn? get currentHymn => _currentHymn;

  /// Initializes the audio session for proper audio handling
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  /// Loads a hymn and prepares all audio tracks for playback
  Future<void> loadHymn(Hymn hymn) async {
    // Dispose existing players
    await _disposeAllPlayers();
    
    _currentHymn = hymn;
    
    // Create a player for each track
    for (final trackName in AppConstants.allTracks) {
      final audioPath = hymn.audioPaths[trackName];
      if (audioPath != null && audioPath.isNotEmpty) {
        final player = AudioPlayer();
        _players[trackName] = player;
        
        // Load the audio file
        try {
          await player.setAsset(audioPath);
          
          // Set initial volume based on mixer state
          final effectiveVolume = _mixerState.getEffectiveVolume(trackName);
          await player.setVolume(effectiveVolume);
          
        } catch (e) {
          debugPrint('Error loading audio for $trackName: $e');
        }
      }
    }
    
    // Set the primary player (soprano by default, or first available)
    _primaryPlayer = _players[AppConstants.sopranoTrack] ?? _players.values.firstOrNull;
    
    // Set up position and duration streams
    if (_primaryPlayer != null) {
      _primaryPlayer!.positionStream.listen((position) {
        _positionController.add(position);
      });
      
      _primaryPlayer!.durationStream.listen((duration) {
        if (duration != null) {
          _durationController.add(duration);
        }
      });
      
      _primaryPlayer!.playingStream.listen((playing) {
        _playingController.add(playing);
      });
    }
  }

  /// Starts synchronized playback of all tracks
  Future<void> play() async {
    if (_primaryPlayer == null || _players.isEmpty) return;
    
    // Get the current position from primary player
    final position = _primaryPlayer!.position;
    
    // 1. Prepare/Seek all players in parallel
    await Future.wait(
      _players.values.map((player) => player.seek(position)),
    );
    
    // 2. Optimized fire: trigger all play commands as fast as possible
    // We don't await each one individually to minimize inter-track latency
    final playFutures = _players.values.map((player) => player.play()).toList();
    await Future.wait(playFutures);
    
    // Start monitoring synchronization
    _startSyncMonitoring();
  }

  /// Pauses all tracks
  Future<void> pause() async {
    if (_players.isEmpty) return;
    
    // Stop sync monitoring
    await _syncSubscription?.cancel();
    _syncSubscription = null;
    
    // Pause all players
    await Future.wait(
      _players.values.map((player) => player.pause()),
    );
  }

  /// Stops playback and resets to beginning
  Future<void> stop() async {
    await pause();
    await seek(Duration.zero);
  }

  /// Seeks all tracks to the specified position
  Future<void> seek(Duration position) async {
    if (_players.isEmpty) return;
    
    // Seek all players to the same position in parallel
    await Future.wait(
      _players.values.map((player) => player.seek(position)),
    );
  }

  /// Seeks backward by the configured duration
  Future<void> seekBackward() async {
    final newPosition = currentPosition - AppConstants.seekBackwardDuration;
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Seeks forward by the configured duration
  Future<void> seekForward() async {
    final newPosition = currentPosition + AppConstants.seekForwardDuration;
    final maxPosition = totalDuration;
    await seek(newPosition > maxPosition ? maxPosition : newPosition);
  }

  /// Sets the volume for a specific track
  Future<void> setTrackVolume(String trackName, double volume) async {
    _mixerState = _mixerState.setVolume(trackName, volume);
    final player = _players[trackName];
    if (player != null) {
      final effectiveVolume = _mixerState.getEffectiveVolume(trackName);
      await player.setVolume(effectiveVolume);
    }
  }

  /// Toggles mute for a specific track
  Future<void> toggleMute(String trackName) async {
    _mixerState = _mixerState.toggleMute(trackName);
    final player = _players[trackName];
    if (player != null) {
      final effectiveVolume = _mixerState.getEffectiveVolume(trackName);
      await player.setVolume(effectiveVolume);
    }
  }

  /// Sets mute state for a specific track
  Future<void> setMute(String trackName, bool muted) async {
    _mixerState = _mixerState.setMute(trackName, muted);
    final player = _players[trackName];
    if (player != null) {
      final effectiveVolume = _mixerState.getEffectiveVolume(trackName);
      await player.setVolume(effectiveVolume);
    }
  }

  /// Starts monitoring synchronization between tracks
  void _startSyncMonitoring() {
    if (_primaryPlayer == null) return;
    
    _syncSubscription?.cancel();
    _syncSubscription = _primaryPlayer!.positionStream
        .where((_) => _primaryPlayer!.playing)
        .listen((primaryPosition) {
      _checkAndResync(primaryPosition);
    });
  }

  /// Checks if tracks are in sync and resyncs if necessary
  Future<void> _checkAndResync(Duration primaryPosition) async {
    // Check each player against the primary player
    for (final entry in _players.entries) {
      final trackName = entry.key;
      final player = entry.value;
      
      if (player == _primaryPlayer) continue;
      
      final drift = (player.position - primaryPosition).abs();
      
      // If drift is catastrophic, do a full hard resync (disruptive)
      if (drift > AppConstants.hardSyncTolerance) {
        debugPrint('CRITICAL: Track $trackName drifted by ${drift.inMilliseconds}ms. Hard Resync.');
        await _resyncAll(primaryPosition);
        return; 
      }
      
      // If drift exceeds normal tolerance, do a "soft catch-up" (non-disruptive)
      if (drift > AppConstants.syncTolerance) {
        debugPrint('SOFT SYNC: Track $trackName catching up (${drift.inMilliseconds}ms)');
        // Just seek this specific track, don't pause others
        await player.seek(primaryPosition);
      }
    }
  }

  /// Performs a hard resync (pauses all for safety)
  Future<void> _resyncAll(Duration position) async {
    // Only used if drift is very high
    await Future.wait(_players.values.map((p) => p.pause()));
    await Future.wait(_players.values.map((p) => p.seek(position)));
    await Future.wait(_players.values.map((p) => p.play()));
  }

  /// Disposes all audio players
  Future<void> _disposeAllPlayers() async {
    await _syncSubscription?.cancel();
    _syncSubscription = null;
    
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _primaryPlayer = null;
  }

  /// Disposes the service and cleans up resources
  Future<void> dispose() async {
    await _disposeAllPlayers();
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
  }
}
