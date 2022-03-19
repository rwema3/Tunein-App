import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playback.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:rxdart/rxdart.dart';

class MusicBoardControls extends StatelessWidget {
  final List<int> colors;
  PlayerState state;
  Tune currentSong;
  PlayerState localState;
  MusicBoardControls(this.colors,{this.state, this.currentSong}){
    this.localState=this.state;
  }
  @override
  Widget build(BuildContext context) {
    final musicService = locator<MusicService>();

    return Material(
      color: Colors.transparent,
      child: Container(
          width: double.infinity,
          child: (this.state ==null || this.currentSong==null)?StreamBuilder<
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

              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  IconButton(
                    padding: EdgeInsets.all(2),
                    icon: Icon(
                      IconData(0xeb40, fontFamily: 'boxicons'),
                      color: new Color(colors[1]).withOpacity(.7),
                      size: 20,
                    ),
                    onPressed: () => musicService.playPreviousSong(),
                  ),
                  IconButton(
                      onPressed: () {
                        if (_currentSong.uri == null) {
                          return;
                        }
                        if (PlayerState.paused == _state) {
                          musicService.playMusic(_currentSong);
                        } else {
                          musicService.pauseMusic(_currentSong);
                        }
                      },
                      icon: Container(
                          decoration: BoxDecoration(
                              color: new Color(colors[1]).withOpacity(.7),
                              borderRadius: BorderRadius.circular(30)),
                          height: 30,
                          width: 30,
                          child: Center(
                            child: AnimatedCrossFade(
                              duration: Duration(milliseconds: 200),
                              crossFadeState: _state == PlayerState.playing
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Icon(
                                Icons.pause,
                                color: Color(colors[0]),
                                size: 20,
                              ),
                              secondChild: Icon(
                                Icons.play_arrow,
                                color: Color(colors[0]),
                                size: 20,
                              ),
                            ),
                          ))),
                  IconButton(
                    icon:Icon(
                      IconData(0xeb3f, fontFamily: 'boxicons'),
                      color: new Color(colors[1]).withOpacity(.7),
                      size: 20,
                    ),
                    onPressed: () => musicService.playNextSong(),
                  ),
                  IconButton(
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
                            size: 15,
                          );
                        },
                      ),

                      onPressed: () {
                        musicService.cycleBetweenPlaybackStates();
                      }
                  ),
                  /*IconButton(
                      icon:Icon(
                        Icons.shuffle,
                        color: new Color(colors[1]).withOpacity(.5),
                        size: 15,
                      ),
                      onPressed: () {

                      }
                  ),*/

                ],
              );
            },
          ):Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.all(0),
                icon:Icon(
                  IconData(0xeb40, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 25,
                ),
                onPressed: () => musicService.playPreviousSong(),
              ),
              IconButton(
                  onPressed: () {
                    if (currentSong.uri == null) {
                      return;
                    }
                    if (PlayerState.paused == state) {
                      musicService.playMusic(currentSong);
                    } else {
                      musicService.pauseMusic(currentSong);
                    }
                  },
                  icon: Container(
                      decoration: BoxDecoration(
                          color: new Color(colors[1]).withOpacity(.7),
                          borderRadius: BorderRadius.circular(30)),
                      height: 30,
                      width: 30,
                      child: Center(
                        child: AnimatedCrossFade(
                          duration: Duration(milliseconds: 200),
                          crossFadeState: state == PlayerState.playing
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Icon(
                            Icons.pause,
                            color: Color(colors[0]),
                            size: 20,
                          ),
                          secondChild: Icon(
                            Icons.play_arrow,
                            color: Color(colors[0]),
                            size: 20,
                          ),
                        ),
                      ))),
              IconButton(
                icon: Icon(
                  IconData(0xeb3f, fontFamily: 'boxicons'),
                  color: new Color(colors[1]).withOpacity(.7),
                  size: 25,
                ),
                onPressed: () => musicService.playNextSong(),
              ),
              IconButton(
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
                        size: 15,
                      );
                    },
                  ),

                  onPressed: () {
                    musicService.cycleBetweenPlaybackStates();
                  }
              ),
              /*IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: new Color(colors[1]).withOpacity(.5),
                      size: 25,
                    ),
                    onPressed: () {

                    }
                ),*/
            ],
          )
      ),
    );
  }
}
