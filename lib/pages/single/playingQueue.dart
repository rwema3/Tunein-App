import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/albumSongList.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/songInfoWidget.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/routes/pageRoutes.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Tunein/models/playback.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:Tunein/components/smallControlls.dart';
import 'package:upnp/upnp.dart' as upnp;

class playingQueue extends StatefulWidget {
  @override
  _playingQueueState createState() => _playingQueueState();
}

class _playingQueueState extends State<playingQueue> with AutomaticKeepAliveClientMixin<playingQueue> {

  final musicService = locator<MusicService>();
  final castService = locator<CastService>();
  final themeService = locator<ThemeService>();
  StreamSubscription<MapEntry<PlayerState, Tune>> scrollAnimationListener;
  ScrollController controller;
  List<Tune> songs;
  MapEntry<List<Playback>, MapEntry<List<Tune>,List<Tune>>> tempState;
  BehaviorSubject<MapEntry<List<Playback>, MapEntry<List<Tune>,List<Tune>>>> newStream = new BehaviorSubject<MapEntry<List<Playback>, MapEntry<List<Tune>,List<Tune>>>>();
  Timer isScheduelingtoPushData;

  @override
  void initState() {
    controller = ScrollController();

    Stream<MapEntry<List<Playback>, MapEntry<List<Tune>,List<Tune>>>>  originalStream = Rx.combineLatest2(
      musicService.playback$,
      musicService.playlist$,
          (a, b) => MapEntry(a, b),
    );

    //
    layoutService.onPanelOpenCallback= (){
      if(tempState!=null){
        newStream.add(tempState);
        tempState=null;
      }
    };
    //
    originalStream.listen((Data){
      if(!layoutService.globalPanelController.isPanelClosed()){
        newStream.add(Data);
      }else{
        tempState=Data;
        if(isScheduelingtoPushData==null){
          isScheduelingtoPushData = Timer(Duration(milliseconds: 4000),(){
            if(tempState!=null){
              newStream.add(tempState);
              tempState=null;
            }
            isScheduelingtoPushData=null;
          });
        }else{
          isScheduelingtoPushData.cancel();
          isScheduelingtoPushData = Timer(Duration(milliseconds: 4000),(){
            if(tempState!=null){
              newStream.add(tempState);
              tempState=null;
            }
            isScheduelingtoPushData=null;
          });
        }
      }
    });


    super.initState();
  }


  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void dispose() {
    //This does create an error in case the controller is already disposed off automatically via the wantKeepAlive returning false
    //controller.dispose();
    scrollAnimationListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screensize = MediaQuery.of(context).size;
    Timer currentDelayedAnimate;
    double getSongPosition(int indexOfThePlayingSong,double numberOfSongsPerScreen){
      double finalNumber =((((indexOfThePlayingSong)/numberOfSongsPerScreen) - ((indexOfThePlayingSong)/numberOfSongsPerScreen).floor()));
      if(finalNumber.abs() <numberOfSongsPerScreen/2){
        return -((numberOfSongsPerScreen/2) - finalNumber)*62;
      }else{
        return (finalNumber - (numberOfSongsPerScreen/2))*62;
      }
    }

    Future<bool> animate(int indexOfThePlayingSong, double numberOfSongsPerScreen) async{
      if(this.controller.hasClients){
        print("will animate");
        await this.controller.animateTo(((indexOfThePlayingSong+1)*62)+getSongPosition(indexOfThePlayingSong,numberOfSongsPerScreen),duration: Duration(
            milliseconds: (pow(log((indexOfThePlayingSong>0?indexOfThePlayingSong:1)*2), 2)).floor() + 50
        ),
            curve: Curves.fastOutSlowIn
        );
        return true;
      }else {
        print("controller has no clients #2");
        return false;
      }
    }


    WidgetsBinding.instance.addPostFrameCallback((duration){
      double numberOfSongsPerScreen =((screensize.height-160)/62);
      scrollAnimationListener = musicService.playerState$.listen((MapEntry<PlayerState, Tune> value) async{
        if(value!=null && songs!=null){
          int indexOfThePlayingSong =songs.indexWhere((elem)=>elem.id==value.value.id);
          if(indexOfThePlayingSong>0){
            bool didanimate = await animate(indexOfThePlayingSong,numberOfSongsPerScreen);
            if(didanimate==true){
              currentDelayedAnimate?.cancel();
              currentDelayedAnimate=null;
              return;
            }
          }
        }
      });
    });


    return StreamBuilder<MapEntry<List<Playback>,MapEntry<List<Tune>,List<Tune>>>>(
      stream: newStream,
      builder: (BuildContext context, AsyncSnapshot<MapEntry<List<Playback>,MapEntry<List<Tune>,List<Tune>>>> snapshot){

        if(!snapshot.hasData){
          return Container(
            color: MyTheme.bgBottomBar,
          );
        }

        final bool _isShuffle = snapshot.data.key.contains(Playback.shuffle);
        final List<Tune> _playlist =
        _isShuffle ? snapshot.data.value.value : snapshot.data.value.key;
        songs=_playlist;

        return StreamBuilder(
          stream: musicService.playerState$,
          builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshotOne){
            if(!snapshotOne.hasData ){
              return Container();
            }

            Tune _currentSong = snapshotOne.data.value;
            PlayerState _state = snapshotOne.data.key;
            return StreamBuilder(
              stream:  themeService.getThemeColors(_currentSong!=null?_currentSong:null).asStream(),
              builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
                List<int> bgColor;
                if(!snapshot.hasData || snapshot.data.length==0){
                  return Container(
                    color: MyTheme.bgBottomBar,
                  );
                }

                bgColor=snapshot.data;

                return Container(

                  color: bgColor!=null?Color(bgColor[0]):MyTheme.darkBlack,

                  child: new Column(
                    children: <Widget>[
                      Material(
                        child: AnimatedContainer(
                          duration: Duration(
                              milliseconds: 500
                          ),
                          curve: Curves.fastOutSlowIn,
                          child: new Container(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: FadeInImage(
                                      placeholder: AssetImage('images/track.png'),
                                      fadeInDuration: Duration(milliseconds: 200),
                                      fadeOutDuration: Duration(milliseconds: 100),
                                      image: _currentSong.albumArt != null
                                          ? FileImage(
                                        new File(_currentSong.albumArt),
                                      )
                                          : AssetImage('images/track.png'),
                                    ),
                                  ),
                                  flex: 4,
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8))
                                        .add(EdgeInsets.only(top: (_currentSong.title != null && _currentSong.title.length>27)?_currentSong.title.length/(_currentSong.title.length-12):10)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            (_currentSong.title == null)
                                                ? "Unknon Title"
                                                : _currentSong.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            strutStyle: StrutStyle(
                                              height: 1.4,
                                              forceStrutHeight:true
                                            ),
                                            style: TextStyle(
                                              fontSize: 17.5,
                                              fontWeight: FontWeight.w700,
                                              color: bgColor!=null?Color(bgColor[2]).withAlpha(200):Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          (_currentSong.artist == null)
                                              ? "Unknown Artist"
                                              : _currentSong.artist,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w400,
                                            color: bgColor!=null?Color(bgColor[2]):Colors.white,
                                          ),
                                        ),
                                        /*Container(
                                      alignment: Alignment.bottomRight,
                                      margin: EdgeInsets.all(5)
                                          .add(EdgeInsets.only(top: 2)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Text(
                                              album.songs.length.toString(),
                                              style: TextStyle(
                                                color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.audiotrack,
                                            color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                          )
                                        ],
                                      ),
                                    ),*/
                                        Container(
                                          alignment: Alignment.bottomRight,
                                          margin: EdgeInsets.all(5).subtract(EdgeInsets.only(bottom: (_currentSong.title != null && _currentSong.title.length>20)?3:0)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  "${Duration(milliseconds: _currentSong.duration).inMinutes} min",
                                                  style: TextStyle(
                                                    color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                margin: EdgeInsets.only(right: 5),
                                              ),
                                              Icon(
                                                Icons.access_time,
                                                color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                              )
                                            ],
                                          ),
                                        ),
                                        MusicBoardControls(bgColor, currentSong: _currentSong,state: _state,)
                                      ],
                                    ),
                                    padding: EdgeInsets.all(7),
                                    alignment: Alignment.topCenter,
                                  ),
                                )
                              ],
                            ),
                          ),
                          height: 200,

                          ///The color here is necessary due to the FadingEdgeScrollView component that needs real contrast in order to display the fading effect
                            ///the animated container on instead of a container for some reason breaks that contrast. In order to use the animated container in the top part of
                            ///the page we had to add it only on that part inside the Material widget. to work this animated container needs a  color attribute thus the duplication between the
                            ///global container and this animated container.
                          color: bgColor!=null?Color(bgColor[0]):MyTheme.darkBlack
                        ),
                          color: Colors.transparent
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: FadingEdgeScrollView.fromScrollView(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(0).add(EdgeInsets.only(
                                        left:10
                                    )),
                                    controller: controller,
                                    cacheExtent: 10,
                                    shrinkWrap: true,
                                    itemExtent: 62,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: _playlist.length,
                                    itemBuilder: (context, index) {
                                      int newIndex = index;
                                      return MyCard(
                                        choices: songCardContextMenulist,
                                        ScreenSize: screensize,
                                        StaticContextMenuFromBottom: 0.0,
                                        onContextSelect: (choice) async{
                                          switch(choice.id){
                                            case 1: {
                                              musicService.playOne(_playlist[newIndex]);
                                              break;
                                            }
                                            case 2:{
                                              musicService.startWithAndShuffleQueue(_playlist[newIndex], _playlist);
                                              break;
                                            }
                                            case 3:{
                                              musicService.startWithAndShuffleAlbum(_playlist[newIndex]);
                                              break;
                                            }
                                            case 4:{
                                              musicService.playAlbum(_playlist[newIndex]);
                                              break;
                                            }
                                            case 5:{
                                              if(castService.currentDeviceToBeUsed.value==null){
                                                upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                                if(result!=null){
                                                  castService.setDeviceToBeUsed(result);
                                                }
                                              }
                                              musicService.castOrPlay(_playlist[newIndex], SingleCast: true);
                                              break;
                                            }
                                            case 6:{
                                              upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                              if(result!=null){
                                                musicService.castOrPlay(_playlist[newIndex], SingleCast: true, device: result);
                                              }
                                              break;
                                            }
                                            case 7: {
                                              DialogService.showAlertDialog(context,
                                                  title: "Song Information",
                                                  content: SongInfoWidget(null, song: _playlist[newIndex]),
                                                  padding: EdgeInsets.only(top: 10)
                                              );
                                              break;
                                            }
                                            case 8:{
                                              PageRoutes.goToAlbumSongsList(_playlist[newIndex], context);
                                              break;
                                            }
                                            case 9:{
                                              PageRoutes.goToSingleArtistPage(_playlist[newIndex], context);
                                              break;
                                            }
                                            case 10:{
                                              PageRoutes.goToEditTagsPage(_playlist[newIndex], context, subtract60ForBottomBar: true);
                                              break;
                                            }
                                          }
                                        },
                                        onContextCancel: (choice){
                                          print("Cancelled");
                                        },
                                        song: _playlist[newIndex],
                                        colors: bgColor!=null?[Color(bgColor[0]),Color(bgColor[1])]:null,
                                        onTap: (){
                                          musicService.playOrPause(_playlist[newIndex]);
                                        },
                                      );
                                    },
                                  ),
                                  gradientFractionOnStart: 0.2 ,
                                  gradientFractionOnEnd: 0.0,
                                ),
                              ),
                              MyScrollbar(
                                controller: controller,
                                color: bgColor!=null?Color(bgColor[0]):null,
                              ),
                            ],
                          ),
                          ///The color here is necessary for the
                          color: bgColor!=null?Color(bgColor[0]):MyTheme.darkBlack,
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );




      },
    );
  }
}
