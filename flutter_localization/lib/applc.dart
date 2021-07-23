import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  Locale locale;
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationDelegate();
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  AppLocalizations(this.locale);

  Map<String, String> languageMap = Map();
  Future load() async {
    final fileString =
        await rootBundle.loadString('lang/${locale.languageCode}.json');
    final Map<String, dynamic> mapData = json.decode(fileString);
    languageMap = mapData.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslation(String key) {
    return languageMap[key];
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationDelegate();
  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // TODO: implement load
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    // TODO: implement shouldReload
    return false;
  }
}
