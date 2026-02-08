import 'package:flutter/material.dart';

enum UserInteractionState { none, liked, disliked }

class UserDishInteractionsStore extends ChangeNotifier {
  final Map<String, UserInteractionState> _dishInteractions = {};

  UserInteractionState getState(String dishId) {
    if (dishId.isEmpty) return UserInteractionState.none;
    return _dishInteractions[dishId] ?? UserInteractionState.none;
  }

  void setStateForDish(String dishId, UserInteractionState state) {
    if (dishId.isEmpty) return;
    _dishInteractions[dishId] = state;
    notifyListeners();
  }
}
