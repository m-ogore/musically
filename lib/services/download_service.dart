import 'package:flutter/foundation.dart';
import 'download_service_io.dart'
    if (dart.library.html) 'download_service_stub.dart'
    as platform;

/// Represents the download state of a single track.
enum TrackDownloadStatus { notDownloaded, downloading, downloaded, failed }

/// Tracks download progress for a single track.
class TrackDownloadState {
  final TrackDownloadStatus status;
  final double progress; // 0.0 to 1.0

  const TrackDownloadState({
    this.status = TrackDownloadStatus.notDownloaded,
    this.progress = 0.0,
  });

  TrackDownloadState copyWith({TrackDownloadStatus? status, double? progress}) {
    return TrackDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  bool get isDownloaded => status == TrackDownloadStatus.downloaded;
  bool get isDownloading => status == TrackDownloadStatus.downloading;
  bool get hasFailed => status == TrackDownloadStatus.failed;
}

/// Represents download state for all tracks of a hymn.
class HymnDownloadState {
  final Map<String, TrackDownloadState> tracks;

  const HymnDownloadState({required this.tracks});

  factory HymnDownloadState.empty(List<String> trackNames) {
    return HymnDownloadState(
      tracks: {for (final t in trackNames) t: const TrackDownloadState()},
    );
  }

  bool get allDownloaded =>
      tracks.values.every((t) => t.status == TrackDownloadStatus.downloaded);

  bool get anyDownloading =>
      tracks.values.any((t) => t.status == TrackDownloadStatus.downloading);

  int get downloadedCount => tracks.values.where((t) => t.isDownloaded).length;

  double get overallProgress {
    if (tracks.isEmpty) return 0.0;
    return tracks.values.map((t) => t.progress).reduce((a, b) => a + b) /
        tracks.length;
  }

  HymnDownloadState withTrackState(String trackName, TrackDownloadState state) {
    return HymnDownloadState(tracks: {...tracks, trackName: state});
  }
}

/// Service responsible for downloading, caching, and managing hymn audio files.
///
/// On web: streaming only — downloads are not supported.
/// On native (iOS/Android/desktop): files are downloaded to local storage and
/// played from disk. Audio is ONLY available after explicit user download.
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  // In-memory cache of download states, keyed by hymnId.
  final Map<String, HymnDownloadState> _states = {};

  // Listeners notified on any state change.
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  /// Returns the current download state for a hymn.
  HymnDownloadState getHymnState(String hymnId, List<String> trackNames) {
    return _states[hymnId] ?? HymnDownloadState.empty(trackNames);
  }

  /// Checks local disk for already-downloaded tracks and updates state.
  /// Call this when the user navigates to a hymn detail screen.
  Future<HymnDownloadState> refreshHymnState(
    String hymnId,
    List<String> trackNames,
  ) async {
    if (kIsWeb) {
      // On web, nothing is ever "downloaded" locally.
      final state = HymnDownloadState.empty(trackNames);
      _states[hymnId] = state;
      return state;
    }

    var state = HymnDownloadState.empty(trackNames);
    for (final trackName in trackNames) {
      final downloaded = await platform.isTrackDownloaded(hymnId, trackName);
      state = state.withTrackState(
        trackName,
        TrackDownloadState(
          status: downloaded
              ? TrackDownloadStatus.downloaded
              : TrackDownloadStatus.notDownloaded,
          progress: downloaded ? 1.0 : 0.0,
        ),
      );
    }
    _states[hymnId] = state;
    _notify();
    return state;
  }

  /// Downloads all tracks for a hymn that are not yet downloaded.
  ///
  /// [audioPaths] is a map of trackName → remote URL.
  /// Progress and status updates are emitted via listeners.
  Future<void> downloadHymn(
    String hymnId,
    Map<String, String> audioPaths,
  ) async {
    if (kIsWeb) {
      debugPrint('DownloadService: downloads not supported on web.');
      return;
    }

    final trackNames = audioPaths.keys.toList();

    // Initialise state for all tracks that aren't already downloaded.
    var current = _states[hymnId] ?? HymnDownloadState.empty(trackNames);
    for (final trackName in trackNames) {
      final trackState =
          current.tracks[trackName] ?? const TrackDownloadState();
      if (!trackState.isDownloaded && !trackState.isDownloading) {
        current = current.withTrackState(
          trackName,
          const TrackDownloadState(
            status: TrackDownloadStatus.downloading,
            progress: 0.0,
          ),
        );
      }
    }
    _states[hymnId] = current;
    _notify();

    // Download each track concurrently.
    await Future.wait(
      audioPaths.entries.map((entry) async {
        final trackName = entry.key;
        final url = entry.value;

        // Skip already-downloaded tracks.
        final trackState = _states[hymnId]?.tracks[trackName];
        if (trackState?.isDownloaded == true) return;

        final success = await platform.downloadTrack(
          url,
          hymnId,
          trackName,
          onReceiveProgress: (received, total) {
            if (total <= 0) return;
            final progress = received / total;
            _updateTrackState(
              hymnId,
              trackName,
              TrackDownloadState(
                status: TrackDownloadStatus.downloading,
                progress: progress.clamp(0.0, 1.0),
              ),
            );
          },
        );

        _updateTrackState(
          hymnId,
          trackName,
          TrackDownloadState(
            status: success
                ? TrackDownloadStatus.downloaded
                : TrackDownloadStatus.failed,
            progress: success ? 1.0 : 0.0,
          ),
        );
      }),
    );
  }

  /// Downloads a single track for a hymn.
  ///
  /// Kept compatible with existing call sites that pass
  /// (url, hymnId, trackName) and optionally read progress.
  Future<bool> downloadTrack(
    String url,
    String hymnId,
    String trackName, {
    Function(int count, int total)? onReceiveProgress,
  }) async {
    if (kIsWeb) return false;

    _updateTrackState(
      hymnId,
      trackName,
      const TrackDownloadState(
        status: TrackDownloadStatus.downloading,
        progress: 0.0,
      ),
    );

    final success = await platform.downloadTrack(
      url,
      hymnId,
      trackName,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;
        if (onReceiveProgress != null) {
          onReceiveProgress(received, total);
        }
        _updateTrackState(
          hymnId,
          trackName,
          TrackDownloadState(
            status: TrackDownloadStatus.downloading,
            progress: (received / total).clamp(0.0, 1.0),
          ),
        );
      },
    );

    _updateTrackState(
      hymnId,
      trackName,
      TrackDownloadState(
        status: success
            ? TrackDownloadStatus.downloaded
            : TrackDownloadStatus.failed,
        progress: success ? 1.0 : 0.0,
      ),
    );

    return success;
  }

  /// Deletes all downloaded tracks for a hymn.
  Future<void> deleteHymn(String hymnId, List<String> trackNames) async {
    if (kIsWeb) return;

    await Future.wait(
      trackNames.map((trackName) => platform.deleteTrack(hymnId, trackName)),
    );

    _states[hymnId] = HymnDownloadState.empty(trackNames);
    _notify();
  }

  /// Deletes a single track and updates cached state.
  Future<bool> deleteTrack(String hymnId, String trackName) async {
    if (kIsWeb) return true;

    final success = await platform.deleteTrack(hymnId, trackName);
    if (!success) return false;

    _updateTrackState(
      hymnId,
      trackName,
      const TrackDownloadState(
        status: TrackDownloadStatus.notDownloaded,
        progress: 0.0,
      ),
    );
    return true;
  }

  /// Returns the local file path for a track (native only).
  Future<String> getLocalTrackPath(String hymnId, String trackName) async {
    if (kIsWeb) return '';
    return platform.getLocalTrackPath(hymnId, trackName);
  }

  /// Whether a specific track is available locally.
  Future<bool> isTrackDownloaded(String hymnId, String trackName) async {
    if (kIsWeb) return false;
    return platform.isTrackDownloaded(hymnId, trackName);
  }

  void _updateTrackState(
    String hymnId,
    String trackName,
    TrackDownloadState state,
  ) {
    final current =
        _states[hymnId] ??
        HymnDownloadState.empty(
          const <String>[],
        ).withTrackState(trackName, const TrackDownloadState());
    _states[hymnId] = current.withTrackState(trackName, state);
    _notify();
  }
}
