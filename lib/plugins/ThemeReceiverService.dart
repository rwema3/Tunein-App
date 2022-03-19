


import 'dart:async';

import 'package:Tunein/plugins/nano.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tunein_image_utils_plugin/tunein_image_utils_plugin.dart';

class ThemeReceiverService {


  BehaviorSubject<List<int>> _color$;
  BehaviorSubject<List<int>> get color$ => _color$;

  Map<String, List<int>> _savedColors;
  Map<String, List<int>> _artistSavedColors;
  List<int> defaultColors =  [0xff111111, 0xffffffff, 0xffffffff];


  ThemeReceiverService(){
    _initStreams();
    _savedColors = Map<String, List<int>>();
    _artistSavedColors= Map<String, List<int>>();
  }

  Future<void> updateTheme(String songId, String songArt) async {
    if (_savedColors.containsKey(songId)) {
      _color$.add(_savedColors[songId]);
      return;
    }


    String path = songArt;
    if (path == null) {
      _color$.add([0xff111111, 0xffffffff]);
      return;
    }

    final colors =
    await TuneinImageUtilsPlugin.getColor(path);
    List<int> _colors = List<int>();
    for (var color in colors) {
      _colors.add(color);
    }
    _color$.add(_colors);
    _savedColors[songId] = _colors;

    return;
  }

  Future<List<int>> getThemeColors(String songId, String songArt) async{
    List<int> color=[];
    if (_savedColors.containsKey(songId)) {
      color.addAll(_savedColors[songId]);


      return color;
    }

    String path = songArt;

    if (path == null) {
      color.addAll(defaultColors);
      return color;
    }
    print(path);
    final colors =
    await TuneinImageUtilsPlugin.getColor(path);

    List<int> _colors = List<int>();
    for (var color in colors) {
      _colors.add(color);
    }
    if(_colors.length<3){
      do{
        _colors.add(_colors[1]);
      }while(_colors.length<3);
    }
    color.addAll(_colors);
    _savedColors[songId] = _colors;


    return color;
  }

  Future<List<int>> getArtistColors(int artistID, String artistCoverArtPath) async{
    List<int> color=[];
    if (_artistSavedColors.containsKey(artistID)) {

      color.addAll(_artistSavedColors[artistID]);


      return color;
    }

    String path = artistCoverArtPath;

    if (path == null) {
      color.addAll(defaultColors);
      return color;
    }

    final colors =
    await TuneinImageUtilsPlugin.getColor(path);

    List<int> _colors = List<int>();
    for (var color in colors) {
      _colors.add(color);
    }
    if(_colors.length<3){
      do{
        _colors.add(_colors[1]);
      }while(_colors.length<3);
    }
    color.addAll(_colors);
    _artistSavedColors[artistID.toString()] = _colors;

    return color;
  }


  Future execute(String caller, dynamic arguments){
    switch(caller){
      case "getArtistColors":{
        return this.getArtistColors(arguments["artistId"],arguments["coverArt"]);
      }
      case "getThemeColors":{
        return this.getThemeColors(arguments["songId"],arguments["coverArt"]);
      }
      case "updateTheme":{
        return this.updateTheme(arguments["songId"],arguments["coverArt"]);
      }
    }
  }

  void _initStreams() {
    _color$ = BehaviorSubject<List<int>>.seeded([0xff111111, 0xffffffff]);
  }
}