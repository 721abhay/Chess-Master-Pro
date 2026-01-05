import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeEngine extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _notificationsEnabled = true;
  String _boardTheme = 'Classic';
  
  // Theme Colors
  Color get primaryColor {
    switch (_boardTheme) {
      case 'Nexus': return const Color(0xFF6366F1);
      case 'Coral': return const Color(0xFFF43F5E);
      case 'Classic': default: return const Color(0xFFD4AF37); // Gold
    }
  }

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get boardTheme => _boardTheme;

  ThemeEngine() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _boardTheme = prefs.getString('board_theme') ?? 'Classic';
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }
  
  Future<void> setHaptics(bool value) async {
    _hapticsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics_enabled', value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> setBoardTheme(String value) async {
    _boardTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('board_theme', value);
    notifyListeners();
  }
}
