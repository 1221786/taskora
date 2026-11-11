import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changePage(int index) {
    if (index < 0 || index > 3) return;

    if (_currentIndex == index) return;

    _currentIndex = index;
    notifyListeners();
  }
}
