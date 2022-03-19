import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/AudioReceiverService.dart';
import 'package:Tunein/plugins/ThemeReceiverService.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/http/server/httpOutgoingServer.dart';
import 'package:Tunein/services/isolates/pluginIsolateFunctions.dart';
import 'package:Tunein/services/isolates/standardIsolateFunctions.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_notification/media_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:Tunein/plugins/upnp.dart' as UPnPPlugin;
import 'package:upnp/upnp.dart';
import 'package:flutter_file_meta_data/flutter_file_meta_data.dart';


class musicServiceIsolate {
  static BehaviorSubject<MapEntry<PlayerState, Tune>> _playerState$ = BehaviorSubject<MapEntry<PlayerState, Tune>>.seeded(
    MapEntry(
      PlayerState.stopped,
      Tune(null, " ", " ", " ", null, null, null, [], null, null, null),
    ),
  );

  BehaviorSubject<MapEntry<PlayerState, Tune>> get playerState$ =>
      _playerState$;

  static Map pluginEnabledIsolateInitialData;

  musicServiceIsolate(){
    WidgetsFlutterBinding.ensureInitialized();
    _initStreams();
  }

  void dispose() {
    newIsolate?.kill(priority: Isolate.immediate);
    newIsolate = null;
    newPluginEnabledIsolate?.kill();
    newPluginEnabledIsolate=null;
  }


  static Map<String, MapEntry<String,String>> filesToServe=Map();

// Temporary attributes

  static Map mapMetaData = Map();

// Isolate  methods and attributes

  SendPort newIsolateSendPort;
  SendPort newPluginEnabledIsolateSendPort;

  Isolate newIsolate;
  FlutterIsolate newPluginEnabledIsolate;

// default port to receive on

  ReceivePort defaultReceivePort = ReceivePort();


  Future<bool> callerCreateIsolate() async {

    ReceivePort receivePort = ReceivePort();


    newIsolate = await Isolate.spawn(
      callbackFunction,
      receivePort.sendPort,
    );


    newIsolateSendPort = await receivePort.first;
    return true;
  }

  Future<bool> callerCreatePluginEnabledIsolate(Map initialData) async {

    ReceivePort receivePort = ReceivePort();

    pluginEnabledIsolateInitialData = initialData;
    newPluginEnabledIsolate = await FlutterIsolate.spawn(
      pluginEnabledIsolateCallbackFunction,
      receivePort.sendPort,
    );


    newPluginEnabledIsolateSendPort = await receivePort.first;
    return true;
  }


  Future<dynamic> sendReceive(String messageToBeSent) async {

    ReceivePort port = ReceivePort();


    newIsolateSendPort.send(CrossIsolatesMessage<String>(
        sender: port.sendPort, message: messageToBeSent, command: null));


    return port.first;
  }

  //Sending any crossIsolateMessage

  Future<dynamic> sendCrossIsolateMessage(
      CrossIsolatesMessage messageToBeSent) async {

    ReceivePort port = ReceivePort();


    messageToBeSent = new CrossIsolatesMessage(
        sender: messageToBeSent.sender==null?port.sendPort:messageToBeSent.sender,
        message: messageToBeSent.message,
        command: messageToBeSent.command);

    newIsolateSendPort.send(messageToBeSent);

    return port.first;
  }

  ///This only takes strings as the plugin isolates only take primitive types
  Future<dynamic> sendCrossPluginIsolatesMessage(
      CrossIsolatesMessage messageToBeSent) async {

    ReceivePort port = ReceivePort();


    messageToBeSent = new CrossIsolatesMessage(
        sender: messageToBeSent.sender==null?port.sendPort:messageToBeSent.sender,
        message: messageToBeSent.message,
        command: messageToBeSent.command);

    newPluginEnabledIsolateSendPort.send([messageToBeSent.command,messageToBeSent.message,messageToBeSent.sender]);

    return port.first;
  }

  ///The callback function used in the regular isolate
  static void callbackFunction(SendPort callerSendPort) {

    ReceivePort newIsolateReceivePort = ReceivePort();


    callerSendPort.send(newIsolateReceivePort.sendPort);


    newIsolateReceivePort.listen((dynamic message) {
      CrossIsolatesMessage incomingMessage = message as CrossIsolatesMessage;

      switch(incomingMessage.command){
        case "registerAFileToBeServed":{
          //The message structure is like follow : MapEntry(id, MapEntry(uri, contentType))
          MapEntry<String,MapEntry<String,String>> newMessage = incomingMessage.message;
          StandardIsolateFunctions.filesToServe[newMessage.key]= MapEntry(newMessage.value.key,newMessage.value.value);
          incomingMessage.sender.send(true);
          break;
        }
        case "getServedFilesList":{
          incomingMessage.sender.send(StandardIsolateFunctions.filesToServe);
          break;
        }
        case "searchForCastDevices":{
          if(incomingMessage.message!=null){

            StandardIsolateFunctions.searchForCastingDevices((data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }
        case "readExternalDirectory":{
          if(incomingMessage.message!=null){
            StandardIsolateFunctions.readExtDir(incomingMessage.message,(dataPath){
              incomingMessage.sender.send(dataPath);
            });
          }
          break;
        }
        case "encodeSongsToStringList":{
          if(incomingMessage.message!=null){
            StandardIsolateFunctions.saveSongsToPref(incomingMessage.message,(data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }

        case "fetchAlbumsFromSongs":{
          if(incomingMessage.message!=null){
            StandardIsolateFunctions.fetchAlbumFromsongs(incomingMessage.message,callback: (data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }


        case "encodeArtistsToStringList":{
          if(incomingMessage.message!=null){
            StandardIsolateFunctions.saveArtiststoPref(incomingMessage.message,(data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }

        case "getTopAlbums":{
          if(incomingMessage.message!=null){
            List<dynamic> segmentedMessage = incomingMessage.message as List<dynamic>;
            StandardIsolateFunctions.getTopAlbum(segmentedMessage[0], segmentedMessage[1], segmentedMessage[2],(data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }

        case "getMostPlayedSongs":{
          if(incomingMessage.message!=null){
            List<dynamic> segmentedMessage = incomingMessage.message as List<dynamic>;
            StandardIsolateFunctions.getMostPlayedSongs(segmentedMessage[0], segmentedMessage[1], segmentedMessage[2],(data){
              incomingMessage.sender.send(data);
            });
          }
          break;
        }
        case "createServerAndAddFilesHosting":{
          if(incomingMessage.message!=null){
            List<dynamic> segmentedMessage = incomingMessage.message as List<dynamic>;
            StandardIsolateFunctions.createServerAndAddImagesAndFiles(segmentedMessage[0],segmentedMessage[1],(value)=>(incomingMessage.sender as SendPort).send(value));
          }
          break;
        }
        default:
          break;
      }

      if (incomingMessage.sender != null) {
        incomingMessage.sender.send("OK");
      } else {}
    });
  }

  ///This callback function is used in the plugin enabled isolate
  static void pluginEnabledIsolateCallbackFunction(SendPort callerSendPort) {

    ReceivePort newIsolateReceivePort = ReceivePort();
    StreamSubscription NotificationTimestampSub ;

    AudioReceiverService audioReceiverService = new AudioReceiverService();

    callerSendPort.send(newIsolateReceivePort.sendPort);


    newIsolateReceivePort.listen((dynamic message) {
      WidgetsFlutterBinding.ensureInitialized();
      List<dynamic> incomingMessage = message as List<dynamic>;
      switch(incomingMessage[0] as String){
        case "test":{
          (incomingMessage[2] as SendPort).send(incomingMessage[1] as String);
          break;
        }
        case "getAllTracksMetadata":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.fetchMetadataOfAllTracks(incomingMessage[1],callback: (data){
              (incomingMessage[2] as SendPort).send(data);
            });
          }
          break;
        }

        case "writeImage":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.writeImage(null,incomingMessage[1]).then(
                    (data){
                  (incomingMessage[2] as SendPort).send(data.uri);
                }
            );
          }
          break;
        }

        case "playMusic":{
          if(incomingMessage[1]!=null){
            Map args = json.decode(incomingMessage[1]);
            audioReceiverService.playSong(args['uri'],
              albumArt: args["albumArt"],
              album: args["album"],
              title: args["title"],
              artist: args["artist"],
            ).then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "pauseMusic":{
          if(incomingMessage[1]!=null){
            audioReceiverService.pauseSong().then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "stopMusic":{
          if(incomingMessage[1]!=null){
            audioReceiverService.stopSong().then((data)=>(incomingMessage[2] as SendPort).send(data));

          }
          break;
        }
        case "seekMusic":{
          if(incomingMessage[1]!=null){
            audioReceiverService.seek(double.tryParse(incomingMessage[1])).then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "useAndroidNotification":{
          if(incomingMessage[1]!=null){
            Map args = json.decode(incomingMessage[1]);
            audioReceiverService.useNotification(useNotification: args["useNotification"], cancelWhenPlayingStops: args["cancelWhenNotPlaying"]).then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "showAndroidNotification":{
          if(incomingMessage[1]!=null){
            audioReceiverService.showNotification().then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "hideAndroidNotification":{
          if(incomingMessage[1]!=null){
            audioReceiverService.hideNotification().then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "setItem":{
          if(incomingMessage[1]!=null){
            Map args = json.decode(incomingMessage[1]);
            audioReceiverService.setItem(
              uri: args['uri'],
              albumArt: args["albumArt"],
              album: args["album"],
              title: args["title"],
              artist: args["artist"],
            ).then((data)=>(incomingMessage[2] as SendPort).send(data));
          }
          break;
        }
        case "subscribeToPosition":{
          if(incomingMessage[1]!=null){
            audioReceiverService.onPositionChanges((position) => (incomingMessage[2] as SendPort).send(position));
          }
          break;
        }
        case "subscribeToState":{
          if(incomingMessage[1]!=null){
            audioReceiverService.onStateChanges((state) => (incomingMessage[2] as SendPort).send(state));
          }
          break;
        }
        case "subscribeToplaybackKeys":{
          if(incomingMessage[1]!=null){
            audioReceiverService.onPlaybackKeys((keys) => (incomingMessage[2] as SendPort).send(keys));
          }
          break;
        }
        case "showNotification":{
          if(incomingMessage[1]!=null){
            Map<String, dynamic> convertedMap = json.decode(incomingMessage[1]);
            int BigLayoutIconColor = convertedMap["bigLayoutIconColor"]!=null?int.tryParse(convertedMap["bigLayoutIconColor"]):null;
            PluginIsolateFunctions.show(
              bigLayoutIconColor: BigLayoutIconColor!=null?Color(BigLayoutIconColor):null,
              author: convertedMap["author"]??"",
              bgColor: convertedMap["bgColor"]!=null?Color(int.tryParse(convertedMap["bgColor"])):Colors.white,
              BitmapImage: convertedMap["BitmapImage"]!=null?Uint8List.fromList((convertedMap["BitmapImage"] as List).map((e) => int.tryParse(e.toString())).toList()):null,
              iconColor: convertedMap["iconColor"]!=null?Color(int.tryParse(convertedMap["iconColor"])):Colors.white,
              image: convertedMap["image"],
              play: convertedMap["play"]??false,
              subtitleColor: convertedMap["subtitleColor"]!=null?Color(int.tryParse(convertedMap["subtitleColor"])):Colors.white,
              title: convertedMap["title"],
              titleColor: convertedMap["titleColor"]!=null?Color(int.tryParse(convertedMap["titleColor"])):Colors.white,
              bgImageBackgroundColor: convertedMap["bgImageBackgroundColor"]!=null?Color(int.tryParse(convertedMap["bgImageBackgroundColor"])):Colors.white,
              bgBitmapImage: convertedMap["bgBitmapImage"]!=null?Uint8List.fromList((convertedMap["bgBitmapImage"] as List).map((e) => int.tryParse(e.toString())).toList()):null,
              bgImage: convertedMap["bgImage"],
              callback: (data){
                (incomingMessage[2] as SendPort).send(data);
              }
            );

            if(NotificationTimestampSub==null)NotificationTimestampSub = audioReceiverService.onPositionChanges((position) => PluginIsolateFunctions.setNotificationTimeStamp(ConversionUtils.DurationToStandardTimeDisplay(inputDuration: position)));
          }
          break;
        }
        case "hideNotification":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.hide().then((value) {
              return NotificationTimestampSub.cancel().then((canceled) => (incomingMessage[2] as SendPort).send(value));
            });
          }
          break;
        }
        case "subscribeToNext":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.subscribeToNextButton((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "subscribeToPrev":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.subscribeToPrevButton((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "subscribeToPlay":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.subscribeToPlayButton((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "subscribeToPause":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.subscribeToPauseButton((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "subscribeToSelect":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.subscribeToSelectButton((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "setTo":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.setNotificationTo(incomingMessage[1]=="true", (value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "setStatusIcon":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.setNotificationStatusIcon(incomingMessage[1], (value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "setTitle":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.setNotificationTitle(incomingMessage[1], (value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "setSubtitle":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.setNotificationSubTitle(incomingMessage[1], (value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "togglePlaypauseButton":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.toggleNotificationPlayPause((value) => (incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        case "sdCardPermission":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.getSDCardAndPermissions((value)=>(incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
        //Theme service calls
        case "getArtistColors":
        case "getThemeColors":
        case "updateTheme":
          {
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.themeReceiverService.execute(incomingMessage[0], incomingMessage[1]).then((value)=>(incomingMessage[2] as SendPort).send(value));
          }
          break;
        }

        //Starter calls
        case "LoadStarterFiles":{
          if(incomingMessage[1]!=null){
            PluginIsolateFunctions.loadFiles().then((value)=>(incomingMessage[2] as SendPort).send(value));
          }
          break;
        }
      }
    });
  }


  void _initStreams() {
    _playerState$.listen((data){
      CrossIsolatesMessage messageToBeSent = new CrossIsolatesMessage<MapEntry<PlayerState,Tune>>(
          sender: null,
          message: data,
          command: "UPlayerstate");
      defaultReceivePort.sendPort.send(messageToBeSent);
    });
  }
}

//
// Helper class
//
class CrossIsolatesMessage<T> {
  final SendPort sender;
  final T message;
  final String command;

  CrossIsolatesMessage({
    @required this.command,
    @required this.sender,
    this.message,
  });
}
