import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:Tunein/plugins/ThemeReceiverService.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:Tunein/services/isolates/standardIsolateFunctions.dart';
import 'package:Tunein/utils/MathUtils.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_tags/dart_tags.dart';
import 'package:dart_tags/src/utils/image_extractor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_meta_data/flutter_file_meta_data.dart';
import 'package:media_notification/media_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnp/upnp.dart';
import 'package:Tunein/plugins/upnp.dart' as UPnPPlugin;
import 'package:path/path.dart';


class PluginIsolateFunctions {

  // Temporary attributes

  static Map mapMetaData = Map();
  static Nano _nano;
  static ThemeReceiverService themeReceiverService = new ThemeReceiverService();
  static Future<List> fetchMetadataOfAllTracks(List tracks, {Function(List) callback}) async{
    List _metaData=[];
    for (var track in tracks) {
      var data = await getFileMetaData(track);
      if (data!=null && data[2] != null) {
        if (data[2] is List<int>) {
          var digest = sha1.convert(data[2]).toString();
          writeImage(digest, data[2]);
          data[2] = digest;
          _metaData.add(data);
        } else {
          _metaData.add(data);
        }
      } else {
        _metaData.add(data);
      }
    }
    if(callback!=null)callback(_metaData);
    return _metaData;
  }

  static Future getFileMetaData(track) async {

    var value;
    try {
      if (mapMetaData[track] == null) {
        var metaValue = await FlutterFileMetaData.getFileMetaData(track);
        return metaValue;
      } else {
        value = mapMetaData[track];
        return value;
      }
    } catch (e, stack) {
      return [null, null, null, null, null, null, null, null];
    }

  }


  static Future<String> getLocalPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> getLocalFile() async {
    String path = await getLocalPath();
    return File('$path/filesmetadata.json');
  }

  static Future<File> writeImage(var hash, List<int> image) async {
    String path = await getLocalPath();
    if(hash==null){
      hash = sha1.convert(image).toString();
    }
    File imagefile = File('$path/$hash');
    return imagefile.writeAsBytes(image);
  }



  //Custom Notification controls

  static show({String title, String author, bool play, String image, List<int> BitmapImage, Color titleColor, Color subtitleColor, Color iconColor, Color bigLayoutIconColor, Color bgColor, String bgImage, List<int> bgBitmapImage, Color bgImageBackgroundColor, Function(dynamic) callback}) async{
    MediaNotification.show(
        title: title??"title",
        author: author??"author",
        play: play??true,
        image: image,
        BitmapImage:
        image == null ? BitmapImage : null,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        iconColor: iconColor,
        bgImage: bgImage,
        bgBitmapImage: bgBitmapImage,
        bgImageBackgroundColor: bgImageBackgroundColor,
        bigLayoutIconColor: bigLayoutIconColor,
        bgColor:bgColor).then((s){
      callback!=null?callback(s):null;
    });
  }

  static Future hide(){
    try{
      return MediaNotification.hide();
    }on PlatformException{
      //
    }
  }
  static setNotificationTimeStamp(String timeStamp) async{
    MediaNotification.setTimestamp(timeStamp);
  }

  static subscribeToPlayButton(Function(dynamic) callback) async{
    MediaNotification.setListener('play', (){
      callback(true);
    });
  }

  static subscribeToNextButton(Function(dynamic) callback) async{
    MediaNotification.setListener('next', (){
      callback(true);
    });
  }

  static subscribeToPrevButton(Function(dynamic) callback) async{
    MediaNotification.setListener('prev', (){
      callback(true);
    });
  }

  static subscribeToSelectButton(Function(dynamic) callback) async{
    MediaNotification.setListener('select', (){
      callback(true);
    });
  }

  static subscribeToPauseButton(Function(dynamic) callback) async{
    MediaNotification.setListener('pause', (){
      callback(true);
    });
  }

  static setNotificationTo(bool value, Function(dynamic) callback) async {
    MediaNotification.setTo(value).then(
            (data){
          callback(data);
        }
    );
  }

  static setNotificationTitle(String value, Function(dynamic) callback) async{
    MediaNotification.setTitle(value).then(
            (data){
          callback(data);
        }
    );
  }

  static setNotificationSubTitle(String value, Function(dynamic) callback) async{
    MediaNotification.setSubtitle(value).then(
            (data){
          callback(data);
        }
    );
  }

  static setNotificationStatusIcon(String value, Function(dynamic) callback) async{
    MediaNotification.setStatusIcon(value).then(
            (data){
          callback(data);
        }
    );
  }

  static toggleNotificationPlayPause(Function(dynamic) callback) async{
    MediaNotification.togglePlayPause().then(
            (data){
          callback(data);
        }
    );
  }


  //SDCARD PERMISSION ACQUIRING


  static getSDCardAndPermissions(Function(dynamic) callback)async{
    MethodChannel platform = MethodChannel('android_app_retain');
    platform.setMethodCallHandler((call) {
      switch(call.method){
        case "resolveWithSDCardUri":{
          if(callback!=null){
            callback(call.arguments);
          }
        }
      }
      return null;
    });
    platform.invokeMethod("getSDCardPermission");

  }


  static Future<Map> loadFiles() async{
    Map<String,List<Map>> finalReturnedMap= new Map();
    final data = await retrieveFiles();
    if (data.length == 0) {
      print("gona fetch songs");
      if(_nano==null) _nano = Nano();
      List<Tune> newSongs = await fetchSongs();
      print("gona fetch albums");
      List<Album> newAlbums = await fetchAlbums(newSongs);
      print("gona fetch artist");
      List<Artist> newArtists = await fetchArtists(newAlbums);
      print("gona fetch playlists");
      List<Playlist> newPlaylistList =  await retrievePlaylists();
      finalReturnedMap["songs"]=newSongs.map((e) => e.toMap()).toList();
      finalReturnedMap["albums"]=newAlbums.map((e) => e.toMap(e)).toList();
      finalReturnedMap["artists"]=newArtists.map((e) => e.toMap(e)).toList();
      finalReturnedMap["playlists"]=newPlaylistList.map((e) => Playlist.toMap(e)).toList();
      print("songs number : ${newSongs.length}");
      print("Albums number : ${newAlbums.length}");
      print("Artists number : ${newArtists.length}");
      print("playlissts number : ${newPlaylistList.length}");
      print("gona saveFiles");
      saveFiles(songsToSave: newSongs);
      print("gona save artist");
      saveArtists(artistsToSave: newArtists);
      print("gona retrieve favorites");
      List<Tune> newFavs = await retrieveFavorites(allSongs: newSongs);
      finalReturnedMap["favs"]=newFavs.map((e) => e.toMap()).toList();
    } else {
      print("gona fetch  old albums");
      List<Album> newAlbums = await fetchAlbums(data);
      List<Artist> artistsData =await retrieveArtists();
      if(artistsData.length==0){
        print("gona fetch newer artist");
        artistsData = await fetchArtists(newAlbums);
        saveArtists(artistsToSave: artistsData);
      }
      List<Playlist> newPlaylistList =  await retrievePlaylists();
      List<Tune> newFavs = await retrieveFavorites(allSongs: data);

      finalReturnedMap["songs"]=data.map((e) => e.toMap()).toList();
      finalReturnedMap["albums"]=newAlbums.map((e) => e.toMap(e)).toList();
      finalReturnedMap["artists"]=artistsData.map((e) => e.toMap(e)).toList();
      finalReturnedMap["playlists"]=newPlaylistList.map((e) => Playlist.toMap(e)).toList();
      finalReturnedMap["notNewStartup"]=List<Map>();
      finalReturnedMap["favs"]=newFavs.map((e) => e.toMap()).toList();
    }

    return finalReturnedMap;

  }


  static Future<List<Artist>> retrieveArtists() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _savedStrings = _prefs.getStringList("artists") ?? [];
    List<Artist> _artists = [];

    for (String data in _savedStrings) {
      final Artist artist = _decodeArtistFromJson(data);
      _artists.add(artist);
    }
    return _artists;
  }

  static Future<List<Tune>> retrieveFiles() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _savedStrings = _prefs.getStringList("tunes") ?? [];
    List<Tune> _songs = [];

    for (String data in _savedStrings) {
      final Tune song = _decodeSongFromJson(data);
      _songs.add(song);
    }
    return _songs;
  }

  static Future<List<Playlist>> retrievePlaylists() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _savedStrings = _prefs.getStringList("playlists") ?? [];
    List<Playlist> _playLists = [];

    for (String data in _savedStrings) {
      final Playlist song = _decodePlaylistFromJson(data);
      _playLists.add(song);
    }
    return _playLists;
  }

  static  String _encodeSongToJson(Tune song) {
    final _songMap = song.toMap();
    final data = json.encode(_songMap);
    return data;
  }

  static Tune _decodeSongFromJson(String ecodedSong) {
    final _songMap = json.decode(ecodedSong);
    final Tune _song = Tune.fromMap(_songMap);
    return _song;
  }

  static Artist _decodeArtistFromJson(String ecodedSong) {
    final _artistMap = json.decode(ecodedSong);
    final Artist _artist = Artist.fromMap(_artistMap);
    return _artist;
  }

  static Playlist _decodePlaylistFromJson(String ecodedPlaylist) {
    final _playlistMap = json.decode(ecodedPlaylist);
    final Playlist _playlist = Playlist.fromMap(_playlistMap);
    return _playlist;
  }

  static String _encodePlaylistToJson(Playlist playlist) {
    final _songMap = Playlist.toMap(playlist);
    final data = json.encode(_songMap);
    return data;
  }

  static Tune _decodeSongPlusFromJson(String ecodedSong) {
    final _songMap = json.decode(ecodedSong);
    final Tune _song = Tune.fromMap(_songMap);
    return _song;
  }

  static Future<List<Tune>> fetchSongs() async {
    var data = await _nano.fetchSongs();
    for(int i = 0; i < data.length; i++) {
      data[i].colors = await themeReceiverService.getThemeColors(data[i].id, data[i].albumArt);
    }
    return data;
  }

  static Future<List<Album>> fetchAlbums(List<Tune> songs) async {
    return StandardIsolateFunctions.fetchAlbumFromsongs(songs);
  }

  static Future<List<Artist>> fetchArtists(List<Album> albums) async {
    return StandardIsolateFunctions.fetchArtistsFromAlbums(albums);
  }

  static Future<void> saveFiles({List<Tune> songsToSave}) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return StandardIsolateFunctions.saveSongsToPref(songsToSave, (data) {
      _prefs.setStringList("tunes", data);
    });
  }

  static Future<void> saveArtists({List<Artist> artistsToSave}) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return StandardIsolateFunctions.saveArtiststoPref(artistsToSave, (data) {
      _prefs.setStringList("artists", data);
      return;
    });
  }

  static Future<List<Tune>> retrieveFavorites({List<Tune> allSongs}) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> _savedStrings = _prefs.getStringList("favoritetunes") ?? [];
    List<Tune> _favorites = [];
    for (String data in _savedStrings) {
      final Tune song = _decodeSongPlusFromJson(data);
      for (var fetchedSong in allSongs) {
        if (song.id == fetchedSong.id) {
          _favorites.add(song);
        }
      }
    }
   return _favorites;
  }


}