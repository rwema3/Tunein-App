


import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:Tunein/utils/messaginUtils.dart';
import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dart_tags/src/readers/id3v1.dart';
import 'package:dart_tags/src/readers/id3v2.dart';
import 'package:dart_tags/src/writers/id3v1.dart';
import 'package:dart_tags/src/writers/id3v2.dart';
import 'package:permission_handler/permission_handler.dart';

import 'memoryCacheService.dart';
class fileService{



  Future<File> getFileFromURI(String uri, {bool mustExist}) async{
    if(uri==null) return null;
    File newFile = File(uri);
    if(mustExist){
      if(newFile.existsSync()){
        return newFile;
      }else{
        return null;
      }
    }

    return newFile;
  }

  deleteFile(String uri) async{
    File fileToBeDeleted = await getFileFromURI(uri,mustExist: true);
    if(fileToBeDeleted!=null){
      fileToBeDeleted.deleteSync();
    }
    return;
  }

  createFile(String fileName) async{
    final path = await _localPath;
    return File('$path/$fileName}');
  }



  saveFile(File fileToBeSaved, String data, {bool writeBytes, List<int> bytesToWrite, nativeSave =false}) async{
    if(fileToBeSaved!=null){
      if(fileToBeSaved.existsSync()){
        if(writeBytes){
          if(nativeSave){
            print("FILE IS IN SDCARD ? : ${isFileOnSDCard(fileToBeSaved)}");
            if(isFileOnSDCard(fileToBeSaved)){
              await getSDCardAndPermissions();
            }
            return saveFileToPathNatively(fileToBeSaved.uri.toString(),bytesToWrite);
          }else{
            return fileToBeSaved.writeAsBytesSync(bytesToWrite);
          }
        }else{
          return fileToBeSaved.writeAsStringSync(data);
        }
      }
    }
  }


  dynamic readFile(uri, {bool readAsBytes}) async{
    File fileToBeRead = await getFileFromURI(uri,mustExist: true);
    if(fileToBeRead!=null){
      if(readAsBytes){
        return fileToBeRead.readAsBytesSync();
      }else{
        return fileToBeRead.readAsStringSync();
      }
    }else{
      return null;
    }
  }


  Future<dynamic> saveBytesToFile(Uint8List FileBytes) async {
    ReceivePort tempPort = ReceivePort();
    var MusicServiceIsolate = locator<musicServiceIsolate>();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<List>(
        sender: tempPort.sendPort,
        command: "writeImage",
        message: FileBytes
    ));

    BehaviorSubject<dynamic> stream = new BehaviorSubject<dynamic>();
    tempPort.forEach((fileURI){
      if(fileURI!="OK"){
        stream.add(fileURI);
        tempPort.close();
      }else{
        //wait
      }
    });
    return stream.first;
  }




  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> getSDCardAndPermissions()async{
    MethodChannel platform = MethodChannel('android_app_retain');
    BehaviorSubject<String> streamB = new BehaviorSubject<String>();
    platform.setMethodCallHandler((call) {
      switch(call.method){
        case "resolveWithSDCardUri":{
          streamB.add(call.arguments);
          streamB.close();
          return call.arguments;
        }
        default:{
          return null;
        }
      }
    });
    platform.invokeMethod("getSDCardPermission");
    return streamB.first;
  }

  FutureOr<bool> isFileOnSDCard(File file){
    final memoryCachingService = locator<MemoryCacheService>();
    String sdCardName = memoryCachingService.getCacheItem(CachedItems.SDCARD_NAME);
    return sdCardName==null || file.uri.toString().contains(sdCardName);
  }

  Future<dynamic> saveFileToPathNatively(String path, List<int> bytes){

    MethodChannel platform = MethodChannel('android_app_retain');
    return platform.invokeMethod("saveFileFromBytes",{
      "filepath":path,
      "bytes":Uint8List.fromList(bytes)
    });

    //return MessagingUtils.sendNewIsolateCommand(command: "saveFileFromBytes");
  }

  Future<bool> writeTags(Tune Song,{List<String> comments}) async{
    final AttachedPicture pic = AttachedPicture(
        'image/jpeg',0x03,'${Song.album}.jpg', Song.albumArt!=null?await ConversionUtils.FileUriTo8Bit(Song.albumArt):[]
    );
    List<Comment> comms;
    if(comments!=null){
      int comIndex=0;
      comms = comments.map((e) {
        Comment com = Comment('eng',comIndex.toString(),e);
        comIndex++;
        return com;
      }).toList();
    }
    final tag = Tag()
      ..tags = {
        if(Song.title!=null)'title': Song.title,
        if(Song.artist!=null)'artist': Song.artist,
        if(Song.album!=null)'album': Song.album,
        if(Song.year!=null)'year': Song.year.toString(),
        if(comments!=null)'comment': comms.asMap().map((key, value) => MapEntry<String,Comment>(value.key,value)),
        if(Song.numberInAlbum!=null)'track': Song.numberInAlbum.toString(),
        if(Song.genre!=null)'genre': Song.genre,
        if(Song.albumArt!=null)'picture': {
          pic.key:pic
        },
      }
      ..type = 'ID3'
      ..version = '2.4';

    final writer = ID3V2Writer();

    final blocks = writer.write(await ConversionUtils.FileUriTo8Bit(Song.uri), tag);

    await saveFile(File(Song.uri),null, writeBytes: true, bytesToWrite: await blocks, nativeSave: true);

    /*final r = ID3V2Reader();
    final f = await r.read(blocks);*/
    return true;
  }
}