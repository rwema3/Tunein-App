import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playback.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';


final musicService = locator<MusicService>();




class DrawerMusicControls extends StatelessWidget {

  PlayerState entryState;
  Tune entrySong;


  DrawerMusicControls({this.entryState, this.entrySong});

  @override
  Widget build(BuildContext context) {

    if(entrySong!=null && entryState!=null){
      return createDrawerControls(entrySong, entryState);
    }

    return StreamBuilder(
      stream: musicService.playerState$,
      builder: (context, AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshot){
        if(!snapshot.hasData){
          return Container();
        }
        Tune song = snapshot.data.value;
        List<int> songColor= song.colors;
        PlayerState state = snapshot.data.key;

        return createDrawerControls(song, state);
      },
    );
  }


  Widget createDrawerControls(Tune song, PlayerState state){
    List<int> songColor= song.colors;
    return Material(
      color: Colors.transparent,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5),
                  height: 45,
                  width: 45,
                  child: InkWell(
                    child: Icon(
                      state==PlayerState.paused?Icons.play_arrow:Icons.pause,
                      size: 32,
                      color: songColor.length!=0?Color(songColor[1]):MyTheme.grey300,
                    ),
                    onTap: (){
                      Future.delayed(Duration(milliseconds: 200),(){
                        musicService.playOrPause(song);
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  height: 45,
                  width: 45,
                  child: InkWell(
                    child: Icon(
                      Icons.skip_next,
                      size: 32,
                      color: songColor.length!=0?Color(songColor[1]):MyTheme.grey300,
                    ),
                    onTap: (){
                      Future.delayed(Duration(milliseconds: 200),(){
                        musicService.playNextSong();
                      });
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5),
                  height: 45,
                  width: 45,
                  child: InkWell(
                    child: Icon(
                      Icons.skip_previous,
                      size: 32,
                      color: songColor.length!=0?Color(songColor[1]):MyTheme.grey300,
                    ),
                    onTap: (){
                      Future.delayed(Duration(milliseconds: 200),(){
                        musicService.playPreviousSong();
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  height: 45,
                  width: 45,
                  child: InkWell(
                    child: StreamBuilder(
                      stream: musicService.playback$,
                      builder: (context, AsyncSnapshot<List<Playback>> snapshot){
                        Color iconColor= (songColor.length!=0?new Color(song.colors[1]):MyTheme.grey300).withOpacity(.5);
                        if(snapshot.hasData && snapshot.data.contains(Playback.shuffle)){
                          iconColor= MyTheme.darkRed;
                        }
                        return Icon(
                          Icons.shuffle,
                          color: iconColor,
                          size: 32,
                        );
                      },
                    ),
                    onTap: (){
                      musicService.updatePlayback(Playback.shuffle,removeIfExistent: true);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
