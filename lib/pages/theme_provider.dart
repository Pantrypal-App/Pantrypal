import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isNightMode = false;

  bool get isNightMode => _isNightMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleNightMode() async {
    _isNightMode = !_isNightMode;
    notifyListeners();
    _saveTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isNightMode = prefs.getBool('isNightMode') ?? false;
    notifyListeners();
  }

  void _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNightMode', _isNightMode);
  }
}
