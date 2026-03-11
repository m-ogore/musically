import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing a user's favorite hymns
class FavoritesProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorite_hymns';
  Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoaded => _isLoaded;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedFavorites = prefs.getStringList(_favoritesKey);
    
    if (storedFavorites != null) {
      _favoriteIds = storedFavorites.toSet();
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  bool isFavorite(String hymnId) {
    return _favoriteIds.contains(hymnId);
  }

  Future<void> toggleFavorite(String hymnId) async {
    if (_favoriteIds.contains(hymnId)) {
      _favoriteIds.remove(hymnId);
    } else {
      _favoriteIds.add(hymnId);
    }
    
    notifyListeners();
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
  }
}
