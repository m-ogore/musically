import 'package:flutter/foundation.dart';
import '../models/hymn.dart';

/// Manages the state for system-level (karaoke-style) score highlighting.
///
/// It listens to audio position updates and determines which line of the
/// musical score (system) should be highlighted based on the 
/// [Hymn.systemTimestamps] provided in hymns.json.
class SystemHighlightProvider extends ChangeNotifier {
  Hymn? _currentHymn;
  int _currentSystemIndex = -1;
  bool _isActive = false;

  /// The currently active line of music (0-indexed). Returns -1 if no system is active.
  int get currentSystemIndex => _currentSystemIndex;
  
  /// Whether the highlight should be displayed (usually matches audio isPlaying).
  bool get isActive => _isActive;
  
  /// The total number of systems for the current hymn.
  int get totalSystems => _currentHymn?.systemTimestamps?.length ?? 0;

  /// Loads a new hymn and prepares it for highlighting.
  void loadHymn(Hymn hymn) {
    if (_currentHymn?.id == hymn.id) return;
    _currentHymn = hymn;
    _currentSystemIndex = -1;
    _isActive = false;
    notifyListeners();
  }

  /// Updates the highlight state based on the current audio position.
  /// This should be called directly by the PlayerProvider listener.
  void updatePosition(Duration position, bool isPlaying) {
    if (_currentHymn == null) return;
    
    final timestamps = _currentHymn!.systemTimestamps;
    if (timestamps == null || timestamps.isEmpty) {
      if (_isActive) {
        _isActive = false;
        notifyListeners();
      }
      return;
    }

    bool wasActive = _isActive;
    int prevIndex = _currentSystemIndex;
    
    _isActive = isPlaying;

    if (!isPlaying && position == Duration.zero) {
      _currentSystemIndex = -1;
    } else {
      // Find the current system based on the audio position
      int newIndex = -1;
      for (int i = 0; i < timestamps.length; i++) {
        // Adding a 100ms early-trigger buffer so it feels more responsive
        if (position.inMilliseconds + 100 >= timestamps[i].inMilliseconds) {
          newIndex = i;
        } else {
          break; // We've passed the current time
        }
      }
      _currentSystemIndex = newIndex;
    }

    if (prevIndex != _currentSystemIndex || wasActive != _isActive) {
      notifyListeners();
    }
  }

  /// Manually resets the highlight.
  void reset() {
    _currentSystemIndex = -1;
    _isActive = false;
    notifyListeners();
  }
}
