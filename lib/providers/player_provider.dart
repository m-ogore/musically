import 'package:flutter/foundation.dart';
import '../models/hymn.dart';
import '../models/mixer_state.dart';
import '../services/audio_player_service.dart';

/// Provider for managing audio playback state
class PlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  MixerState _mixerState = MixerState.initial();
  Hymn? _currentHymn;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  MixerState get mixerState => _mixerState;
  Hymn? get currentHymn => _currentHymn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Progress as a percentage (0.0 to 1.0)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  /// Initializes the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _audioService.initialize();
      _isInitialized = true;
      
      // Listen to audio service streams
      _audioService.positionStream.listen((position) {
        _currentPosition = position;
        notifyListeners();
      });
      
      _audioService.durationStream.listen((duration) {
        _totalDuration = duration;
        notifyListeners();
      });
      
      _audioService.playingStream.listen((playing) {
        _isPlaying = playing;
        notifyListeners();
      });
      
    } catch (e) {
      _error = 'Failed to initialize audio: $e';
      _isInitialized = false;
    }
    
    notifyListeners();
  }

  /// Loads a hymn for playback
  Future<void> loadHymn(Hymn hymn) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _audioService.loadHymn(hymn);
      _currentHymn = hymn;
      _mixerState = _audioService.mixerState;
      _error = null;
    } catch (e) {
      _error = 'Failed to load hymn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Plays the current hymn
  Future<void> play() async {
    try {
      await _audioService.play();
    } catch (e) {
      _error = 'Playback error: $e';
      notifyListeners();
    }
  }

  /// Pauses playback
  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      _error = 'Pause error: $e';
      notifyListeners();
    }
  }

  /// Toggles play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stops playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
    } catch (e) {
      _error = 'Stop error: $e';
      notifyListeners();
    }
  }

  /// Seeks to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      _error = 'Seek error: $e';
      notifyListeners();
    }
  }

  /// Seeks backward
  Future<void> seekBackward() async {
    try {
      await _audioService.seekBackward();
    } catch (e) {
      _error = 'Seek error: $e';
      notifyListeners();
    }
  }

  /// Seeks forward
  Future<void> seekForward() async {
    try {
      await _audioService.seekForward();
    } catch (e) {
      _error = 'Seek error: $e';
      notifyListeners();
    }
  }

  /// Sets the volume for a specific track
  Future<void> setTrackVolume(String trackName, double volume) async {
    try {
      await _audioService.setTrackVolume(trackName, volume);
      _mixerState = _audioService.mixerState;
      notifyListeners();
    } catch (e) {
      _error = 'Volume error: $e';
      notifyListeners();
    }
  }

  /// Toggles mute for a specific track
  Future<void> toggleMute(String trackName) async {
    try {
      await _audioService.toggleMute(trackName);
      _mixerState = _audioService.mixerState;
      notifyListeners();
    } catch (e) {
      _error = 'Mute error: $e';
      notifyListeners();
    }
  }

  /// Clears any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
