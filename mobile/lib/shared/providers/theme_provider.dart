import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    final saved = box.get(_key, defaultValue: 'system') as String;
    state = _fromString(saved);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final box = Hive.box(_boxName);
    await box.put(_key, _toString(mode));
  }

  void toggleMode() {
    setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeMode _fromString(String s) => switch (s) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  String _toString(ThemeMode m) => switch (m) {
    ThemeMode.dark => 'dark',
    ThemeMode.light => 'light',
    _ => 'system',
  };
}
