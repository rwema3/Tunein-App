import 'dart:convert';
import 'dart:io';

import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/songInfoWidget.dart';
import 'package:Tunein/components/trackListDeck.dart';
import 'package:Tunein/components/trackListDeckItem.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/single/singleAlbum.page.dart';
import 'package:Tunein/pages/single/singleArtistPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/http/requests.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/routes/pageRoutes.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Tunein/models/playback.dart';
import 'dart:math';
import 'dart:core';
import 'package:Tunein/values/contextMenus.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:upnp/upnp.dart' as upnp;

class TracksPage extends StatefulWidget {

  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage>
    with AutomaticKeepAliveClientMixin<TracksPage> {
  final musicService = locator<MusicService>();
  final SettingService = locator<settingService>();
  final castService = locator<CastService>();
  final RequestSettings = locator<Requests>();

  ScrollController controller;
  ScrollPosition listPosition;
  List<Tune> songs;
  BehaviorSubject<List<Tune>> currentSongs= BehaviorSubject<List<Tune>>();
  BehaviorSubject<List<Tune>> newSongListWithFilters= BehaviorSubject<List<Tune>>();
  Map<String,TrackListDeckItemState> deckItemState;
  Map<String,Key> deckItemKeys;
  Map<String, BehaviorSubject> deckItemStateStream;
  Map<String, PopupMenu> deckItemMenu;
  @override
  void initState(){
    controller = ScrollController();
    controller.addListener((){
      listPosition =  controller.positions.toList()[0];
    });
    deckItemState= readTrackListDeckSettingsFromDisk();
    if(deckItemState==null){
      deckItemState={
        "shuffle":TrackListDeckItemState(),
        "sort": TrackListDeckItemState(),
        "filter": TrackListDeckItemState(),
        "cast": TrackListDeckItemState()
      };
      saveTrackListDeckSettingsToDisk();
    }
    deckItemKeys={
      "shuffle":GlobalKey(),
      "sort": GlobalKey(),
      "filter": GlobalKey(),
      "cast": GlobalKey()
    };


    deckItemStateStream={
      "cast": BehaviorSubject<Map<String,dynamic>>()
    };

    deckItemMenu={
      "shuffle":null,
      "sort": null,
      "filter": null,
      "cast":null
    };


    musicService.songs$.listen((data){
      currentSongs.add(applyDeckItemChanges(data));
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screensize = MediaQuery.of(context).size;

    double getSongPosition(int indexOfThePlayingSong,double numberOfSongsPerScreen){
      double finalNumber =((((indexOfThePlayingSong)/numberOfSongsPerScreen) - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor()));
      if(finalNumber.abs() <numberOfSongsPerScreen/2){
        return -((numberOfSongsPerScreen/2) - finalNumber)*62;
      }else{
        return (finalNumber - (numberOfSongsPerScreen/2))*62;
      }
    }



    WidgetsBinding.instance.addPostFrameCallback((duration){
      double numberOfSongsPerScreen =((screensize.height-160)/62);
      Rx.combineLatest2(musicService.playerState$, newSongListWithFilters, (a,b)=>MapEntry<MapEntry<PlayerState, Tune>,List<Tune>>(a,b)).listen(( MapEntry<MapEntry<PlayerState, Tune>,List<Tune>> value){
        if(value!=null &&  value.key!=null && value.value!=null){
          int indexOfThePlayingSong =value.value.indexWhere((elem){
            return value.key.value.id==elem.id;
          });
          if(indexOfThePlayingSong>0){
            /*print("  index : ${indexOfThePlayingSong} final value : ${(pow(log(indexOfThePlayingSong)*2, 2)).floor()}  value of Songs per screen : ${numberOfSongsPerScreen}  and the pool ${(indexOfThePlayingSong/numberOfSongsPerScreen)}");
          print("the difference between the pool number based postion and the oridnary index*size postion : ${((indexOfThePlayingSong)/numberOfSongsPerScreen - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor())*numberOfSongsPerScreen}");
          print(" the ideal position would be equal to the desired pool and a portion of the next pool so that the final position to scroll to would be determined by creating a virtual pool between the previous"
              "pool and the next one in order to put the desired song in the middle of the screen this will be done by finding out the difference between the position of the song in the pool and "
              "half of the pool : the position of the song in the new pool : ${((indexOfThePlayingSong)/numberOfSongsPerScreen - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor())*numberOfSongsPerScreen}, The difference "
              "is (${numberOfSongsPerScreen} - ${((indexOfThePlayingSong)/numberOfSongsPerScreen - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor())*numberOfSongsPerScreen}) = ${((indexOfThePlayingSong)/numberOfSongsPerScreen - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor())*numberOfSongsPerScreen - numberOfSongsPerScreen}"
              "if the difference is less than half of the pool size in number of songs the scroll position should be pulled back else it should be pushed forward");


          print("${((((indexOfThePlayingSong)/numberOfSongsPerScreen))*numberOfSongsPerScreen*62)} added value : ${getSongPosition(indexOfThePlayingSong,numberOfSongsPerScreen)} final Value : ${(indexOfThePlayingSong*61.2)+getSongPosition(indexOfThePlayingSong,numberOfSongsPerScreen)}");*/

            if(controller.hasClients){
              controller.animateTo(((indexOfThePlayingSong+1)*62)+getSongPosition(indexOfThePlayingSong,numberOfSongsPerScreen),duration: Duration(
                  milliseconds: (pow(log(indexOfThePlayingSong*2), 2)).floor() + 50
              ),
                  curve: Curves.fastOutSlowIn
              );
            }
          }
        }
      });
    });
    return Container(
      alignment: Alignment.center,
      color: MyTheme.darkBlack,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: 62,
                  margin: EdgeInsets.only(bottom: 5),
                  child: TrackListDeck(
                    items: [
                      TrackListDeckItem(
                        initialState: deckItemState["shuffle"],
                        globalWidgetKey: deckItemKeys["shuffle"],
                        onBuild: (){
                          Widget badgeToBe;
                          Color badgeColor;
                          Color iconColor= Colors.white;
                          switch(deckItemState["shuffle"].activeNature){
                            case "auto":{
                              badgeToBe = Icon(IconData(0xf526, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "artist":{
                              badgeToBe = Icon(IconData(0xf526, fontFamily: 'fontawesome'), color: MyTheme.grey300,);
                              badgeColor=Colors.transparent;
                              break;
                            }
                            default:{
                              break;
                            }
                          }
                          if(deckItemState["shuffle"].isActive){
                            iconColor= MyTheme.darkRed;
                          }
                          return {
                            "withBadge":deckItemState["shuffle"].isActive,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor
                          };
                        },
                        title: "Shuffle",
                        subtitle:"All Tracks",
                        icon: Icon(
                          Icons.shuffle,
                        ),
                        onTap: (){
                          toggleSongShuffling();
                          Widget badgeToBe;
                          Color badgeColor;
                          Color iconColor= Colors.white;
                          switch(deckItemState["shuffle"].activeNature){
                            case "auto":{
                              badgeToBe = Icon(IconData(0xf526, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "artist":{
                              badgeToBe = Icon(Icons.person, color: MyTheme.grey300,);
                              badgeColor=Colors.transparent;
                              break;
                            }
                            default:{
                              break;
                            }
                          }
                          if(deckItemState["shuffle"].isActive){
                            iconColor= MyTheme.darkRed;
                          }
                          return {
                            "withBadge":deckItemState["shuffle"].isActive,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor
                          };
                        },
                      ),
                      TrackListDeckItem(
                        initialState: deckItemState["sort"],
                        globalWidgetKey: deckItemKeys["sort"],
                        onBuild: (){
                          Widget badgeToBe;
                          Color badgeColor;
                          Color iconColor= Colors.white;
                          switch(deckItemState["sort"].activeNature){
                            case "asc":{
                              badgeToBe = Icon(IconData(0xf15e, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "desc":{
                              badgeToBe = Icon(IconData(0xf881, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            default:{
                              break;
                            }
                          }
                          if(deckItemState["sort"].isActive){
                            iconColor= MyTheme.darkRed;
                          }
                          return {
                            "withBadge":deckItemState["sort"].isActive,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor
                          };
                        },
                        title: "Sort",
                        subtitle:"All Tracks",
                        icon: Icon(Icons.sort),
                        onTap: (){
                          if(!deckItemState["sort"].isActive){
                            //if any sorting is active, just tapping would deactivate it
                            toggleApplySortingSongs("asc");
                          }else{
                            //passing the current nature as nature to set would trigger the deactivation
                            //of the sorting. This could be used for all items
                            toggleApplySortingSongs(deckItemState["sort"].activeNature);
                          }
                          Widget badgeToBe;
                          Color badgeColor;
                          Color iconColor= Colors.white;
                          switch(deckItemState["sort"].activeNature){
                            case "asc":{
                              badgeToBe = Icon(IconData(0xf15e, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "desc":{
                              badgeToBe = Icon(IconData(0xf881, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            default:{
                              break;
                            }
                          }
                          if(deckItemState["sort"].isActive){
                            iconColor= MyTheme.darkRed;
                          }
                          return {
                            "withBadge":deckItemState["sort"].isActive,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor
                          };
                        },
                        onLongPress: () async{
                          BehaviorSubject<Map> returnvalue= BehaviorSubject<Map>();
                          PopupMenu sortMenu = PopupMenu(
                              backgroundColor: MyTheme.darkRed,
                              lineColor: Colors.transparent,
                              maxColumn: 2,
                              context: context,
                              items: [
                                MenuItem(
                                    title: 'ASC',
                                    textStyle: TextStyle(
                                        fontSize: 10.0,
                                        color: (deckItemState["sort"].isActive && deckItemState["sort"].activeNature=="asc")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack
                                    ),
                                    image: Icon(
                                      IconData(0xf15e, fontFamily: 'fontawesome'),
                                      size: 30,
                                      color: (deckItemState["sort"].isActive && deckItemState["sort"].activeNature=="asc")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    )
                                ),
                                MenuItem(
                                    title: 'DESC',
                                    textStyle: TextStyle(
                                      fontSize: 10.0,
                                      color: (deckItemState["sort"].isActive && deckItemState["sort"].activeNature=="desc")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    ),
                                    image: Icon(
                                      IconData(0xf881, fontFamily: 'fontawesome'),
                                      size: 30,
                                      color: (deckItemState["sort"].isActive && deckItemState["sort"].activeNature=="desc")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    )
                                ),
                              ],
                              onClickMenu: (provider){
                                print("provider got is : ${provider}");
                                switch(provider.menuTitle){
                                  case "ASC":{
                                    toggleApplySortingSongs("asc");
                                    break;
                                  }
                                  case "DESC":{
                                    toggleApplySortingSongs("desc");
                                    break;
                                  }
                                  default:{
                                    break;
                                  }

                                }
                              },
                              onDismiss: (){
                                print("dismissed");
                              });
                          dismissAllShownMenus();
                          sortMenu.show(widgetKey: deckItemKeys["sort"]);
                          deckItemMenu["sort"]= sortMenu;
                          sortMenu.dismissCallback = (){
                            Widget badgeToBe;
                            Color badgeColor;
                            Color iconColor= Colors.white;
                            switch(deckItemState["sort"].activeNature){
                              case "asc":{
                                badgeToBe = Icon(IconData(0xf15e, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              case "desc":{
                                badgeToBe = Icon(IconData(0xf881, fontFamily: 'fontawesome'), size: 17, color: MyTheme.grey300);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              default:{
                                break;
                              }
                            }
                            if(deckItemState["sort"].isActive){
                              iconColor= MyTheme.darkRed;
                            }

                            returnvalue.add( {
                              "withBadge":deckItemState["sort"].isActive,
                              "badgeContent": badgeToBe,
                              "badgeColor":badgeColor,
                              "iconColor":iconColor
                            });
                          };

                          return returnvalue.first;
                        },
                      ),
                      TrackListDeckItem(
                        globalWidgetKey: deckItemKeys["filter"],
                        initialState: deckItemState["filter"],
                        title: "Filter",
                        subtitle:"All Tracks",
                        icon: Icon(Icons.filter_list),
                        onBuild: (){
                          Widget badgeToBe;
                          Color badgeColor;
                          Color iconColor= Colors.white;
                          switch(deckItemState["filter"].activeNature){
                            case "keyword":{
                              badgeToBe = Icon(Icons.keyboard, color: MyTheme.grey300, size: 17);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "artist":{
                              badgeToBe = Icon(Icons.person, color: MyTheme.grey300, size: 17);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            case "album":{
                              badgeToBe = Icon(Icons.album, color: MyTheme.grey300, size: 17);
                              badgeColor= Colors.transparent;
                              break;
                            }
                            default:{
                              break;
                            }
                          }
                          if(deckItemState["filter"].isActive){
                            iconColor= MyTheme.darkRed;
                          }
                          return {
                            "withBadge":deckItemState["filter"].isActive,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor
                          };
                        },
                        onTap: (){
                          BehaviorSubject<Map> returnvalue= BehaviorSubject<Map>();
                          returnFirstValue(){
                            Widget badgeToBe;
                            Color badgeColor;
                            Color iconColor= Colors.white;
                            switch(deckItemState["filter"].activeNature){
                              case "keyword":{
                                badgeToBe = Icon(Icons.keyboard, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              case "artist":{
                                badgeToBe = Icon(Icons.person, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              case "album":{
                                badgeToBe = Icon(Icons.album, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              default:{
                                break;
                              }
                            }
                            if(deckItemState["filter"].isActive){
                              iconColor= MyTheme.darkRed;
                            }
                            returnvalue.add({
                              "withBadge":deckItemState["filter"].isActive,
                              "badgeContent": badgeToBe,
                              "badgeColor":badgeColor,
                              "iconColor":iconColor
                            }) ;
                          }
                          //if any sorting is active, just tapping would deactivate it
                          if(!deckItemState["filter"].isActive){

                            toggleApplyFiltering("keyword").then((data){
                              returnFirstValue();
                            });
                          }else{
                            //passing the current nature as nature to set would trigger the deactivation
                            //of the sorting. This could be used for all items
                            toggleApplyFiltering(deckItemState["filter"].activeNature).then((data){
                              returnFirstValue();
                            });
                          }
                          return returnvalue.first;
                        },

                        onLongPress: (){
                          BehaviorSubject<Map> returnvalue= BehaviorSubject<Map>();
                          returnFirstValue(){
                            Widget badgeToBe;
                            Color badgeColor;
                            Color iconColor= Colors.white;
                            switch(deckItemState["filter"].activeNature){
                              case "keyword":{
                                badgeToBe = Icon(Icons.keyboard, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              case "artist":{
                                badgeToBe = Icon(Icons.person, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              case "album":{
                                badgeToBe = Icon(Icons.album, color: MyTheme.grey300, size: 17);
                                badgeColor= Colors.transparent;
                                break;
                              }
                              default:{
                                break;
                              }
                            }
                            if(deckItemState["filter"].isActive){
                              iconColor= MyTheme.darkRed;
                            }
                            returnvalue.add({
                              "withBadge":deckItemState["filter"].isActive,
                              "badgeContent": badgeToBe,
                              "badgeColor":badgeColor,
                              "iconColor":iconColor
                            }) ;
                          }
                          PopupMenu sortMenu = PopupMenu(
                              backgroundColor: MyTheme.darkRed,
                              lineColor: Colors.transparent,
                              maxColumn: 3,
                              context: context,
                              items: [
                                MenuItem(
                                    title: 'Keyword',
                                    textStyle: TextStyle(
                                        fontSize: 10.0,
                                        color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="keyword")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack
                                    ),
                                    image: Icon(
                                      Icons.keyboard,
                                      size: 30,
                                      color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="keyword")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    )
                                ),
                                MenuItem(
                                    title: 'Artist',
                                    textStyle: TextStyle(
                                      fontSize: 10.0,
                                      color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="artist")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    ),
                                    image: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="artist")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    )
                                ),
                                MenuItem(
                                    title: 'Album',
                                    textStyle: TextStyle(
                                      fontSize: 10.0,
                                      color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="album")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    ),
                                    image: Icon(
                                      Icons.album,
                                      size: 30,
                                      color: (deckItemState["filter"].isActive && deckItemState["filter"].activeNature=="album")?MyTheme.grey300.withOpacity(.9):MyTheme.darkBlack,
                                    )
                                ),
                              ],
                              onClickMenu: (provider){
                                print("provider got is : ${provider}");
                                switch(provider.menuTitle){
                                  case "Album":{
                                    toggleApplyFiltering("album").then((data){
                                      print("gona return value");
                                      returnFirstValue();
                                    });
                                    break;
                                  }
                                  case "Artist":{
                                    toggleApplyFiltering("artist").then((data){
                                      returnFirstValue();
                                    });
                                    break;
                                  }
                                  case "Keyword":{
                                    toggleApplyFiltering("keyword").then((data){
                                      returnFirstValue();
                                    });
                                    break;
                                  }
                                  default:{
                                    break;
                                  }

                                }
                              },
                              onDismiss: (){
                                print("dismissed");
                              });
                          dismissAllShownMenus();
                          sortMenu.show(widgetKey: deckItemKeys["filter"]);
                          deckItemMenu["sort"]= sortMenu;
                          return returnvalue.first;
                        },
                      ),
                      TrackListDeckItem(
                        globalWidgetKey: deckItemKeys["cast"],
                        initialState: deckItemState["cast"],
                        stateStream: deckItemStateStream["cast"],
                        title: "Cast",
                        subtitle:"Casting control",
                        icon: Icon(Icons.cast),
                        onBuild: (){
                          Widget badgeToBe;
                          Color badgeColor;
                          Icon iconToBe = Icon(Icons.cast);
                          Color iconColor= Colors.white;
                          if(deckItemState["cast"].isActive && (castService.castingState==CastState.CASTING)){
                            iconColor= MyTheme.darkRed;
                            iconToBe = Icon(Icons.cast_connected);
                          }
                          //The following condition will be triggered when the casting state
                          //changes elsewhere so we must update this widget and toggle the casting
                          castService.castingState.distinct().listen((data){
                            print("the stream is distinct ${data}");
                            Widget badgeToBe;
                            Color badgeColor;
                            Icon iconToBe = Icon(Icons.cast);
                            String title = "Cast";
                            Color iconColor= Colors.white;

                            if(data==CastState.CASTING){
                              deckItemState["cast"].isActive=true;
                              iconColor= MyTheme.darkRed;
                              iconToBe = Icon(Icons.cast_connected);
                              title="Casting..";
                            }else{
                              deckItemState["cast"].isActive=false;
                            }
                            if(deckItemStateStream["cast"]!=null){
                              deckItemStateStream["cast"].add({
                                "withBadge":false,
                                "badgeContent": badgeToBe,
                                "badgeColor":badgeColor,
                                "iconColor":iconColor,
                                "icon":iconToBe,
                                "title":title
                              });
                            }
                          });

                          return {
                            "withBadge":false,
                            "badgeContent": badgeToBe,
                            "badgeColor":badgeColor,
                            "iconColor":iconColor,
                            "icon":iconToBe
                          };

                        },
                        onTap: (){
                          deckItemStateStream["cast"].add({
                            "withBadge":true,
                            "badgeContent": FlashingBadgeIcon(
                              child: IconData(0xf7c0, fontFamily: 'fontawesome'),
                              colors: [MyTheme.grey300, MyTheme.darkRed],
                              flash: true,
                              IconSize: 17,
                            ),
                            "badgeColor":Colors.transparent,
                          });
                          BehaviorSubject<Map> returnvalue= BehaviorSubject<Map>();
                          returnFirstValue(){
                            Widget badgeToBe;
                            Color badgeColor;
                            Icon iconToBe = Icon(Icons.cast);
                            Color iconColor= Colors.white;
                            String title = "Cast";
                            if(deckItemState["cast"].isActive){
                              iconColor= MyTheme.darkRed;
                              iconToBe = Icon(Icons.cast_connected);
                              title="Casting..";
                            }
                            returnvalue.add({
                              "withBadge":false,
                              "badgeContent": badgeToBe,
                              "badgeColor":badgeColor,
                              "iconColor":iconColor,
                              "icon":iconToBe,
                              "title":title
                            });
                          }
                          //You always toggle the casting since that already takes consideration of the
                          // current value of the cast and doesn't need any arguments
                          castService.isDeviceClear(awaitClearance: false).then((data){
                            if(!data){
                              print("device not clear");
                            }
                            if(data){
                              toggleCasting().then((castingData){
                                returnFirstValue();
                              });
                            }
                          });
                          return returnvalue.first;
                        },

                        onLongPress: (){
                          BehaviorSubject<Map> returnvalue= BehaviorSubject<Map>();
                          returnFirstValue(){
                            Widget badgeToBe;
                            Color badgeColor;
                            Icon iconToBe = Icon(Icons.cast);
                            Color iconColor= Colors.white;
                            String title = "Cast";
                            if(deckItemState["cast"].isActive){
                              iconColor= MyTheme.darkRed;
                              iconToBe = Icon(Icons.cast_connected);
                              title="Casting..";
                            }
                            returnvalue.add({
                              "withBadge":false,
                              "badgeContent": badgeToBe,
                              "badgeColor":badgeColor,
                              "iconColor":iconColor,
                              "icon":iconToBe,
                              "title":title
                            }) ;
                          }
                          PopupMenu sortMenu = PopupMenu(
                              backgroundColor: MyTheme.darkRed,
                              lineColor: Colors.transparent,
                              maxColumn: 1,
                              context: context,
                              items: [
                                MenuItem(
                                    title: 'Search',
                                    textStyle: TextStyle(
                                        fontSize: 10.0,
                                        color: MyTheme.darkBlack
                                    ),
                                    image: Container(
                                      height: 30,
                                      width: 30,
                                      child: Stack(
                                        children: <Widget>[
                                          Icon(
                                            Icons.search,
                                            size: 35,
                                            color: MyTheme.darkBlack,
                                          ),
                                          Positioned(
                                            child: Icon(
                                              Icons.cast,
                                              size: 10,
                                              color: MyTheme.darkBlack
                                            ),
                                            left: 9,
                                            top: 9,
                                          )
                                        ],
                                      ),
                                    )
                                ),
                              ],
                              onClickMenu: (provider){
                                print("provider got is : ${provider}");
                                switch(provider.menuTitle){
                                  case "Search":{
                                    DialogService.openDevicePickingDialog(context, null).then(
                                        (data){
                                          upnp.Device deviceChosen = data;
                                          if(deviceChosen!=null){
                                            castService.setDeviceToBeUsed(deviceChosen);
                                            castService.setCastingState(CastState.CASTING);
                                            deckItemState["cast"].isActive=true;
                                            saveTrackListDeckSettingsToDisk();
                                            returnFirstValue();
                                          }
                                        }
                                    );
                                    break;
                                  }
                                  default:{
                                    break;
                                  }

                                }
                              },
                              onDismiss: (){
                                print("dismissed");
                              });
                          dismissAllShownMenus();
                          sortMenu.show(widgetKey: deckItemKeys["cast"]);
                          deckItemMenu["sort"]= sortMenu;
                          return returnvalue.first;
                        },
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: StreamBuilder(
                    stream: currentSongs,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Tune>> snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      List<Tune> _songs = snapshot.data;

                      if(deckItemState!=null && !deckItemState["shuffle"].isActive && !deckItemState["sort"].isActive && !deckItemState["filter"].isActive){
                        _songs.sort((a, b) {
                          return a.title
                              .toLowerCase()
                              .compareTo(b.title.toLowerCase());
                        });
                      }else{
                        //Do nothing for now
                        //_songs=applyDeckItemChanges(_songs);
                      }
                      songs=_songs;
                      newSongListWithFilters.add(songs);
                      return FadingEdgeScrollView.fromScrollView(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          controller: controller,
                          shrinkWrap: true,
                          itemExtent: 62,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: _songs.length,
                          itemBuilder: (context, index) {
                            int newIndex = index;
                            return InkWell(
                              enableFeedback: false,
                              child: MyCard(
                                ScreenSize: screensize,
                                choices: songCardContextMenulist,
                                StaticContextMenuFromBottom: 190,
                                onContextSelect: (choice) async{
                                  switch(choice.id){
                                    case 1: {
                                      musicService.playOne(_songs[newIndex]);
                                      break;
                                    }
                                    case 2:{
                                      musicService.startWithAndShuffleQueue(_songs[newIndex], _songs);
                                      break;
                                    }
                                    case 3:{
                                      musicService.startWithAndShuffleAlbum(_songs[newIndex]);
                                      break;
                                    }
                                    case 4:{
                                      musicService.playAlbum(_songs[newIndex]);
                                      break;
                                    }
                                    case 5:{
                                      if(castService.currentDeviceToBeUsed.value==null){
                                        upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                        if(result!=null){
                                          castService.setDeviceToBeUsed(result);
                                        }
                                      }
                                      musicService.castOrPlay(_songs[newIndex], SingleCast: true);
                                      break;
                                    }
                                    case 6:{
                                      upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                      if(result!=null){
                                        musicService.castOrPlay(_songs[newIndex], SingleCast: true, device: result);
                                      }
                                      break;
                                    }
                                    case 7: {
                                      DialogService.showAlertDialog(context,
                                        title: "Song Information",
                                        content: SongInfoWidget(null, song: _songs[newIndex]),
                                        padding: EdgeInsets.only(top: 10)
                                      );
                                      break;
                                    }
                                    case 8:{
                                      PageRoutes.goToAlbumSongsList(_songs[newIndex], context);
                                      break;
                                    }
                                    case 9:{
                                      PageRoutes.goToSingleArtistPage(_songs[newIndex], context);
                                      break;
                                    }
                                    case 10:{
                                      PageRoutes.goToEditTagsPage(_songs[newIndex], context, subtract60ForBottomBar: false, rootRouter: true);
                                      break;
                                    }
                                  }
                                },
                                onContextCancel: (choice){
                                  print("Cancelled");
                                },
                                song: _songs[newIndex],
                                onTap: (){
                                  print(_songs[newIndex].colors);
                                  musicService.updatePlaylist(_songs);
                                  musicService.playOrPause(_songs[newIndex]);
                                },
                              ),
                            );
                          },
                        ),
                        gradientFractionOnStart: 0.2 ,
                        gradientFractionOnEnd: 0.0,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          MyScrollbar(
            controller: controller,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void goToAlbumSongsList(Tune song) async {
    Album album = musicService.getAlbumFromSong(song);
    if(album!=null){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SingleAlbumPage(null,
            album:album,
            heightToSubstract: 60,
          ),
        ),
      );
    }
  }

  void goToSingleArtistPage(Tune song){
    Artist artist = musicService.getArtistTitle(song.artist);
    if(artist!=null){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SingleArtistPage(artist, heightToSubstract: 60),
        ),
      );
    }
  }

  dismissAllShownMenus(){
    print("called");
    deckItemMenu.keys.forEach((elem){
      print("key : ${elem} is shown ? : ${deckItemMenu[elem]!=null && deckItemMenu[elem].isShow}");
      if(deckItemMenu[elem]!=null && deckItemMenu[elem].isShow){
        deckItemMenu[elem].dismiss();
      }
    });
  }

  void shuffleSongListAlphabetically(){
    List<Tune> songsValue = List.from(currentSongs.value);
    songsValue.shuffle();
    currentSongs.add(songsValue);
    deckItemState["shuffle"].isActive=true;
    deckItemState["shuffle"].activeNature="auto";
  }


  void toggleSongShuffling(){
    if(deckItemState["shuffle"].isActive){
      deckItemState["shuffle"].activeNature=null;
      deckItemState["shuffle"].isActive=false;
      List<Tune> songsValue = musicService.songs$.value;
      currentSongs.add(songsValue);
    }else{
      shuffleSongListAlphabetically();
    }

    saveTrackListDeckSettingsToDisk();
  }




  Future<bool> saveTrackListDeckSettingsToDisk() async{
    Map<String,String> mapToBeSaved= Map();
    deckItemState.keys.forEach((elem){
      mapToBeSaved[elem]= json.encode(deckItemState[elem].toMap());
    });
    String stringMap = json.encode(mapToBeSaved);
    await SettingService.updateSingleSetting(SettingsIds.SET_TRACK_LIST_DECK_ITEMS, stringMap);
  }


  Map<String, TrackListDeckItemState> readTrackListDeckSettingsFromDisk() {
    dynamic settingString = SettingService.getCurrentMemorySetting(SettingsIds.SET_TRACK_LIST_DECK_ITEMS);

    print(settingString!=null);
    if(settingString!=null){
      Map<String,dynamic> mapToBeSaved= Map();
      mapToBeSaved = json.decode(settingString);
      print(mapToBeSaved);
      Map<String, TrackListDeckItemState> finalMap=Map();
      mapToBeSaved.keys.forEach((elem){
        finalMap[elem] = TrackListDeckItemState.fromMap(json.decode(mapToBeSaved[elem]));
      });

      return finalMap;
    }else{
      return null;
    }


  }

  void toggleApplySortingSongs(String nature){
    if(deckItemState["sort"].isActive && deckItemState["sort"].activeNature==nature){
      deckItemState["sort"].activeNature=null;
      deckItemState["sort"].isActive=false;
      List<Tune> songsValue = musicService.songs$.value;
      currentSongs.add(applyDeckItemChanges(songsValue));
    }else{
      deckItemState["sort"].activeNature=nature;
      deckItemState["sort"].isActive=true;
      List<Tune> songsValue = musicService.songs$.value;
      currentSongs.add(applyDeckItemChanges(songsValue));
    }

    saveTrackListDeckSettingsToDisk();
  }


  Future<void> toggleApplyFiltering(String nature) async{
    if(deckItemState["filter"].isActive && deckItemState["filter"].activeNature==nature){
      deckItemState["filter"].activeNature=null;
      deckItemState["filter"].isActive=false;
      List<Tune> songsValue = musicService.songs$.value;
      currentSongs.add(applyDeckItemChanges(songsValue));
    }else{
      switch(nature){
        case "keyword":{
          String returnedKeyword = await openFilteringKeywordDialog();
          if(returnedKeyword!=null){
            deckItemState["filter"].activeNature=nature;
            deckItemState["filter"].isActive=true;
            deckItemState["filter"].natureKey=returnedKeyword;
            List<Tune> songsValue = musicService.songs$.value;
            currentSongs.add(applyDeckItemChanges(songsValue));
          }
          break;
        }
        case "album":{
          List<Album> albumsToFilterWith = await openFilteringAlbumDialog(null);
          if(albumsToFilterWith!=null){
            deckItemState["filter"].activeNature=nature;
            deckItemState["filter"].isActive=true;
            deckItemState["filter"].natureKey=albumsToFilterWith.map((elem){
              return elem.title;
            }).toList().join(",");
            List<Tune> songsValue = musicService.songs$.value;
            currentSongs.add(applyDeckItemChanges(songsValue));
          }

          break;
        }
        case "artist":{
          List<Artist> artistsToFilterWith = await openFilteringArtistDialog(null);
          if(artistsToFilterWith!=null){
            deckItemState["filter"].activeNature=nature;
            deckItemState["filter"].isActive=true;
            deckItemState["filter"].natureKey=artistsToFilterWith.map((elem){
              return elem.name;
            }).toList().join(",");
            List<Tune> songsValue = musicService.songs$.value;
            currentSongs.add(applyDeckItemChanges(songsValue));
          }
        }
      }

    }

    saveTrackListDeckSettingsToDisk();
    return ;
  }

  Future<void> toggleCasting() async{


    if(deckItemState["cast"].isActive && castService.currentDeviceToBeUsed.value!=null && castService.castingState.value==CastState.CASTING){
      bool result = await DialogService.showConfirmDialog(context,
        title: "Stop the current Cast",
        message: "This will abandon the control of the cast and stop it completely",
        confirmButtonText: "Stop Cast",
        cancelButtonText: "Kepp cast active",
        titleColor: MyTheme.grey300
      );
      if(result!=null && result==true){
        castService.stopCasting();
        musicService.initializePlayStreams();
        deckItemState["cast"].isActive=false;
      }
    }else{
      upnp.Device registeredDevice = castService.currentDeviceToBeUsed.value;
      if(registeredDevice!=null){
        //This means that a device is already registered and has been found, So we need to try and connect
        // to that device and see if it is already up or not
        RequestSettings.pingURL(registeredDevice.url, timeout: Duration(seconds: 2)).then((value) async{
          if(value==null){
            throw "pingFailed";
          }
          musicService.stopMusic();
          castService.setCastingState(CastState.CASTING);
          deckItemState["cast"].isActive=true;
          musicService.reInitializePlayStreams();

        }).catchError((err)async{
          upnp.Device selectedDevice = await DialogService.openDevicePickingDialog(context,null);
          if(selectedDevice!=null){
            castService.setDeviceToBeUsed(selectedDevice);
            musicService.stopMusic();
            castService.setCastingState(CastState.CASTING);
            deckItemState["cast"].isActive=true;
            musicService.reInitializePlayStreams();
          }
        });
      }else{
        //If there is no device registered so we need to search for devices and show a dialog for the user to pick from
        upnp.Device selectedDevice = await DialogService.openDevicePickingDialog(context,null);
        if(selectedDevice!=null){
          castService.setDeviceToBeUsed(selectedDevice);
          musicService.stopMusic();
          castService.setCastingState(CastState.CASTING);
          deckItemState["cast"].isActive=true;
          musicService.reInitializePlayStreams();
        }
      }
    }
    saveTrackListDeckSettingsToDisk();
    return;
  }

  List<Tune> applyDeckItemChanges(List<Tune> songs){
    List<Tune> songsValue = songs??List.from(currentSongs.value);
    if(deckItemState==null){
      return songsValue;
    }


    if(deckItemState["shuffle"].isActive){
      switch(deckItemState["shuffle"].activeNature){
        case "auto":{
          songsValue.shuffle();

          break;
        }
        case "artist":{

          break;
        }
        default:{
          break;
        }
      }
    }


    if(deckItemState["sort"].isActive){
      switch(deckItemState["sort"].activeNature){
        case "asc":{
          songsValue.sort((a, b) {
            return a.title
                .toLowerCase()
                .compareTo(b.title.toLowerCase());
          });
          break;
        }
        case "desc":{
          songsValue.sort((a, b) {
            return b.title
                .toLowerCase()
                .compareTo(a.title.toLowerCase());
          });
          break;
        }
        default:{
          break;
        }
      }
    }

    if(deckItemState["filter"].isActive){
      switch(deckItemState["filter"].activeNature){
        case "keyword":{
          if(deckItemState["filter"].natureKey!=null){
            String key = deckItemState["filter"].natureKey;
            songsValue= songsValue.where((elem){
              return ((elem.title!=null && elem.title.toLowerCase().contains(key))
                  || (elem.album != null && elem.album.toLowerCase().contains(key))
                  || (elem.artist != null && elem.artist.toLowerCase().contains(key)));
            }).toList();
          }
          break;
        }
        case "artist":{
          String key = deckItemState["filter"].natureKey;
          List<String> keyList = key.split(",");

          songsValue= songsValue.where((elem){
            return ((keyList.indexWhere((artistTitle){
              return artistTitle==elem.artist;
            }))!=-1);
          }).toList();
          break;
        }
        case "album":{
          String key = deckItemState["filter"].natureKey;
          List<String> keyList = key.split(",");
          print(keyList);
          songsValue= songsValue.where((elem){
            return keyList.indexWhere((albumTitle){
              return albumTitle==elem.album;
            })!=-1;
          }).toList();
          break;
        }
        default:{
          break;
        }
      }
    }


    if(deckItemState["cast"].isActive){
      //Automatic casting is what is going to implemented there is no need to checking itemNature
      //The base idea here is :
      // Ensure that casting is not activated after reboot app

      if(castService.castingState.value==CastState.CASTING){
        castService.setCastingState(CastState.NOT_CASTING);
      }
      deckItemState["cast"].isActive=false;


    }else{
      //manually set the not casting state
      if(!(castService.castingState.value==CastState.NOT_CASTING)){
        castService.setCastingState(CastState.NOT_CASTING);
      }
    }

    return songsValue;
  }

  Future<String> openFilteringKeywordDialog(){
    String keyword="";
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Filtering keyword",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: TextField(
              onChanged: (string){
                keyword=string;
              },
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  hintText: "Type anything",
                  hintStyle: TextStyle(
                      color: MyTheme.grey500.withOpacity(0.2)
                  )
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Filter",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(keyword);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop())
            ],
          );
        });
  }
  Future<List<Album>> openFilteringAlbumDialog(List<Album> albums){
    albums=albums??musicService.albums$.value;
    List<Album> selectedAlbums=List<Album>();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Filtering Albums",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height/2.5,
              width: MediaQuery.of(context).size.width/1.2,
              child: GridView.builder(
                padding: EdgeInsets.all(3),
                itemBuilder: (context, index){
                  Album album = albums[index];
                  return SelectableTile(
                    imageUri: album.albumArt,
                    title: album.title,
                    isSelected: false,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      print("Selected ${album.title}");
                      if(willItBeSelected){
                        selectedAlbums.add(album);
                      }else{
                        selectedAlbums.removeAt(selectedAlbums.indexWhere((elem)=>elem.title==album.title));
                      }
                    },
                    placeHolderAssetUri: "images/cover.png",
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                  childAspectRatio: 3,
                ),
                semanticChildCount: albums.length,
                cacheExtent: 120,
                itemCount: albums.length,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Filter",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(selectedAlbums);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop())
            ],
          );
        });
  }
  Future<List<Artist>> openFilteringArtistDialog(List<Artist> artists){
    artists=artists??musicService.artists$.value;
    List<Artist> selectedArtists=List<Artist>();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Filtering Albums",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height/2.5,
              width: MediaQuery.of(context).size.width/1.2,
              child: GridView.builder(
                padding: EdgeInsets.all(3),
                itemBuilder: (context, index){
                  Artist artist = artists[index];
                  return SelectableTile(
                    imageUri: artist.coverArt,
                    title: artist.name,
                    isSelected: false,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      print("Selected ${artist.name}");
                      if(willItBeSelected){
                        selectedArtists.add(artist);
                      }else{
                        selectedArtists.removeAt(selectedArtists.indexWhere((elem)=>elem.name==artist.name));
                      }
                    },
                    placeHolderAssetUri: "images/artist.jpg",
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                  childAspectRatio: 3,
                ),
                semanticChildCount: artists.length,
                cacheExtent: 120,
                itemCount: artists.length,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Filter",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(selectedArtists);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop())
            ],
          );
        });
  }

}



