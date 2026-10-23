import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, Locale>((ref) => AppLocaleNotifier());

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier() : super(_readSavedLocale());

  static Locale _readSavedLocale() {
    final language = Hive.box('settings').get('app_language', defaultValue: 'km');
    return Locale(language == 'en' ? 'en' : 'km');
  }

  Future<void> setLanguage(String languageCode) async {
    final language = languageCode == 'en' ? 'en' : 'km';
    await Hive.box('settings').put('app_language', language);
    state = Locale(language);
  }
}

String appText(BuildContext context, String khmer, String english) =>
    Localizations.localeOf(context).languageCode == 'en' ? english : khmer;
