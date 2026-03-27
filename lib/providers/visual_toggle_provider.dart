import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/score_bounds.dart';

/// Manages the visual playback cursor independent of the audio player engine.
///
/// Runs an internal visual timer that animates through coordinates parsed from
/// `assets/data/coords/*.json`. The audio player merely provides play/pause/seek
/// sync commands.
class VisualToggleProvider extends ChangeNotifier {
  ScoreBoundsData? _boundsData;
  BeatBounds? _currentBeat;
  MeasureBounds? _currentMeasure;
  SystemBounds? _currentSystem;
  String? _loadedHymnId;
  final Set<String> _missingCoordsLoggedFor = <String>{};

  bool _isPlaying = false;
  int _visualTimeMs = 0;
  Timer? _ticker;

  // Getters
  ScoreBoundsData? get boundsData => _boundsData;
  BeatBounds? get currentBeat => _currentBeat;
  MeasureBounds? get currentMeasure => _currentMeasure;
  SystemBounds? get currentSystem => _currentSystem;
  bool get isPlaying => _isPlaying;

  Future<void> loadHymnCoords(String hymnId) async {
    if (_loadedHymnId == hymnId) {
      return;
    }

    _loadedHymnId = hymnId;
    _boundsData = null;
    _currentBeat = null;
    _currentMeasure = null;
    _currentSystem = null;
    _visualTimeMs = 0;
    _isPlaying = false;
    _ticker?.cancel();
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/coords/$hymnId.json',
      );
      final jsonData = json.decode(jsonString);
      _boundsData = ScoreBoundsData.fromJson(jsonData);
      notifyListeners();
    } catch (e) {
      // If the hymn doesn't have an explict mapping json yet, that's fine.
      if (_missingCoordsLoggedFor.add(hymnId)) {
        debugPrint('No explicit coordinate data found for hymn $hymnId.');
      }
    }
  }

  /// Called remotely by the Audio Player to issue Play/Pause/Seek commands.
  void syncWithAudio(Duration audioPosition, bool isAudioPlaying) {
    // If the difference is big (a seek), or we weren't tracking time well,
    // snap the internal clock back to the audio position.
    final diff = (_visualTimeMs - audioPosition.inMilliseconds).abs();
    if (diff > 500 || !isAudioPlaying) {
      _visualTimeMs = audioPosition.inMilliseconds;
      _updateActiveBounds();
    }

    if (isAudioPlaying && !_isPlaying) {
      _startTicker();
    } else if (!isAudioPlaying && _isPlaying) {
      _stopTicker();
    }
  }

  void _startTicker() {
    if (_isPlaying) return;
    _isPlaying = true;
    _ticker?.cancel();

    // Run a visual game loop at ~60fps (16ms)
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _visualTimeMs += 16;
      _updateActiveBounds();
    });
    notifyListeners();
  }

  void _stopTicker() {
    _isPlaying = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void _updateActiveBounds() {
    if (_boundsData == null) return;

    BeatBounds? activeBeat;
    MeasureBounds? activeMeasure;
    SystemBounds? activeSystem;

    // Search for the active beat
    for (final system in _boundsData!.systems) {
      for (final measure in system.measures) {
        for (final beat in measure.beats) {
          if (_visualTimeMs >= beat.timeMs &&
              _visualTimeMs < (beat.timeMs + beat.durationMs)) {
            activeBeat = beat;
            activeMeasure = measure;
            activeSystem = system;
            break;
          }
        }
        if (activeBeat != null) break;
      }
      if (activeBeat != null) break;
    }

    if (_currentBeat != activeBeat) {
      _currentBeat = activeBeat;
      _currentMeasure = activeMeasure;
      _currentSystem = activeSystem;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
