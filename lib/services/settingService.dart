import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'locator.dart';



enum SettingsIds{
  SET_LANG,
  SET_ARTIST_THUMB_UPDATE,
  SET_DISCOG_API_KEY,
  SET_DISCOG_THUMB_QUALITY,
  SET_TRACK_LIST_DECK_ITEMS,
  SET_ALBUM_LIST_PAGE,
  SET_CUSTOM_NOTIFICATION_PLAYBACK_CONTROL,
  SET_ANDROID_NOTIFICATION_PLAYBACK_CONTROL,
  SET_OUT_GOING_HTTP_SERVER_IP,
  SET_OUT_GOING_HTTP_SERVER_PORT,
}



enum LIST_PAGE_SettingsIds{
  ALBUMS_PAGE_BOX_FADE_IN_DURATION,
  ALBUMS_PAGE_GRID_ROW_ITEM_COUNT,
  ARTISTS_PAGE_BOX_FADE_IN_DURATION,
  ARTISTS_PAGE_GRID_ROW_ITEM_COUNT,
}


class settingService{

  BehaviorSubject<Map<SettingsIds,String>> _settings$;

  List<MapEntry<SettingsIds, BehaviorSubject<String>>> activeSingleSettingListeners =List();
  Map<SettingsIds, String> activeSingleSettingOldValues = Map();
  BehaviorSubject<Map<SettingsIds, String>> get settings$ => _settings$;


  settingService(){
    _initStreams();
  }

  _initStreams(){
    _settings$ = BehaviorSubject<Map<SettingsIds,String>>.seeded(Map());
    SettingsIds.values.forEach((element) {
      addSinglSettingStream(element);
    });
    _startSingleSettingStreams();
  }

  _startSingleSettingStreams(){
    _settings$.listen((value) {
      activeSingleSettingListeners.forEach((activeListenerMap) {
        if(activeSingleSettingOldValues[activeListenerMap.key]!=null){
          if(value[activeListenerMap.key] !=activeSingleSettingOldValues[activeListenerMap.key]){
            activeListenerMap.value.add(value[activeListenerMap.key]);
            activeSingleSettingOldValues[activeListenerMap.key] = value[activeListenerMap.key];
          }
        }else{
          activeListenerMap.value.add(value[activeListenerMap.key]);
          activeSingleSettingOldValues[activeListenerMap.key] = value[activeListenerMap.key];
        }

      });
    });
  }

  MapEntry<SettingsIds, BehaviorSubject<String>> addSinglSettingStream(SettingsIds setting){
    MapEntry<SettingsIds, BehaviorSubject<String>> newStream = MapEntry(setting, new BehaviorSubject<String>.seeded(null));
    activeSingleSettingListeners.add(newStream);
    return newStream;
  }

  deleteSingSettingStream(SettingsIds setting){
    activeSingleSettingListeners.where((element) => element.key==setting).toList().forEach((activeListener) {
      !activeListener.value.isClosed?activeListener.value.close():null;
    });
    activeSingleSettingListeners.removeWhere((element) => element.key==setting);
  }

  BehaviorSubject<String> getOrCreateSingleSettingStream(SettingsIds setting){
    MapEntry<SettingsIds, BehaviorSubject<String>> existingStream = activeSingleSettingListeners.firstWhere((element) => element.key==setting,orElse: (){
      return null;
    });
    if(existingStream!=null && existingStream.value!=null && !existingStream.value.isClosed){
      return existingStream.value;
    }else{
      return addSinglSettingStream(setting).value;
    }
  }

  BehaviorSubject<Map<SettingsIds,String>> createSettingStreamOfASettingId(SettingsIds setting){
    return _settings$.distinct((prev,next)  {
      if(prev[setting]!=next[setting]){
        return true;
      }else{
        return false;
      }
    });
  }

  fetchSettings() async{
    Map<SettingsIds, String> settingsMap = new Map();
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    try{
      SettingsIds.values.toList().forEach((setting){
        String storedSettingValue = _prefs.getString(getEnumValue(setting).toString());
        if(storedSettingValue==null){
          settingsMap[setting] = getDefaultSetting(setting);
        }else{
          settingsMap[setting] = storedSettingValue;
        }

      });
    }catch (e){
      return false;
    }
    _settings$.add(settingsMap);
  }


  fetchSingleSetting(SettingsIds setting)async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    try{
      Map<SettingsIds, String> settingsMap = _settings$.value;
      settingsMap[setting]= _prefs.getString(getEnumValue(setting).toString());
      _settings$.add(settingsMap);
    }catch (e){
      print("Error in fetching setting ${e}");
      return false;
    }
  }


  getCurrentMemorySetting(SettingsIds setting){
    return _settings$.value[setting];
  }


  BehaviorSubject<String> subscribeToMemorySetting(SettingsIds settingsIds){
     BehaviorSubject<String> newStream = new BehaviorSubject<String>();
     _settings$.listen((data){
       newStream.add(data[settingsIds]);
     });

     return newStream;
  }

  updateSingleSetting(SettingsIds setting, String value) async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    try{
      Map<SettingsIds, String> settingsMap = _settings$.value;
      await _prefs.setString(getEnumValue(setting).toString(),value);
      settingsMap[setting]= value;
      _settings$.add(settingsMap);
      return true;
    }catch (e){
      print("Error in saving setting ${e}");
      return false;
    }
  }



  //Utils

  //will return the default setting for each settingID
  getDefaultSetting(SettingsIds setting){
    switch(setting){
      case SettingsIds.SET_LANG:
      return "English";
        break;
      case SettingsIds.SET_ARTIST_THUMB_UPDATE:
        return "false";
        break;
      case SettingsIds.SET_DISCOG_API_KEY:
        return null;
        break;
      case SettingsIds.SET_DISCOG_THUMB_QUALITY:
        return "Low";
        break;
      case SettingsIds.SET_TRACK_LIST_DECK_ITEMS:
        return null;
        break;
      case SettingsIds.SET_ALBUM_LIST_PAGE:
        return "{}";
        break;
      case SettingsIds.SET_CUSTOM_NOTIFICATION_PLAYBACK_CONTROL:
        return "true";
        break;
      case SettingsIds.SET_ANDROID_NOTIFICATION_PLAYBACK_CONTROL:
        return "true";
        break;
      case SettingsIds.SET_OUT_GOING_HTTP_SERVER_IP:
        return "0.0.0.0";
        break;
      case SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT:
        return "8090";
        break;
      default:
        return null;
        break;
    }
  }

  //will return the default setting for each Album SettingID
  getDefaultListPageSetting(LIST_PAGE_SettingsIds setting){
    switch(setting){
      case LIST_PAGE_SettingsIds.ALBUMS_PAGE_BOX_FADE_IN_DURATION:
        return "300";
        break;
      case LIST_PAGE_SettingsIds.ALBUMS_PAGE_GRID_ROW_ITEM_COUNT:
        return "3";
        break;
      case LIST_PAGE_SettingsIds.ARTISTS_PAGE_BOX_FADE_IN_DURATION:
        return "300";
        break;
      case LIST_PAGE_SettingsIds.ARTISTS_PAGE_GRID_ROW_ITEM_COUNT:
        return "3";
        break;
      default:
        return null;
        break;
    }
  }

  Map<LIST_PAGE_SettingsIds, String> DeserializeUISettings(String uiSettingsString){
    if(uiSettingsString!=null){
      Map<String,dynamic> TempMap = json.decode(uiSettingsString);
      Map<LIST_PAGE_SettingsIds, String> finalMap =Map();
      LIST_PAGE_SettingsIds.values.forEach((element) {
        int indexOfElementInAlbumSettingIDList = TempMap.keys.toList().indexOf(getAlbumListEnumValue(element));
        if(indexOfElementInAlbumSettingIDList!=-1){
          finalMap[element] = TempMap[getAlbumListEnumValue(element)];
        }else{
          finalMap[element] = getDefaultListPageSetting(element);
        }
      });
      return finalMap;
    }else{
      return null;
    }
  }

  String getEnumValue(SettingsIds set){
    return set.toString().split('.').last;
  }

  String getAlbumListEnumValue(LIST_PAGE_SettingsIds set){
    return set.toString();
  }

  void dispose() {
    _settings$.close();
    activeSingleSettingListeners.forEach((element) {
      element.value.close();
    });
  }
}

