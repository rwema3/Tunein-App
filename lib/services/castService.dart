import 'dart:async';
import 'dart:isolate';

import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:Tunein/services/platformService.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:upnp/upnp.dart';
import 'package:uuid/uuid.dart';
import 'package:Tunein/plugins/upnp.dart' as UpnpPlugin;
import 'package:xml/xml.dart' as xml;

enum CastState{
  CASTING,
  NOT_CASTING,
}

enum DeviceSearchingState{
  SEARCHING,
  NOT_SEARCHING
}





class CastService {

  BehaviorSubject<CastState> _castingState;
  BehaviorSubject<DeviceSearchingState> _deviceSearchingState;
  BehaviorSubject<PlayerState> _castingPlayerState;
  BehaviorSubject<CastItem> _castItem;
  BehaviorSubject<Duration> _currentPosition;
  BehaviorSubject<Device> _currentDeviceToBeUsed;
  Timer positionTimer;
  StreamSubscription castingPlayerStateTimer;
  BehaviorSubject<Map<String,String>> PlayerStateStream;
  UpnpPlugin.upnp UpnPPlugin;

  List<int> subscriptionIDs=[];
  final MusicServiceIsolate = locator<musicServiceIsolate>();
  final platformService = locator<PlatformService>();
  final SettingService = locator<settingService>();



  BehaviorSubject<CastItem> get castItem => _castItem;

  BehaviorSubject<CastState> get castingState => _castingState;


  BehaviorSubject<Duration> get currentPosition => _currentPosition;


  BehaviorSubject<Device> get currentDeviceToBeUsed => _currentDeviceToBeUsed;


  BehaviorSubject<PlayerState> get castingPlayerState => _castingPlayerState;


  BehaviorSubject<DeviceSearchingState> get deviceSearchingState =>
      _deviceSearchingState;

  CastService(){
    _initStreams();
  }


  Future feedCurrentPosition({bool perpetual=true, bool feedState=true}) async{
    if(perpetual){
      if(positionTimer==null){
        if(_currentDeviceToBeUsed.value!=null){
          positionTimer = Timer.periodic(Duration(seconds: 1), (Timer) async{
            if(castingState.value==CastState.CASTING &&  castingPlayerState.value==PlayerState.playing){
              UpnPPlugin.getPositionInfo(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value)).then(
                      (positionData){
                    String position = positionData["RelTime"];
                    Duration positionInDuration = FormatPositionToDuration(position);
                    if(positionInDuration!=null && (_currentPosition.value==null || positionInDuration.inSeconds!=_currentPosition.value.inSeconds)){
                      _currentPosition.add(positionInDuration);
                    }
                  }
              );
            }
          });
        }
      }

      if(feedState){
        if(castingPlayerStateTimer==null){
          if(_currentDeviceToBeUsed.value!=null){
            /*castingPlayerStateTimer = Timer.periodic(Duration(seconds: 1), (Timer) async{
              if(castingState.value==CastState.CASTING){
                UpnPPlugin.getTransportInfo(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value)).then(
                        (positionData){
                      String state = positionData["CurrentTransportState"];
                      switch(state){
                        case "PLAYING":{
                          _castingPlayerState.value!=PlayerState.playing?_castingPlayerState.add(PlayerState.playing):null;
                          break;
                        }
                        case "PAUSED_PLAYBACK":{
                          _castingPlayerState.value!=PlayerState.paused?_castingPlayerState.add(PlayerState.paused):null;
                          break;
                        }
                        case "STOPPED":{
                          _castingPlayerState.value!=PlayerState.stopped?_castingPlayerState.add(PlayerState.stopped):null;
                          break;
                        }
                        default:
                          break;
                      }
                    }
                );
              }
            });*/

             PlayerStateStream = await UpnPPlugin.subscribeToService(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value), newSub: true);

            castingPlayerStateTimer = PlayerStateStream.listen((data){
              if(data!=null){
                subscriptionIDs.indexOf(int.tryParse(data["subscriptionID"]))==-1?subscriptionIDs.add(int.tryParse(data["subscriptionID"])):null;
                xml.XmlDocument doc = xml.parse(data["LastChange"]);
                List<xml.XmlElement> listOFTransportState = doc.findAllElements("TransportState").toList();

                if(listOFTransportState.length!=0){
                  String state = listOFTransportState[0].getAttribute("val");
                  switch(state){
                    case "PLAYING":{
                      _castingPlayerState.value!=PlayerState.playing?_castingPlayerState.add(PlayerState.playing):null;
                      break;
                    }
                    case "PAUSED_PLAYBACK":{
                      _castingPlayerState.value!=PlayerState.paused?_castingPlayerState.add(PlayerState.paused):null;
                      break;
                    }
                    case "STOPPED":{
                      _castingPlayerState.value!=PlayerState.stopped?_castingPlayerState.add(PlayerState.stopped):null;
                      break;
                    }
                    default:
                      break;
                  }
                }
              }
            });
          }
        }
      }
    }
  }

  stopFeedingCurrentPosition(){
    if(positionTimer!=null){
      positionTimer.cancel();
      positionTimer=null;
    }
    if(castingPlayerStateTimer!=null){
      castingPlayerStateTimer.cancel();
      castingPlayerStateTimer=null;
      if(PlayerStateStream!=null){
        if(!PlayerStateStream.isClosed)PlayerStateStream.close();
        PlayerStateStream=null;
      }
    }

    try{
      UpnPPlugin.closeserviceSubscriptions(IDs: subscriptionIDs);
    }catch(e){
      print(e);
    }
  }

  ///This will return true when the device is ready
  ///
  /// [searching] will track the device if it is searching already for other devices to cast to
  ///
  /// [awaitClearance] will make the function return true only if all the input conditions are met (e.g if the device is not searching anymore)
  Future<bool> isDeviceClear({searching=true, awaitClearance=true}) async{
    bool finalverdict=false;
    DeviceSearchingState searchingState;
    if(searching){
      if(awaitClearance){
        searchingState = await _deviceSearchingState.firstWhere((data){
          return data==DeviceSearchingState.NOT_SEARCHING;
        });
        //redundant test for explaining
        if(searchingState==DeviceSearchingState.NOT_SEARCHING){
          finalverdict=true;
        }
      }else{
        if(_deviceSearchingState.value==DeviceSearchingState.NOT_SEARCHING){
          finalverdict=true;
        }
      }
    }
    return finalverdict;
  }

  Future<List<Device>> searchForDevices() async{
    if(_deviceSearchingState.value!=DeviceSearchingState.SEARCHING){
      _deviceSearchingState.add(DeviceSearchingState.SEARCHING);
      ReceivePort tempPort = ReceivePort();
      MusicServiceIsolate.sendCrossIsolateMessage(CrossIsolatesMessage(
          sender: tempPort.sendPort,
          command: "searchForCastDevices",
          message: ""
      ));

      List<Device> deviceList =[];
      await  tempPort.forEach((data){
        if(data!="OK"){
          tempPort.close();
          deviceList =data;
          _deviceSearchingState.add(DeviceSearchingState.NOT_SEARCHING);
        }
      });

      return deviceList;
    }else{
      return null;
    }
  }

  Future castAndPlay(Tune songToCast, {Tune nextSong, bool SingleCast=false, Device deviceToUse})async {
    if(_castingState.value==CastState.CASTING || SingleCast){
      await registerSongForServing(songToCast);
      if(songToCast.albumArt!=null){
        await registerArtForService("art${songToCast.id}",songToCast.albumArt);
      }

      String currentIP = await platformService.getCurrentIP();
      String currentPort = SettingService.getCurrentMemorySetting(SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT);
      String newURI = "http://${currentIP}:${currentPort}/file?fileID=${songToCast.id}.mp3";
      print(newURI);
      String newArtURI = "http://${currentIP}:${currentPort}/file?fileID=art${songToCast.id}.jpg";
      CastItem newItemToCast = CastItem(uri: newURI, name: songToCast.title.toString(), coverArtUri: songToCast.albumArt!=null?newArtURI:null, id: songToCast.id);

      Device currentDev = deviceToUse??_currentDeviceToBeUsed.value;
      UpnPPlugin.setCurrentURI(service: await currentDev.getService("urn:schemas-upnp-org:service:AVTransport:1"),
        uri: newItemToCast.uri,
        Objectclass: "object.item.audioItem",
        creator: songToCast.artist,
        title: newItemToCast.name,
        artUri: songToCast.albumArt!=null?newArtURI:null,
        Duration: DurationToFormatPosition(Duration(milliseconds: songToCast.duration)),
        trackNumber: songToCast.numberInAlbum,
        Album: songToCast.album,
      ).then((data){
        play();
        if(!SingleCast){
          _castItem.add(newItemToCast);
        }
        //_castingPlayerState.add(PlayerState.playing);
        return;
      });
    }
  }


  Future stopCasting() async{
     await UpnPPlugin.stopCurrentMedia(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value));
     _castingState.add(CastState.NOT_CASTING);
     stopFeedingCurrentPosition();
     return;
  }


  Future stopCurrentMedia() async{
    await UpnPPlugin.stopCurrentMedia(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value));
    return;
  }


  Future<dynamic> registerSongForServing(Tune song)async{
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossIsolateMessage(CrossIsolatesMessage(
        sender: tempPort.sendPort,
        command: "registerAFileToBeServed",
        message: MapEntry(song.id,MapEntry(song.uri, "audio/mpeg"))
    ));

    return tempPort.forEach((dataAlbums){
      if(dataAlbums==true){
        tempPort.close();
        return true;
      }
    });
  }

  Future<dynamic> registerArtForService(String id, String uri)async{
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossIsolateMessage(CrossIsolatesMessage(
        sender: tempPort.sendPort,
        command: "registerAFileToBeServed",
        message: MapEntry(id,MapEntry(uri,"image/jpeg"))
    ));

    return tempPort.forEach((dataAlbums){
      if(dataAlbums==true){
        tempPort.close();
        return true;
      }
    });
  }

  Future pauseCasting() async{
    await UpnPPlugin.pauseCurrentMedia(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value));
    return;
  }

  Future play()async {
    await UpnPPlugin.playCurrentMedia(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value));
    return;
  }

  Future seek(Duration durationToSeekTo) async{
    await UpnPPlugin.seekPostion(service: await UpnPPlugin.getAVTTransportServiceFromDevice(_currentDeviceToBeUsed.value), position: DurationToFormatPosition(durationToSeekTo));
    return;
  }


  void resumePlay(Tune songToBeCasted) async{
    if(_castingState.value==CastState.CASTING){
      play();
    }else{
      castAndPlay(songToBeCasted);
    }
  }


  setCastingState(CastState state){
    _castingState.add(state);
  }

  void setDeviceToBeUsed(Device dev){
    _currentDeviceToBeUsed.add(dev);
  }


  ///[position] must be in format hh:mm:ss
  FormatPositionToDuration(String position){
    List<String> splitChronos = position.split(":");
    int seconds = (int.parse(splitChronos[0])*(60*60))+(int.parse(splitChronos[1])*60)+(int.parse(splitChronos[2]));
    return Duration(seconds: seconds);
  }


  String DurationToFormatPosition(Duration duration){
    return duration.toString().split('.')[0];
  }


  _initStreams(){
    UpnPPlugin= UpnpPlugin.upnp();
    _castingState = BehaviorSubject<CastState>.seeded(CastState.NOT_CASTING);
    _castItem = BehaviorSubject<CastItem>.seeded(null);
    _currentPosition = BehaviorSubject<Duration>.seeded(Duration(milliseconds: 0));
    _castingPlayerState= BehaviorSubject<PlayerState>.seeded(PlayerState.stopped);
    _currentDeviceToBeUsed = BehaviorSubject<Device>.seeded(null);
    _deviceSearchingState = BehaviorSubject<DeviceSearchingState>.seeded(DeviceSearchingState.NOT_SEARCHING);
  }



  void dispose() {
    _castItem.close();
    _castingState.close();
    _deviceSearchingState.close();
  }
}




class CastItem {
  String name;
  String id;
  String uri;
  String coverArtUri;
  Duration duration;

  CastItem({this.name="Unnamed", this.id, this.uri, this.coverArtUri}){
   if(this.id==null){
     this.id = Uuid().v1();
   }
  }


}