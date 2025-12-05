import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _storageKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Carrega o tema salvo no dispositivo (chame no main BEFORE runApp)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_storageKey);

    _themeMode = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' || _ => ThemeMode.system,
    };

    notifyListeners();
  }

  /// Define o tema e salva a escolha
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }

  /// Alterna entre claro e escuro
  Future<void> toggleDarkLight() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

// Instância global simples
final themeController = ThemeController();
