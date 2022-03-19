import 'dart:async';

import 'package:Tunein/plugins/nano.dart';
import 'package:dio/dio.dart';
import 'package:Tunein/services/http/httpRequests.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/settingService.dart';



class Requests {

  final requestService  = locator<httpRequests>();
  final SettingsService  = locator<settingService>();

  Map<SettingsIds,String> Settings = new Map();
  StreamSubscription settingStreamSubscription;

  Requests(){
    settingStreamSubscription = SettingsService.settings$.listen((data){
      Settings=data;
    });
  }

  static String SPOTIFY_SEARCH_URL = "https://api.spotify.com/v1/search";
  static String SPOTIFY_API_KEY = "https://api.spotify.com/v1/search";
  static String ARTIST_DATA_URL ="https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF";

  static String LAST_FOM_API_KEY="abeaa955cfeb92a1c9e3ca52bebb120f";

  static String DISCOGS_SEARCH_URL = "https://api.discogs.com/database/search";
  static String DISCOGS_ARTIST_URL = "https://api.discogs.com/artists/";
  static String DISCOGS_API_TOKEN = "xhvYJGwbYCsfKYrbGisBLoNlowOsnZSRUrBAStCR";




  Future spotifySearch(String searchTerm, {String type="artist"}) async {


    Response requestResqponse = await requestService.get(
        url: SPOTIFY_SEARCH_URL,
        data: {
          "q":searchTerm,
          "type":type,
        },
        headers: {
          "Authorization":"Bearer "+SPOTIFY_API_KEY
        }
    );

    if(requestResqponse.data !=null){
      return requestResqponse.data;
    }
  }


  Future discogsSearch(String searchTerm, {String type="artist"}) async {


    Response requestResqponse = await requestService.get(
        url: DISCOGS_SEARCH_URL,
        data: {
          "q":searchTerm,
          "type":type,
          "token":Settings[SettingsIds.SET_DISCOG_API_KEY]
        },
    );

    if(requestResqponse.data !=null){
      print(requestResqponse.data);
      return requestResqponse.data;
    }
  }


  Future<Map> getArtistDataFromDiscogs(Artist artist) async{

    if(artist.name==null) return null;

    if(artist.apiData["discogID"]==null){
      print("not gone use discogID");
      dynamic result = await discogsSearch(artist.name);
      //discogs specific response schema
      if(result["results"].length==0){
        return null;
      }
      //by default the most accurate result from the search is the first one
      //This could be added as a configuration option in the future
      return result["results"][0];
    }else{
      print("gone use discogID");
      Response requestResqponse = await requestService.get(
          url: DISCOGS_ARTIST_URL+artist.apiData["discogID"],
          data: {
            "token":DISCOGS_API_TOKEN
          }
      );
      if(requestResqponse.data !=null){
        return requestResqponse.data;
      }else{
        return null;
      }
    }
  }


  Future<Map> getDiscogArtistData(Artist artist) async{
    if(artist.name==null) return null;
    if(artist.apiData["discogID"]==null){
      dynamic result = await discogsSearch(artist.name);
      //discogs specific response schema
      if(result["results"].length==0){
        return null;
      }
      //by default the most accurate result from the search is the first one
      //This could be added as a configuration option in the future
      int id =  result["results"][0]["id"];
      Response requestResqponse = await requestService.get(
          url: DISCOGS_ARTIST_URL+id.toString(),
          data: {
            "token":DISCOGS_API_TOKEN
          }
      );
      if(requestResqponse.data !=null){
        return requestResqponse.data;
      }else{
        return null;
      }
    }else{
      Response requestResqponse = await requestService.get(
          url: DISCOGS_ARTIST_URL+artist.apiData["discogID"],
          data: {
            "token":DISCOGS_API_TOKEN
          }
      );
      if(requestResqponse.data !=null){
        return requestResqponse.data;
      }else{
        return null;
      }
    }
  }

  Future<dynamic> pingURL(String url, {Duration timeout}) async{
    if(url!=null){
      Response requestResponse = await requestService.get(
        url: url,
        timeout: timeout.inSeconds,
      );
      if(requestResponse!=null){
        return requestResponse.data;
      }else{
        return null;
      }
    }
  }


  void dispose(){
    settingStreamSubscription?.cancel();
  }
}