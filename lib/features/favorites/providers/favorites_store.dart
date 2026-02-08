import 'package:flutter/material.dart';
import '../../recommendations/domain/recommended_dish.dart';
import '../../../services/favorites_service.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore() {
    Future.microtask(loadFavorites);
  }

  final Map<String, RecommendedDish> _favorites = {};
  Set<String> _favoriteDishIds = {};
  final Set<String> _sending = {};

  List<RecommendedDish> get favorites => _favorites.values.toList();
  Set<String> get favoriteDishIds => _favoriteDishIds;

  bool isFavorite(String dishId) {
    if (dishId.isEmpty) return false;
    return _favoriteDishIds.contains(dishId);
  }

  bool isSending(String dishId) {
    if (dishId.isEmpty) return false;
    return _sending.contains(dishId);
  }

  void setSending(String dishId, bool sending) {
    if (dishId.isEmpty) return;
    if (sending) {
      _sending.add(dishId);
    } else {
      _sending.remove(dishId);
    }
    notifyListeners();
  }

  void toggleFavorite(RecommendedDish dish) {
    final dishId = dish.dishId;
    if (dishId.isEmpty) return;
    if (_favorites.containsKey(dishId)) {
      _favorites.remove(dishId);
      _favoriteDishIds.remove(dishId);
    } else {
      _favorites[dishId] = dish;
      _favoriteDishIds.add(dishId);
    }
    notifyListeners();
  }

  void setFavoriteById(String dishId, bool favorite,
      {RecommendedDish? dish}) {
    if (dishId.isEmpty) return;
    if (favorite) {
      if (dish != null) {
        _favorites[dishId] = dish;
      }
      _favoriteDishIds.add(dishId);
    } else {
      _favorites.remove(dishId);
      _favoriteDishIds.remove(dishId);
    }
    notifyListeners();
  }

  void setFavorites(List<String> dishIds) {
    _favoriteDishIds = dishIds.toSet();
    _favorites.removeWhere((key, value) => !_favoriteDishIds.contains(key));
    notifyListeners();
  }

  void setFavoritesFromDishes(List<RecommendedDish> dishes) {
    _favorites
      ..clear()
      ..addEntries(
        dishes
            .where((dish) => dish.dishId.isNotEmpty)
            .map((dish) => MapEntry(dish.dishId, dish)),
      );
    _favoriteDishIds = _favorites.keys.toSet();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    try {
      final dishes = await FavoritesService.getFavorites();
      setFavoritesFromDishes(dishes);
    } catch (e) {
      debugPrint('❌ Erreur chargement favoris: $e');
    }
  }
}
