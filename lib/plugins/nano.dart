import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/services/isolates/pluginIsolateFunctions.dart';
import 'package:Tunein/services/isolates/standardIsolateFunctions.dart';
import 'package:Tunein/services/memoryCacheService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:tunein_image_utils_plugin/tunein_image_utils_plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:ext_storage/ext_storage.dart';
class Nano {

  // used for app
  List _metaData = [];
  List _musicFiles = [];

  List get musicFiles => _musicFiles;

  // used for json file
  Map mapMetaData = Map();
  Uuid uuid = new Uuid();

  Future<String> getLocalPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> getLocalFile() async {
    String path = await getLocalPath();
    return File('$path/filesmetadata.json');
  }

  Future<File> writeImage(var hash, List<int> image) async {
    String path = await getLocalPath();
    File imagefile = File('$path/$hash');
    return imagefile.writeAsBytes(image);
  }

  Future getSdCardPath() async {
    String value;
    try {
      value = await TuneinImageUtilsPlugin.getSdCardPath();
    } catch (e) {}
    //memoryCachingService.setCacheItem(CachedItems.SDCARD_NAME, value.split("/").last);
    return value;
  }

  Future readStoredMetaData() async {
    File file = await getLocalFile();
    try {
      String rawMetadata = await file.readAsString();
      return jsonDecode(rawMetadata);
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<File> writeStoredMetaData(Map fileMetaData) async {
    File file = await getLocalFile();
    String jsonData = jsonEncode(fileMetaData);
    return file.writeAsString(jsonData);
  }

  Future<dynamic> readExtDir(Directory dir) async {
    return StandardIsolateFunctions.readExtDir(dir,(dataPath){
      if(dataPath!="0001"){
        _musicFiles.add(dataPath);
      }
    });
  }

  bool validateMusicFile(String path){
    String filename = basename(path);
    if(filename.startsWith(new RegExp(r'([_.\-\!\?])'))){
      return false;
    }
    return true;
  }

  Future<void> getMusicFiles() async {
    //Directory ext = await getExternalStorageDirectory();
    String ext = await ExtStorage.getExternalStorageDirectory();
    await readExtDir(Directory(ext));
    String sdPath = await getSdCardPath();
    if (sdPath == null) {
      print("NO SDCARD ON THIS DEVICE");
    } else {
      String sdCardDir = Directory(sdPath).parent.parent.parent.parent.path;
      await readExtDir(Directory(sdCardDir));
    }
  }

  Future getAllMetaData() async {
    _metaData = await PluginIsolateFunctions.fetchMetadataOfAllTracks(List.from(_musicFiles));
    return;
  }

  void cleanMetadata() {
    for (var i = 0; i < _musicFiles.length; i++) {
      if(_metaData[i]==null) continue;
      if (_metaData[i][0] == null) {
        String s = _musicFiles[i];
        for (var n = s.length; n > 0; n--) {
          if (s.substring(n - 2, n - 1) == "/") {
            _metaData[i][0] = s.substring(n - 1, s.length - 4);
            break;
          }
        }
      }
      if (_metaData[i][1] == null) {
        _metaData[i][1] = "Unknown Artist";
      }
      if (_metaData[i][3] == null) {
        _metaData[i][3] = "Unknown Album";
      }
      if (_metaData[i][4] != null) {
        Iterable<Match> matches =
            RegExp(r"^([^\/]+)").allMatches(_metaData[i][4]);
        for (Match match in matches) {
          _metaData[i][4] = match.group(0);
        }
      } else {
        _metaData[i][4] = "0";
      }
      if (_metaData[i][5] == null) {
        _metaData[i][5] = 0;
      }
    }
  }

  getImage(appPath, imageHash) {
    if (imageHash != null) {
      return appPath + "/" + imageHash;
    }
    return null;
  }

  Future<List<Tune>> fetchSongs() async {
    String appPath = await getLocalPath();
    List<Tune> tunes = List<Tune>();
    await getMusicFiles();
    await getAllMetaData();
    cleanMetadata();
    for (var i = 0; i < _musicFiles.length; i++) {
      if(_metaData[i]==null)continue;
      var albumArt = getImage(appPath, _metaData[i][2]);
      Tune tune = Tune(
          uuid.v1(),
          _metaData[i][0],
          _metaData[i][1],
          _metaData[i][3],
          int.parse((_metaData[i][5]).toString()),
          _musicFiles[i],
          albumArt,
          [],
          int.parse(_metaData[i][4]),
          _metaData[i][6],
          _metaData[i][7],

      );
      tunes.add(tune);
    }

    return tunes;
  }
}

class Tune {
  String id;
  String title;
  String artist;
  String album;
  int duration;
  String uri;
  String albumArt;
  int numberInAlbum;
  String genre;
  String year;
  List<int> colors;

  Tune(this.id, this.title, this.artist, this.album, this.duration, this.uri,
      this.albumArt, this.colors, this.numberInAlbum, this.genre, this.year);
  Tune.fromMap(Map m) {
    id = m["id"];
    artist = m["artist"];
    title = m["title"];
    album = m["album"];
    duration = m["duration"];
    uri = m["uri"];
    albumArt = m["albumArt"];
    numberInAlbum = m["numberInAlbum"];
    List<int> colorList =[];
    (m["colors"] as List).forEach((colorElem){
      colorList.add(int.tryParse(colorElem.toString()));
    });
    colors = colorList;
    genre= m["genre"];
    year=m["year"];
  }

  Map toMap(){
    Map<String, dynamic> _map = {};
    _map["album"] = this.album;
    _map["id"] = this.id;
    _map["artist"] = this.artist;
    _map["title"] = this.title;
    _map["duration"] = this.duration;
    _map["uri"] = this.uri;
    _map["albumArt"] = this.albumArt;
    _map["colors"] = this.colors;
    _map["numberInAlbum"] = this.numberInAlbum;
    _map["genre"] = this.genre;
    _map["year"] = this.year;
    return _map;
  }
}


class Album {
  int id;
  String title;
  String artist;
  String albumArt;
  List<Tune> songs=[];
  Album(this.id, this.title, this.artist, this.albumArt);

  Album.fromMap(Map m) {
    id= m["id"];
    artist = m["artist"];
    title = m["title"];
    albumArt = m["albumArt"];
    List<Tune> albumSongs = [];
    (m["songs"] as List).forEach((element){
      albumSongs.add(Tune.fromMap(element));
    });
    songs=albumSongs;
  }

  Map toMap(Album album){
    Map<String, dynamic> _map = {};
    //transforming the song list to a decodable format
    List<Map> newSongsMap=[];
    album.songs.forEach((song){
      Map songAsAMap = song.toMap();
      newSongsMap.add(songAsAMap);
    });

    _map["artist"] = album.artist;
    _map["id"] = album.id;
    _map["songs"] = newSongsMap;
    _map["title"] = album.title;
    _map["albumArt"] = album.albumArt;
    return _map;
  }

  @override
  String toString() {
    return 'Album{id: $id, title: $title, artist: $artist, albumArt: $albumArt, songs: $songs}';
  }

}


class Artist {
  int id;
  String name;
  String coverArt;
  List<Album> albums=[];
  List<int> colors=List<int>();
  Map<String,String> apiData=Map<String,String>();
  String genre;
  Artist(this.id, this.name, this.coverArt, this.genre);

  Artist.fromMap(Map m) {
    id= m["id"];
    name = m["name"];
    coverArt = m["coverArt"];
    List<Album> albumsList=[];
    (m["albums"] as List).forEach((AlbumMap){
      albumsList.add(Album.fromMap(AlbumMap));
    });
    albums=albumsList;
    apiData=Map<String, String>.from(m["apiData"]);
    List<int> colorList =[];
    (m["colors"] as List).forEach((colorElem){
      colorList.add(int.tryParse(colorElem.toString()));
    });
    colors=colorList;
    genre= m["genre"];
  }


  Map toMap(Artist artist){
    Map<String, dynamic> _map = {};
    //transforming the song list to a decodable format
    List<Map> newAlbumsMap=[];
    artist.albums.forEach((album){
      newAlbumsMap.add(album.toMap(album));
    });

    _map["name"] = artist.name;
    _map["id"] = artist.id;
    _map["albums"] = newAlbumsMap;
    _map["apiData"] = artist.apiData;
    _map["coverArt"] = artist.coverArt;
    _map["colors"] = artist.colors;
    _map["genre"] = artist.genre;
    return _map;
  }

  @override
  String toString() {
    return 'Artist{id: $id, name: $name, coverArt: $coverArt, albums: $albums, apiData :$apiData}';
  }



}

class Playlist {
  Uuid uuid = new Uuid();
  String id;
  String covertArt;
  String name;
  List<Tune> songs;
  PlayerState playbackState;
  DateTime creationDate;
  Playlist(this.name, this.songs, this.playbackState, this.covertArt){
    this.id= uuid.v1();
    this.creationDate=DateTime.now();
  }

  Playlist.fromMap(Map m) {

    List<Tune> songlist=[];
    (m["songs"] as List).forEach((songMap){
      songlist.add(Tune.fromMap(songMap));
    });

    id= m["id"];
    name = m["name"];
    songs = songlist;
    playbackState= StringToPlayerState(m["playbackState"]);
    covertArt= m["covertArt"];
    creationDate= DateTime.parse(m["creationDate"]);
  }

  static Map toMap(Playlist playlist){
    Map<String, dynamic> _map = {};
    //transforming the song list to a decodable format
    List<Map> newSongsMap=[];
    playlist.songs.forEach((song){
      newSongsMap.add(song.toMap());
    });

    _map["name"] = playlist.name;
    _map["id"] = playlist.id;
    _map["songs"] = newSongsMap;
    _map["playbackState"] = playlist.playbackState.index.toString();
    _map["covertArt"] = playlist.covertArt;
    _map["creationDate"] = playlist.creationDate.toIso8601String();
    return _map;
  }

  PlayerState StringToPlayerState(String string){
    switch(string){
      case "1":{
        return PlayerState.playing;
      }
      case "2":{
        return PlayerState.paused;
      }
      case "3":{
        return PlayerState.stopped;
      }
      default:{
        return PlayerState.stopped;
      }
    }
  }
}