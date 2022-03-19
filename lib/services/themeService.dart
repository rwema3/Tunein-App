import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/utils/messaginUtils.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

final _androidAppRetain = MethodChannel("android_app_retain");

class ThemeService {
  BehaviorSubject<List<int>> _color$;
  BehaviorSubject<List<int>> get color$ => _color$;

  Map<String, List<int>> _savedColors;
  Map<String, List<int>> _artistSavedColors;
  List<int> defaultColors =  [0xff111111, 0xffffffff, 0xffffffff];
  ThemeService() {
    _initStreams();
    _savedColors = Map<String, List<int>>();
    _artistSavedColors= Map<String, List<int>>();
  }


  void updateTheme(Tune song) async {
    final color = await MessagingUtils.sendNewIsolateCommand(command: "updateTheme",message: {
      "songId": song.id,
      "coverArt": song.albumArt
    });

    return;
  }

  Future<List<int>> getThemeColors(Tune song) async{

    final color = await MessagingUtils.sendNewIsolateCommand(command: "getThemeColors",message: {
      "songId": song.id,
      "coverArt": song.albumArt
    });

    return color;
  }

  Future<List<int>> getArtistColors(Artist artist) async{
    final color = await MessagingUtils.sendNewIsolateCommand(command: "getArtistColors",message: {
      "artistId": artist.id,
      "coverArt": artist.coverArt
    });

    return color;
  }

  void _initStreams() {
    _color$ = BehaviorSubject<List<int>>.seeded([0xff111111, 0xffffffff]);
  }
}
