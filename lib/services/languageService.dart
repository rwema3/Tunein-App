import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';
///import 'package:flutter_i18n/flutter_i18n.dart';
import 'locator.dart';

final themeService = locator<ThemeService>();



///NOT USED YET, WILL PROBABLY BE DEPRECATED
class languageService{

  String _flutterI18nDelegate="" ;


  languageService(){
   /* _flutterI18nDelegate = FlutterI18nDelegate(
      translationLoader: FileTranslationLoader(
          useCountryCode: false,
          fallbackFile: 'en',
          basePath: 'locale',
          forcedLocale: Locale('en')),
    );*/
  }

  //FlutterI18nDelegate get flutterI18nDelegate => _flutterI18nDelegate;

  settingService(){
    _initStreams();
  }

  _initStreams(){

  }


  void dispose() {

  }
}

