import 'package:flutter/material.dart';
import '../models/filter_payload.dart';

class FiltersProvider extends ChangeNotifier {
  FiltersPayload? _filters;

  FiltersPayload? get filters => _filters;

  void setFilters(FiltersPayload filters) {
    _filters = filters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = null;
    notifyListeners();
  }

  bool get hasFilters => _filters != null;
}
