import 'dart:io';

import 'package:Tunein/components/cards/genericItem.dart';
import 'package:Tunein/components/itemListDevider.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicMetricsService.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

class MetricsPage extends StatelessWidget {


  final metricService = locator<MusicMetricsService>();
  final musicService = locator<MusicService>();
  ExpandableController  expandController = ExpandableController();

  Widget getDataByMetric(MetricIds id, dynamic value){
    switch(id){

      case MetricIds.MET_GLOBAL_PLAY_TIME:{
        Duration globalSongDuration = Duration(seconds: int.parse(value.toString()));
        return GenericItem(
          leading: Icon(
            Icons.timer,
            color: MyTheme.grey300,
          ),
          title: "Global time play",
          subTitle: "${ConversionUtils.DurationToFancyText(globalSongDuration)}",
        );
      }

      case MetricIds.MET_GLOBAL_SONG_PLAY_TIME:
        Map<String,dynamic> newValue = value;
        var sortedKeys = newValue.keys.toList(growable:false)
          ..sort((k1, k2) => int.parse(newValue[k2]).compareTo(int.parse(newValue[k1])));
        Map<String,String> sortedMap = new Map
            .fromIterable(sortedKeys, key: (k) => k, value: (k) => newValue[k]);

        Map<Tune,int> finalMap = sortedMap.map((key, value) {
          Tune newKey = musicService.songs$.value.firstWhere((element) => element.id==key, orElse: ()=>null);
          return MapEntry(newKey, int.tryParse(value));
        });
        List<Tune> finalMapSongs = finalMap.keys.toList();
        finalMapSongs.removeWhere((element) => element==null);
        ScrollController itemListController =ScrollController();
        ExpandableController  expandController = ExpandableController();
        bool previousState = false;
        expandController.addListener(() {
          if(previousState && !expandController.expanded){
            itemListController.jumpTo(0);
          }
          previousState=expandController.expanded;
        });
        return ExpandableNotifier(
          child: ScrollOnExpand(
            child: ExpandablePanel(
              header: GenericItem(
                leading: Icon(
                  Icons.queue_music,
                  color: MyTheme.grey300,
                ),
                title: "Global song time play",
                subTitle: "Tap to open",
              ),
              collapsed: Container(),
              expanded: Container(
                height: 200,
                padding: EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        controller: itemListController,
                        itemBuilder: (context, index){
                          Duration songDuration = Duration(seconds: finalMap[finalMapSongs[index]]);
                          return Material(
                              child: GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: GenericItem(
                                      height: 40,
                                      leading: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: FadeInImage(
                                          placeholder: AssetImage('images/track.png'),
                                          fadeInDuration: Duration(milliseconds: 200),
                                          fadeOutDuration: Duration(milliseconds: 100),
                                          image: finalMapSongs[index].albumArt != null
                                              ? FileImage(
                                            new File(finalMapSongs[index].albumArt),
                                          )
                                              : AssetImage('images/track.png'),
                                        ),
                                      ),
                                      title: "${finalMapSongs[index].title}",
                                      subTitle: "${ConversionUtils.DurationToFancyText(songDuration)}"
                                  ),
                                ),
                                onTap: (){

                                },
                              ),
                              color: Colors.transparent
                          );
                        },
                        scrollDirection: Axis.vertical,
                        itemCount: finalMapSongs.length,
                        shrinkWrap: false,
                        itemExtent: 62,
                        physics: AlwaysScrollableScrollPhysics(),
                        cacheExtent: 400,
                      ),
                    ),
                    MyScrollbar(
                      controller: itemListController,
                      color: null,
                      showFromTheStart:finalMap.length*62>200,
                    )
                  ],
                ),
              ),
              theme: ExpandableThemeData(
                animationDuration: Duration(milliseconds: 200),
                iconColor: MyTheme.darkRed,
                tapHeaderToExpand: true,
                iconSize: 35,
                iconPadding: EdgeInsets.all(8),
              ),
            ),
          ),
          controller: expandController,
        );
        break;
      case MetricIds.MET_GLOBAL_ARTIST_PLAY_TIME:
        Map<String,dynamic> newValue = value;
        var sortedKeys = newValue.keys.toList(growable:false)
          ..sort((k1, k2) => int.parse(newValue[k2]).compareTo(int.parse(newValue[k1])));
        Map<String,String> sortedMap = new Map
            .fromIterable(sortedKeys, key: (k) => k, value: (k) => newValue[k]);
        Map<Artist,int> finalMap = sortedMap.map((key, value) {
          Artist newKey = musicService.artists$.value.firstWhere((element) => element.id==int.parse(key), orElse: ()=>null);
          return MapEntry(newKey, int.tryParse(value));
        });
        List<Artist> finalMapArtists = finalMap.keys.toList();
        ScrollController itemListController =ScrollController();
        ExpandableController  expandController = ExpandableController();
        bool previousState = false;
        expandController.addListener(() {
          if(previousState && !expandController.expanded){
            itemListController.jumpTo(0);
          }
          previousState=expandController.expanded;
        });
        return ExpandableNotifier(
          child: ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: true,
            child: ExpandablePanel(
                header: GenericItem(
                  leading: Icon(
                    Icons.insert_chart,
                    color: MyTheme.grey300,
                  ),
                  title: "Global Artist time play",
                  subTitle: "Tap to open",
                ),
                collapsed: Container(),
                expanded: Container(
                  height: 200,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          controller: itemListController,
                          itemBuilder: (context, index){
                            Duration songDuration = Duration(seconds: finalMap[finalMapArtists[index]]);
                            return Material(
                                child: GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: GenericItem(
                                        leading: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: FadeInImage(
                                            placeholder: AssetImage('images/track.png'),
                                            fadeInDuration: Duration(milliseconds: 200),
                                            fadeOutDuration: Duration(milliseconds: 100),
                                            image: finalMapArtists[index].coverArt != null
                                                ? FileImage(
                                              new File(finalMapArtists[index].coverArt),
                                            )
                                                : AssetImage('images/track.png'),
                                          ),
                                        ),
                                        title: "${finalMapArtists[index].name}",
                                        subTitle: "${ConversionUtils.DurationToFancyText(songDuration)}"
                                    ),
                                  ),
                                  onTap: (){

                                  },
                                ),
                                color: Colors.transparent
                            );
                          },
                          scrollDirection: Axis.vertical,
                          itemCount: finalMap.length,
                          shrinkWrap: false,
                          itemExtent: 62,
                          physics: AlwaysScrollableScrollPhysics(),
                          cacheExtent: 400,
                        ),
                      ),
                      MyScrollbar(
                        controller: itemListController,
                        color: null,
                        showFromTheStart:finalMap.length*62>200,
                      )
                    ],
                  ),
                ),
                theme: ExpandableThemeData(
                  animationDuration: Duration(milliseconds: 200),
                  iconColor: MyTheme.darkRed,
                  tapHeaderToExpand: true,
                  iconSize: 35,
                  iconPadding: EdgeInsets.all(8),
                )
            ),
          ),
          controller: expandController,
        );
        break;
      case MetricIds.MET_GLOBAL_LAST_PLAYED_SONGS:
        // TODO: Handle this case.
      return Container();
        break;
      case MetricIds.MET_GLOBAL_LAST_PLAYED_PLAYLIST:
        // TODO: Handle this case.
        break;
      case MetricIds.MET_GLOBAL_PLAYLIST_PLAY_TIME:
        // TODO: Handle this case.
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    return Container(
      color: MyTheme.darkBlack,
      height: MediaQuery.of(context).size.height -160,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: MediaQuery.of(context).padding,
          ),
          Flexible(
            child: CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ItemListDevider(DeviderTitle: "Playing Metrics",
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Material(
                              child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: StreamBuilder(
                                    stream: metricService.getOrCreateSingleSettingStream(MetricIds.MET_GLOBAL_PLAY_TIME),
                                    builder: (context, AsyncSnapshot<dynamic> snapshot){
                                      Widget widgetToBe = Container(child: GenericItem(title: "LOADING", subTitle: "",),);
                                      if(snapshot.hasData){
                                        widgetToBe = getDataByMetric(MetricIds.MET_GLOBAL_PLAY_TIME, snapshot.data);
                                      }
                                      return widgetToBe;
                                    },
                                  )
                              ),
                              color: Colors.transparent
                          ),
                        ),
                        Flexible(
                          child: Material(
                              child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: StreamBuilder(
                                    stream: metricService.getOrCreateSingleSettingStream(MetricIds.MET_GLOBAL_SONG_PLAY_TIME),
                                    builder: (context, AsyncSnapshot<dynamic> snapshot){
                                      Widget widgetToBe = Container(child: GenericItem(title: "LOADING", subTitle: "",),);
                                      if(snapshot.hasData){
                                        widgetToBe = getDataByMetric(MetricIds.MET_GLOBAL_SONG_PLAY_TIME, snapshot.data);
                                      }
                                      return widgetToBe;
                                    },
                                  )
                              ),
                              color: Colors.transparent
                          ),
                        ),
                        Flexible(
                          child: Material(
                              child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: StreamBuilder(
                                    stream: metricService.getOrCreateSingleSettingStream(MetricIds.MET_GLOBAL_ARTIST_PLAY_TIME),
                                    builder: (context, AsyncSnapshot<dynamic> snapshot){
                                      Widget widgetToBe = Container(child: GenericItem(title: "LOADING", subTitle: "",),);
                                      if(snapshot.hasData){
                                        widgetToBe = getDataByMetric(MetricIds.MET_GLOBAL_ARTIST_PLAY_TIME, snapshot.data);
                                      }
                                      return widgetToBe;
                                    },
                                  )
                              ),
                              color: Colors.transparent
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
