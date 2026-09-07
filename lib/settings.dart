import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _fromKey = 'last_from';
  static const _toKey = 'last_to';

  ThemeMode themeMode = ThemeMode.light;
  String lastFrom = 'USD';
  String lastTo = 'RUB';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = prefs.getString(_themeKey) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    lastFrom = prefs.getString(_fromKey) ?? 'USD';
    lastTo = prefs.getString(_toKey) ?? 'RUB';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> saveCurrencyPair(String from, String to) async {
    lastFrom = from;
    lastTo = to;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fromKey, from);
    await prefs.setString(_toKey, to);
    notifyListeners();
  }
}

class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope не найден в дереве виджетов');
    return scope!.notifier!;
  }
}
