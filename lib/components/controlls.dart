import 'package:Tunein/components/trackListDeckItem.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playback.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rxdart/rxdart.dart';
import 'package:upnp/upnp.dart' as upnp;

class MusicBoardControls extends StatelessWidget {
  final List<int> colors;
  PlayerState state;
  Tune currentSong;
  PlayerState localState;
  BehaviorSubject<bool> flashCastIconStream ;
  GlobalKey playButtonKey;
  MusicBoardControls(this.colors,{this.state, this.currentSong}){
   this.localState=this.state;
   flashCastIconStream= BehaviorSubject<bool>.seeded(false);
   playButtonKey=GlobalKey();
  }


  Widget playPauseButton(MusicService musicService){

    return StreamBuilder<
        MapEntry<PlayerState, Tune>>(
      stream: musicService.playerState$,
      builder: (BuildContext context,
          AsyncSnapshot<
              MapEntry<PlayerState, Tune>>
          snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final _state = snapshot.data.key;
        final _currentSong = snapshot.data.value;

        return InkWell(
            onTap: () {
              if (_currentSong.uri == null) {
                return;
              }
              if (PlayerState.paused == _state) {
                musicService.playMusic(_currentSong);
              } else {
                musicService.pauseMusic(_currentSong);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    color: new Color(colors[1]).withOpacity(.7),
                    borderRadius: BorderRadius.circular(30)),
                height: 60,
                width: 60,
                child: Center(
                  child: AnimatedCrossFade(
                    duration: Duration(milliseconds: 200),
                    crossFadeState: _state == PlayerState.playing
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Icon(
                      Icons.pause,
                      color: Color(colors[0]),
                      size: 30,
                    ),
                    secondChild: Icon(
                      Icons.play_arrow,
                      color: Color(colors[0]),
                      size: 30,
                    ),
                  ),
                )
            )
        );
      },
    );

  }



  @override
  Widget build(BuildContext context) {
    final musicService = locator<MusicService>();
    final castService = locator<CastService>();
    PopupMenu castMenu = PopupMenu(
        backgroundColor: MyTheme.darkRed,
        lineColor: Colors.transparent,
        maxColumn: 2,
        context: context,
        items: [
          MenuItem(
              title: 'Stop',
              textStyle: TextStyle(
                  fontSize: 10.0,
                  color: MyTheme.darkBlack
              ),
              image: Icon(
                  IconData(0xf28d,fontFamily: "fontawesome"),
                  size: 27,
                  color: MyTheme.darkBlack
              )
          ),
          MenuItem(
              title: 'Search',
              textStyle: TextStyle(
                  fontSize: 10.0,
                  color: MyTheme.darkBlack
              ),
              image: Icon(
                  Icons.refresh,
                  size: 30,
                  color: MyTheme.darkBlack
              )
          ),
        ],
        onClickMenu: (provider) async{
          print("provider got is : ${provider}");
          flashCastIconStream.add(true);
          switch(provider.menuTitle){
            case "Search":{
              DialogService.openDevicePickingDialog(context,null).then(
                      (data){
                    upnp.Device deviceChosen = data;
                    if(deviceChosen!=null){
                      castService.isDeviceClear(awaitClearance: true).then((data)async{
                        if(data){
                          await castService.stopCasting();
                          castService.setDeviceToBeUsed(deviceChosen);
                          castService.setCastingState(CastState.CASTING);
                          flashCastIconStream.add(false);
                        }
                      });
                    }
                  }
              );
              break;
            }

            case "Stop":{
              bool result = await DialogService.showConfirmDialog(context,
                  title: "Stop the current Cast",
                  message: "This will abandon the control of the cast and stop it completely",
                  confirmButtonText: "Stop Cast",
                  cancelButtonText: "Kepp cast active",
                  titleColor: MyTheme.grey300
              );
              if(result!=null && result==true){
                castService.isDeviceClear(awaitClearance: true).then((data){
                  if(data){
                    castService.stopCasting();
                    musicService.initializePlayStreams();
                  }
                });

              }
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
    if(state!=localState)localState=state;
    return Material(
      color: Colors.transparent,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          width: double.infinity,
          child: (this.state ==null || this.currentSong==null)?Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                splashColor: Color(colors[1]),
                padding: EdgeInsets.all(5),
                  icon: StreamBuilder(
                    stream: musicService.playback$,
                    builder: (context, AsyncSnapshot<List<Playback>> snapshot){
                      Color iconColor= new Color(colors[1]).withOpacity(.5);
                      IconData iconToBe = Icons.repeat;
                      if(snapshot.hasData){
                        bool isSongRepeat = snapshot.data.contains(Playback.repeatSong);
                        bool isQueueRepeat = snapshot.data.contains(Playback.repeatQueue);
                        if(isQueueRepeat || isSongRepeat){
                          iconColor= MyTheme.darkRed;
                          if(isSongRepeat){
                            iconToBe= Icons.repeat_one;
                          }
                          if(isQueueRepeat){
                            //This is redundant for future changes
                            iconToBe= Icons.repeat;
                          }
                        }
                      }
                      return Icon(
                        iconToBe,
                        color: iconColor,
                        size: 25,
                      );
                    },
                  ),
                  onPressed: () {
                    musicService.cycleBetweenPlaybackStates();
                  }
              ),
              IconButton(
                splashColor: Color(colors[1]),
                icon: Icon(
                  IconData(0xeb40, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 35,
                ),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 200),(){
                    musicService.playPreviousSong();
                  });
                },
              ),
              GestureDetector(
                onLongPress: (){
                  if(castService.castingState.value==CastState.CASTING){
                    if(castMenu.isShow){
                      castMenu.dismiss();
                    }else{
                      castMenu.show(
                          widgetKey:playButtonKey
                      );
                    }
                  }
                },
                child: IconButton(
                  splashColor: Color(colors[1]),
                    key: playButtonKey,
                    iconSize: 50,
                    onPressed: () {
                      if (currentSong.uri == null) {
                        return;
                      }
                      Future.delayed(Duration(milliseconds: 200),(){
                        if (PlayerState.paused == state) {
                          this.localState==PlayerState.playing;
                          musicService.playMusic(currentSong);
                        } else {
                          this.localState=PlayerState.paused;
                          musicService.pauseMusic(currentSong);
                        }
                      });
                    },
                    icon: StreamBuilder(
                      stream: castService.castingState,
                      builder: (context, AsyncSnapshot<CastState> snapshot){
                        bool isCasting=false;
                        if(snapshot.hasData){
                          isCasting = snapshot.data==CastState.CASTING;
                        }
                        return Badge(
                          badgeContent: StreamBuilder(
                            stream: flashCastIconStream,
                            builder: (context, AsyncSnapshot<bool> snapshot){
                              bool doFlash=false;
                              if(snapshot.hasData){
                                doFlash= snapshot.data;
                              }
                              return FlashingBadgeIcon(
                                child: Icons.cast_connected,
                                IconSize: 21,
                                colors: [MyTheme.grey300, MyTheme.darkRed],
                                flash: doFlash,
                                nonFlashingColor: MyTheme.darkRed,
                              );
                            },
                          ),
                          showBadge: isCasting,
                          elevation: 0,
                          child: Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                  color: new Color(colors[1]).withOpacity(.7),
                                  borderRadius: BorderRadius.circular(30)),
                              height: 60,
                              width: 60,
                              child: Center(
                                child: AnimatedCrossFade(
                                  duration: Duration(milliseconds: 200),
                                  crossFadeState: localState == PlayerState.playing
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: Icon(
                                    Icons.pause,
                                    color: Color(colors[0]),
                                    size: 30,
                                  ),
                                  secondChild: Icon(
                                    Icons.play_arrow,
                                    color: Color(colors[0]),
                                    size: 30,
                                  ),
                                ),
                              )),
                          badgeColor:Color(colors[0]),
                        );
                      },
                    )
                ),
              ),
              IconButton(
                splashColor: Color(colors[1]),
                icon: Icon(
                  IconData(0xeb3f, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 35,
                ),
                onPressed: (){
                  Future.delayed(Duration(milliseconds: 200),(){
                    musicService.playNextSong();
                  });
                },
              ),
              IconButton(
                splashColor: Color(colors[1]),
                  icon: StreamBuilder(
                    stream: musicService.playback$,
                    builder: (context, AsyncSnapshot<List<Playback>> snapshot){
                      Color iconColor= new Color(colors[1]).withOpacity(.5);
                      if(snapshot.hasData && snapshot.data.contains(Playback.shuffle)){
                        iconColor= MyTheme.darkRed;
                      }
                      return Icon(
                        Icons.shuffle,
                        color: iconColor,
                        size: 25,
                      );
                    },
                  ),
                  onPressed: () {
                    musicService.updatePlayback(Playback.shuffle,removeIfExistent: true);
                  }
              ),
            ],
          ):Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                splashColor: Color(colors[1]),
                padding: EdgeInsets.all(5),
                  icon: StreamBuilder(
                    stream: musicService.playback$,
                    builder: (context, AsyncSnapshot<List<Playback>> snapshot){
                      Color iconColor= new Color(colors[1]).withOpacity(.5);
                      IconData iconToBe = Icons.repeat;
                      if(snapshot.hasData){
                        bool isSongRepeat = snapshot.data.contains(Playback.repeatSong);
                        bool isQueueRepeat = snapshot.data.contains(Playback.repeatQueue);
                        if(isQueueRepeat || isSongRepeat){
                          iconColor= MyTheme.darkRed;
                          if(isSongRepeat){
                            iconToBe= Icons.repeat_one;
                          }
                          if(isQueueRepeat){
                            //This is redundant for future changes
                            iconToBe= Icons.repeat;
                          }
                        }
                      }
                      return Icon(
                        iconToBe,
                        color: iconColor,
                        size: 25,
                      );
                    },
                  ),

                  onPressed: () {
                    musicService.cycleBetweenPlaybackStates();
                  }
              ),
              IconButton(
                splashColor: Color(colors[1]),
                icon: Icon(
                  IconData(0xeb40, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 35,
                ),
                onPressed: (){
                  Future.delayed(Duration(milliseconds: 200),(){
                    musicService.playPreviousSong();
                  });
                },
              ),
              GestureDetector(
                onLongPress: (){
                  if(castService.castingState.value==CastState.CASTING){
                    if(castMenu.isShow){
                      castMenu.dismiss();
                    }else{
                      castMenu.show(
                          widgetKey:playButtonKey
                      );
                    }
                  }
                },
                child: IconButton(
                  splashColor: Color(colors[1]),
                    key: playButtonKey,
                    iconSize: 50,
                    onPressed: () {
                      if (currentSong.uri == null) {
                        return;
                      }
                      Future.delayed(Duration(milliseconds: 200),(){
                        if (PlayerState.paused == state) {
                          this.localState==PlayerState.playing;
                          musicService.playMusic(currentSong);
                        } else {
                          this.localState=PlayerState.paused;
                          musicService.pauseMusic(currentSong);
                        }
                      });

                    },
                    icon: StreamBuilder(
                      stream: castService.castingState,
                      builder: (context, AsyncSnapshot<CastState> snapshot){
                        bool isCasting=false;
                        if(snapshot.hasData){
                          isCasting = snapshot.data==CastState.CASTING;
                        }
                        return Badge(
                          badgeContent: StreamBuilder(
                            stream: flashCastIconStream,
                            builder: (context, AsyncSnapshot<bool> snapshot){
                              bool doFlash=false;
                              if(snapshot.hasData){
                                doFlash= snapshot.data;
                              }
                              return FlashingBadgeIcon(
                                child: Icons.cast_connected,
                                IconSize: 21,
                                colors: [MyTheme.grey300, MyTheme.darkRed],
                                nonFlashingColor: MyTheme.darkRed,
                                flash: doFlash,
                              );
                            },
                          ),
                          showBadge: isCasting,
                          elevation: 0,
                          child: Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                  color: new Color(colors[1]).withOpacity(.7),
                                  borderRadius: BorderRadius.circular(30)),
                              height: 60,
                              width: 60,
                              child: Center(
                                child: AnimatedCrossFade(
                                  duration: Duration(milliseconds: 200),
                                  crossFadeState: localState == PlayerState.playing
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: Icon(
                                    Icons.pause,
                                    color: Color(colors[0]),
                                    size: 30,
                                  ),
                                  secondChild: Icon(
                                    Icons.play_arrow,
                                    color: Color(colors[0]),
                                    size: 30,
                                  ),
                                ),
                              )),
                          badgeColor:Color(colors[0]),
                        );
                      },
                    )
                ),
              ),
              IconButton(
                splashColor: Color(colors[1]),
                icon: Icon(
                  IconData(0xeb3f, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 35,
                ),
                onPressed: () {
                    Future.delayed(Duration(milliseconds: 200),(){
                        musicService.playNextSong();
                    });
                  },
              ),
              IconButton(
                splashColor: Color(colors[1]),
                  icon: StreamBuilder(
                    stream: musicService.playback$,
                    builder: (context, AsyncSnapshot<List<Playback>> snapshot){
                      Color iconColor= new Color(colors[1]).withOpacity(.5);
                      if(snapshot.hasData && snapshot.data.contains(Playback.shuffle)){
                        iconColor= MyTheme.darkRed;
                      }
                      return Icon(
                        Icons.shuffle,
                        color: iconColor,
                        size: 25,
                      );
                    },
                  ),
                  onPressed: () {
                    musicService.updatePlayback(Playback.shuffle,removeIfExistent: true);
                  }
              ),
            ],
          )
      ),
    );
  }
}
