import 'package:flutter/foundation.dart';
import '../models/hymn.dart';
import '../services/hymn_repository.dart';

enum NotationViewMode { lineByLine, fullSheet }
enum ScrollMode { manual, audioSync }

/// Provider for managing hymn data and view state
class HymnProvider with ChangeNotifier {
  final HymnRepository _repository = HymnRepository();
  
  List<Hymn> _hymns = [];
  Hymn? _selectedHymn;
  bool _isLoading = false;
  String? _error;
  bool _showLyrics = true; // true for lyrics, false for notation
  NotationViewMode _notationMode = NotationViewMode.fullSheet;
  ScrollMode _scrollMode = ScrollMode.audioSync;

  // Getters
  List<Hymn> get hymns => _hymns;
  Hymn? get selectedHymn => _selectedHymn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showLyrics => _showLyrics;
  bool get showNotation => !_showLyrics;
  NotationViewMode get notationMode => _notationMode;
  ScrollMode get scrollMode => _scrollMode;

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

  /// Sets the notation view mode (Line by Line or Full Sheet)
  void setNotationMode(NotationViewMode mode) {
    _notationMode = mode;
    notifyListeners();
  }

  /// Sets the scroll mode (Manual or Auto Sync)
  void setScrollMode(ScrollMode mode) {
    _scrollMode = mode;
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
