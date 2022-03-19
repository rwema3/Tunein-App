



import 'package:rxdart/rxdart.dart';
import 'package:xml/xml.dart' as xml;
import 'package:upnp/upnp.dart';
import 'dart:convert' show HtmlEscape;
class upnp{

  StateSubscriptionManager globalSub;
  List<StateSubscriptionManager> individualSubs=[];
  upnp();




  Future<Map<String, dynamic>> getCurrentMediaInfo({Service service}) async{
    return await service.invokeAction("GetMediaInfo", {
      "InstanceID":"0"
    });
  }

  Future<Map<String, dynamic>> pauseCurrentMedia({Service service}) async{
    return await service.invokeAction("Pause", {
      "InstanceID":"0"
    });
  }

  Future<Map<String, dynamic>> playCurrentMedia({Service service, String Speed}) async{
    return await service.invokeAction("Play", {
      "InstanceID":"0",
      "Speed":Speed??"1"
    });
  }

  Future<Map<String, dynamic>> stopCurrentMedia({Service service}) async{
    return await service.invokeAction("Stop", {
      "InstanceID":"0",
    });
  }

  Future<Map<String, dynamic>> getTransportSettings({Service service}) async{
    return await service.invokeAction("GetTransportSettings", {
      "InstanceID":"0"
    });
  }

  ///Will get info on the track duration and the position it is in right now
  ///
  ///
  ///Example : {Track: 1, TrackDuration: 00:40:21, TrackMetaData: <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/" xmlns:sec="http://www.sec.co.kr/" xmlns:xbmc="urn:schemas-xbmc-org:metadata-1-0/"><item id="plugin://plugin.video.youtube/play/?video_id=XfcvX0P1b5g" parentID="" restricted="1"><dc:title>Bitcoin - Unmasking Satoshi Nakamoto</dc:title><dc:creator>Unknown</dc:creator><dc:publisher>Unknown</dc:publisher><upnp:genre>Unknown</upnp:genre><upnp:albumArtURI dlna:profileID="JPEG_TN">http://192.168.1.2:1602/thumb?path=image%3A%2F%2Fhttps%253a%252f%252fi.ytimg.com%252fvi%252fXfcvX0P1b5g%252fhqdefault.jpg%2F</upnp:albumArtURI><upnp:lastPlaybackTime>1969-12-31T23:59:59+04:36</upnp:lastPlaybackTime><upnp:playbackCount>0</upnp:playbackCount><upnp:episodeSeason>0</upnp:episodeSeason><xbmc:dateadded>1969-12-31</xbmc:dateadded><xbmc:rating>0.0</xbmc:rating><xbmc:userrating>0</xbmc:userrating><upnp:class>object.item.videoItem</upnp:class></item></DIDL-Lite>, TrackURI: plugin://plugin.video.youtube/play/?video_id=XfcvX0P1b5g, RelTime: 00:00:10, AbsTime: 00:00:10, RelCount: 2147483647, AbsCount: 2147483647}
  Future<Map<String, dynamic>> getPositionInfo({Service service}) async{
    return await service.invokeAction("GetPositionInfo", {
      "InstanceID":"0"
    });
  }

  ///Return the current status of the playback
  ///
  ///
  ///Example : {CurrentTransportState: PAUSED_PLAYBACK, CurrentTransportStatus: OK, CurrentSpeed: 1}
  ///
  ///
  ///CurrentTransportState returned value can be on of the following :
  /// - PLAYING
  /// - PAUSED_PLAYBACK
  /// - STOPPED
  Future<Map<String, dynamic>> getTransportInfo({Service service}) async{
    return await service.invokeAction("GetTransportInfo", {
      "InstanceID":"0"
    });
  }


  ///Returns the device capabilities from playing and recording
  ///
  ///
  ///Example : {PlayMedia: NONE,NETWORK,HDD,CD-DA,UNKNOWN, RecMedia: NOT_IMPLEMENTED, RecQualityModes: NOT_IMPLEMENTED}
  Future<Map<String, dynamic>> getDeviceCapabilities({Service service}) async{
    return await service.invokeAction("GetDeviceCapabilities", {
      "InstanceID":"0"
    });
  }

  ///Returns the possible transport actions that can be called
  ///
  ///
  ///Example : {Actions: Play,Pause,Stop,Seek,Next,Previous}
  Future<Map<String, dynamic>> getTransportActions({Service service}) async{
    return await service.invokeAction("GetCurrentTransportActions", {
      "InstanceID":"0"
    });
  }

  ///Sets teh PlayMode to playmode argument
  ///
  ///
  ///Play Modes are one of the following :
  ///
  ///
  /// NORMAL :
  ///
  ///
  /// SHUFFLE :
  ///
  ///
  /// REPEAT_ONE :
  ///
  ///
  /// REPEAT_ALL :
  ///
  ///
  /// RANDOM :
  ///
  ///
  /// DIRECT_1 : Will only play the first track then completely stop
  ///
  ///
  /// INTRO : Will only play 1à seconds of each track then stop after playing (the 10 seconds) all of the tracks
  ///
  ///
  Future<Map<String, dynamic>> setPlayMode({Service service, String playmode}) async{
    return await service.invokeAction("GetCurrentTransportActions", {
      "InstanceID":"0",
      "NewPlayMode":playmode??"NORMAL"
    });
  }

  ///Will set the next item in the playlist To be early buffered
  ///
  ///
  ///[Objectclass] is a the type definition of the item to be played it can be of the following :
  ///
  ///
  /// - object.item.imageItem
  ///
  ///
  /// - object.item.audioItem
  ///
  ///
  /// - object.item.videoItem
  ///
  ///
  /// - object.item.playlistItem
  ///
  ///
  /// - object.item.textItem
  ///
  ///
  /// - object.item.bookmarkItem
  ///
  ///
  /// - object.item.epgItem
  ///
  ///
  /// Please visit the following source for more information
  ///
  ///
  /// Source : https://www.researchgate.net/figure/UPnP-DIDL-Lite-Metadata-Model-Listing-1-Abstract-DID-Model-The-abstract-DID-model-has_fig1_237063436
  ///
  /// [creator] is equivalent to author or artist and is just a string
  ///
  ///
  /// [uri] is the uri for the file, it should be public and accessible over http ( this is not a final version )
  Future<Map<String, dynamic>> setNextURI({Service service, String uri, String title, String creator, String Objectclass}) async{
    return await service.invokeAction("SetNextAVTransportURI", {
      "InstanceID":"0",
      "NextURI":uri??"",
      "NextURIMetaData":'<CurrentURIMetaData>&lt;DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sec="http://www.sec.co.kr/"&gt;&lt;item id="f-0" parentID="0" restricted="0"&gt;&lt;dc:title&gt;${title??"Untitled"}&lt;/dc:title&gt;&lt;dc:creator&gt;${creator??"NoCreator"}&lt;/dc:creator&gt;&lt;upnp:class&gt;${Objectclass??"object.item.videoItem"}&lt;/upnp:class&gt;&lt;res protocolInfo="*:*:audio:*" sec:URIType="public"&gt;${uri??""}&lt;/res&gt;&lt;/item&gt;&lt;/DIDL-Lite&gt;</CurrentURIMetaData>'
    });
  }


  ///This will override the current URI
  ///
  ///
  ///[Objectclass] is a the type definition of the item to be played it can be of the following :
  ///
  ///
  /// - object.item.imageItem
  ///
  ///
  /// - object.item.audioItem
  ///
  ///
  /// - object.item.videoItem
  ///
  ///
  /// - object.item.playlistItem
  ///
  ///
  /// - object.item.textItem
  ///
  ///
  /// - object.item.bookmarkItem
  ///
  ///
  /// - object.item.epgItem
  ///
  ///
  /// Please visit the following source for more information
  ///
  ///
  /// Source : http://www.upnp.org/schemas/av/upnp.xsd
  ///
  ///
  /// [creator] is equivalent to author or artist and is just a string
  ///
  ///
  /// [uri] is the uri for the file, it should be public and accessible over http ( this is not a final version )
  Future<Map<String, dynamic>> setCurrentURI({Service service, String uri, String artUri, String title, String creator,
    String Objectclass, String Duration, String Album ,int Size, String region, String genre, int trackNumber}) async{

    HtmlEscape htmlEscape = const HtmlEscape();

    return await service.invokeAction("SetAVTransportURI", {
      "InstanceID":"0",
      "CurrentURI":uri??"",
      "CurrentURIMetaData":(htmlEscape.convert(xml.parse('<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sec="http://www.sec.co.kr/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">'
          '<item id="0" parentID="-1" restricted="false">'
          '<upnp:class>${Objectclass??"object.item.audioItem.musicTrack"}</upnp:class>'
          '<dc:title>${title??"Unknown Title"}</dc:title>'
          '<dc:creator>${creator??"Unknown creator"}</dc:creator>'
          '<upnp:artist>${creator??"Unknown Artist"}</upnp:artist>'
          '<upnp:album>${Album}</upnp:album>'
          '<upnp:originalTrackNumber>${trackNumber??1}</upnp:originalTrackNumber>'
          '<dc:genre>${genre}</dc:genre>'
          '<upnp:albumArtURI dlna:profileID="JPEG_TN" xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/">${artUri}</upnp:albumArtURI>'
          '<res duration="${Duration}" size="${Size}" protocolInfo="http-get:*:audio/mpeg:DLNA.ORG_PN=MP3;DLNA.ORG_OP=01;DLNA.ORG_FLAGS=01700000000000000000000000000000">${uri}</res>'
          '</item>'
          '</DIDL-Lite>').toString()))
    });
  }

  Future<Map<String, dynamic>> goToPrevious({Service service}) async{
    return await service.invokeAction("Previous", {
      "InstanceID":"0"
    });
  }

  Future<Map<String, dynamic>> goToNext({Service service}) async{
    return await service.invokeAction("Next", {
      "InstanceID":"0"
    });
  }

  ///Seeks the current playing track to a specific position
  ///[position] is an absolute value and needs to be in this format : HH:MM:SS
  ///where HH is hours, MM is minutes and SS is seconds
  ///Example : 00:01:00
  Future<Map<String, dynamic>> seekPostion({Service service, String position}) async{
    return await service.invokeAction("Seek", {
      "InstanceID":"0",
      "Unit":"REL_TIME",
      "Target":position??"00:01:00"
    });
  }

  ///Subscribes to a service events and returns a map of the subscriptionID and all the event elements
  ///
  ///
  /// Returns a Future of a behavior stream that you can listen to. The returned stream needs to be MANUALLY
  /// canceled and closed when not used or when disposing of it
  ///
  ///
  /// [newSub] creates a new subscription to the event for the given service, so that it can be unsubscribed to on it's own
  /// it defaults to false and if set so, the subscription will be part of the global state subscription manager and will be unsubscribed to
  /// whenever that global state manager has been unsubscribed
  ///
  ///
  /// When set to true [newSub] will NEED a MANUAL un-subscription in order to free cpu and memory
  Future<BehaviorSubject<Map<String,String>>> subscribeToService({Service service, bool newSub=false}) async{
    var sub;
    int subIndex;
    BehaviorSubject<Map<String,String>> returnedBehaviorSubject = BehaviorSubject<Map<String,String>>.seeded(null);


    if(newSub || globalSub==null){
      sub = new StateSubscriptionManager();
      await sub.init();
      individualSubs.add(sub);
      subIndex=individualSubs.length-1;
    }else{
      if(globalSub==null){
        globalSub = new StateSubscriptionManager();
        await globalSub.init();
      }
      sub=globalSub;
    }


    Map<String,String> eventDataMap=Map();
    eventDataMap["subscriptionID"]= subIndex.toString();
    sub.subscribeToService(service).listen((value) {
      value.keys.forEach((elem){
        var eventData = value[elem];
        eventDataMap[elem]= eventData;
      });
      returnedBehaviorSubject.add(eventDataMap);
    }, onError: (e, stack) {
      print("Error while subscribing to ${service.type} : ${e}");
    });

    return returnedBehaviorSubject;
  }



  Future<bool> closeserviceSubscriptions({List<int> IDs}){
    if(IDs!=null){
      IDs.forEach((elemID){
        if(elemID < individualSubs.length-1 && individualSubs[elemID]!=null){
          individualSubs[elemID].close();
        }
      });
    }else{
      individualSubs.forEach((elem){
        elem.close();
      });
    }
  }

  Future<List<Device>> getDevices() async{
    List<Device> listOfDevicesThatSupportAVTransport=[];
    var disc = new DeviceDiscoverer();
    await disc.start(ipv6: false);
    Stream discoverStream = disc.quickDiscoverClients();
    await discoverStream.forEach((client) async {
      try {
        Device dev = await client.getDevice();
        var result = await dev.getService("urn:schemas-upnp-org:service:AVTransport:1");
        if(result!=null){
          listOfDevicesThatSupportAVTransport.add(dev);
        }
      } catch (e, stack) {
        print("ERROR: ${e} - ${client.location}");
        print(stack);
      }
    });

    return listOfDevicesThatSupportAVTransport;
  }


  
  Future<Service> getAVTTransportServiceFromDevice(Device dev) async{
    Service result = await dev.getService("urn:schemas-upnp-org:service:AVTransport:1");
    return result;
  }

}