import 'package:flutter/foundation.dart';
import '../models/hymn.dart';
import '../services/hymn_repository.dart';

enum ScrollMode { manual, audioSync }
enum HighlightMode { individual, chord }
enum NotationViewMode { fullSheet, lineByLine }
enum HymnViewMode { lyrics, imageScore, newScore }

/// Provider for managing hymn data and view state
class HymnProvider with ChangeNotifier {
  final HymnRepository _repository = HymnRepository();
  
  List<Hymn> _hymns = [];
  Hymn? _selectedHymn;
  bool _isLoading = false;
  String? _error;
  HymnViewMode _viewMode = HymnViewMode.lyrics;
  NotationViewMode _notationMode = NotationViewMode.fullSheet;
  ScrollMode _scrollMode = ScrollMode.audioSync;
  bool _highlightingEnabled = true;
  HighlightMode _highlightMode = HighlightMode.individual;

  // Getters
  List<Hymn> get hymns => _hymns;
  Hymn? get selectedHymn => _selectedHymn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  HymnViewMode get viewMode => _viewMode;
  bool get showLyrics => _viewMode == HymnViewMode.lyrics;
  bool get showNotation => _viewMode == HymnViewMode.imageScore;
  ScrollMode get scrollMode => _scrollMode;
  bool get highlightingEnabled => _highlightingEnabled;
  HighlightMode get highlightMode => _highlightMode;
  NotationViewMode get notationMode => _notationMode;

  /// Loads all hymns from the repository
  Future<void> loadHymns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hymns = await _repository.getAllHymns();
      _error = null;
    } catch (e) {
      _error = 'Failed to load hymns: $e';
      _hymns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a hymn by ID
  Future<void> selectHymn(String hymnId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedHymn = await _repository.getHymnById(hymnId);
      if (_selectedHymn == null) {
        _error = 'Hymn not found';
      }
    } catch (e) {
      _error = 'Failed to load hymn: $e';
      _selectedHymn = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the selected hymn directly
  void setSelectedHymn(Hymn? hymn) {
    _selectedHymn = hymn;
    notifyListeners();
  }

  /// Sets the view mode directly
  void setViewMode(HymnViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  /// Toggles between lyrics and notation view (Legacy support, cycles 2 main modes)
  void toggleView() {
    if (_viewMode == HymnViewMode.lyrics) {
      _viewMode = HymnViewMode.imageScore;
    } else {
      _viewMode = HymnViewMode.lyrics;
    }
    notifyListeners();
  }

  /// Sets the scroll mode (Manual or Auto Sync)
  void setScrollMode(ScrollMode mode) {
    _scrollMode = mode;
    notifyListeners();
  }
  
  /// Sets the notation view mode (Full Sheet vs Line-by-Line)
  void setNotationMode(NotationViewMode mode) {
    _notationMode = mode;
    notifyListeners();
  }

  /// Toggles note highlighting on/off
  void toggleHighlighting() {
    _highlightingEnabled = !_highlightingEnabled;
    notifyListeners();
  }

  /// Sets the highlight mode (Individual or Chord)
  void setHighlightMode(HighlightMode mode) {
    _highlightMode = mode;
    notifyListeners();
  }


  /// Clears any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Finds the next hymn ID for navigation
  String? getNextHymnId() {
    if (_selectedHymn == null || _hymns.isEmpty) return null;
    final currentIndex = _hymns.indexWhere((h) => h.id == _selectedHymn!.id);
    if (currentIndex == -1) return null;
    
    final nextIndex = (currentIndex + 1) % _hymns.length;
    return _hymns[nextIndex].id;
  }

  /// Finds the previous hymn ID for navigation
  String? getPreviousHymnId() {
    if (_selectedHymn == null || _hymns.isEmpty) return null;
    final currentIndex = _hymns.indexWhere((h) => h.id == _selectedHymn!.id);
    if (currentIndex == -1) return null;
    
    final prevIndex = (currentIndex - 1 + _hymns.length) % _hymns.length;
    return _hymns[prevIndex].id;
  }
}
