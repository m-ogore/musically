import 'package:flutter/foundation.dart';
import '../models/hymn.dart';
import '../services/hymn_repository.dart';

enum ScrollMode { manual, audioSync }
enum HighlightMode { individual, chord }

/// Provider for managing hymn data and view state
class HymnProvider with ChangeNotifier {
  final HymnRepository _repository = HymnRepository();
  
  List<Hymn> _hymns = [];
  Hymn? _selectedHymn;
  bool _isLoading = false;
  String? _error;
  bool _showLyrics = true; // true for lyrics, false for notation
  ScrollMode _scrollMode = ScrollMode.audioSync;
  bool _highlightingEnabled = true;
  HighlightMode _highlightMode = HighlightMode.individual;

  // Getters
  List<Hymn> get hymns => _hymns;
  Hymn? get selectedHymn => _selectedHymn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showLyrics => _showLyrics;
  bool get showNotation => !_showLyrics;
  ScrollMode get scrollMode => _scrollMode;
  bool get highlightingEnabled => _highlightingEnabled;
  HighlightMode get highlightMode => _highlightMode;

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

  /// Toggles between lyrics and notation view
  void toggleView() {
    _showLyrics = !_showLyrics;
    notifyListeners();
  }

  /// Sets the scroll mode (Manual or Auto Sync)
  void setScrollMode(ScrollMode mode) {
    _scrollMode = mode;
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

  /// Sets the view mode explicitly
  void setViewMode({required bool showLyrics}) {
    _showLyrics = showLyrics;
    notifyListeners();
  }

  /// Clears any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
