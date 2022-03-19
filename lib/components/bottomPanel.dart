import 'dart:io';

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/models/playerstate.dart';

import '../globals.dart';

class BottomPanel extends StatelessWidget {
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  Widget playPauseButton;
  Tune oldSong;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapEntry<PlayerState, Tune>>(
      stream: musicService.playerState$.where((newValue){
        if(oldSong!=null && oldSong.id==newValue.value.id){
          return false;
        }else{
          oldSong= newValue.value;
          return true;
        }
      }),
      builder: (BuildContext context,
          AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshot) {

        if (!snapshot.hasData) {
          return Container(
            color: MyTheme.bgBottomBar,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
          );
        }

        final Tune _currentSong = snapshot.data.value;

        if (_currentSong.id == null) {
          return Container(
            color: MyTheme.bgBottomBar,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
          );
        }

        final PlayerState _state = snapshot.data.key;
        final String _artists = getArtists(_currentSong);
        List<int> currentColors = (_currentSong.colors != null && _currentSong.colors.length!=0)?_currentSong.colors:themeService.defaultColors;
        return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.decelerate,
            color: Color(currentColors[0]),
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: getBottomPanelLayout(
                _state, _currentSong, _artists, currentColors));
      },
    );
  }

  String getArtists(Tune song) {
    if(song.artist == null) return "Unknow Artist";
    return song.artist.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }

  getBottomPanelLayout(_state, _currentSong, _artists, colors) {
    /*if(playPauseButton==null){
      playPauseButton = PlayPauseButton(_state,_currentSong,colors);
    }*/
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
           width: 60,
          height: 60,
          child: Padding(
            padding: EdgeInsets.only(right: 0, left: 5),
            child: _currentSong.albumArt != null
                ? Image.file(File(_currentSong.albumArt), fit: BoxFit.contain)
                : Image.asset("images/track.png"),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              getSlider(colors, _currentSong),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _currentSong.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(colors[1]).withOpacity(.7),
                              ),
                            ),
                          ),
                          Text(
                            _artists,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(colors[1]).withOpacity(.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Color(colors[1]),
                            onTap: () {
                              if (_currentSong.uri == null) {
                                return;
                              }
                              Future.delayed(Duration(milliseconds: 200),(){
                                musicService.playPreviousSong();
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(
                                    IconData(0xeb40, fontFamily: 'boxicons'),
                                    color: new Color(colors[1]).withOpacity(.7),
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: StreamBuilder(
                            initialData: MapEntry<PlayerState, Tune>(_state,_currentSong),
                            stream: musicService.playerState$,
                            builder: (context, AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshot){
                              PlayerState newStat = snapshot.data.key;
                              return PlayPauseButtonWidget(newStat, colors, (PlayerState state){
                                if(state==PlayerState.playing){
                                  //will run pause
                                  Future.delayed(Duration(milliseconds: 200),(){
                                    musicService.playOrPause(null, PlayPauseCurrentSong: true);
                                  });
                                  return;
                                }
                                if(state==PlayerState.paused){
                                  //will run play
                                  Future.delayed(Duration(milliseconds: 200),(){
                                    musicService.playOrPause(null, PlayPauseCurrentSong: true);
                                  });
                                  return;
                                }
                              }
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }


  Widget getSlider(List<int> colors, Tune song){

        return Stack(
          children: <Widget>[
            StreamBuilder(
              initialData: Duration(milliseconds: 1),
              stream: musicService.position$,
              builder: (BuildContext context,
                  AsyncSnapshot<Duration> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                final Duration _currentDuration = snapshot.data;

                return new LinearProgressIndicator(
                  value: _currentDuration != null &&
                      _currentDuration.inMilliseconds > 0
                      ? (song.duration!=0?_currentDuration.inMilliseconds.toDouble()/song.duration:0)
                      : 0.0,
                  valueColor:
                  new AlwaysStoppedAnimation(Color(colors[1])),
                  backgroundColor: Color(colors[0]),
                ) ;
              },
            )
          ],
        );
  }
//Deprecated
  Widget PlayPauseButton(PlayerState state, Tune _currentSong, List<int> colors){
    PlayerState _state = state;
    return PlayPauseButtonWidget(_state,colors, (PlayerState state){
      if(state==PlayerState.playing){
        //will run pause
        Future.delayed(Duration(milliseconds: 200),(){
          musicService.pauseMusic(_currentSong);
        });
        return;
      }
      if(state==PlayerState.paused){
        //will run play
        Future.delayed(Duration(milliseconds: 200),(){
          musicService.playMusic(_currentSong);
        });
        return;
      }
    });
  }
}

class PlayPauseButtonWidget extends StatefulWidget {
  final PlayerState _state;
  final List<int> colors;
  final Function(PlayerState) onTap;

  PlayPauseButtonWidget(this._state, this.colors, this.onTap){
  }

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButtonWidget> {
  PlayerState _state;
  List<int> colors;
  Function(PlayerState) onTap;


  @override
  void initState() {
    super.initState();
    _state = widget._state;
    colors=widget.colors;
    onTap=widget.onTap;
  }

  @override
  void didUpdateWidget(PlayPauseButtonWidget oldWidget) {
    if(oldWidget._state != widget._state || oldWidget.colors != widget.colors || oldWidget.onTap != widget.onTap) {
      setState((){
        _state = widget._state;
        colors=widget.colors;
        onTap=widget.onTap;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print(_state);
    return Material(
      color: Colors.transparent,
      child: IconButton(
        splashColor: Color(colors[1]),
        onPressed: () {
          if (PlayerState.paused == _state) {
            onTap(_state);
            setState(() {
              _state = PlayerState.playing;
            });

          } else {
            onTap(_state);
            setState(() {
              _state=PlayerState.paused;
            });
          }
        },
        icon: _state == PlayerState.playing
            ? Icon(
          Icons.pause,
          color: Color(colors[1]).withOpacity(.7),
        )
            : Icon(
          Icons.play_arrow,
          color: Color(colors[1]).withOpacity(.7),
        ),
      ),
    );;
  }
}
