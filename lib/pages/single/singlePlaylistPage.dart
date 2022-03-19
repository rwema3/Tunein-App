import 'dart:io';

import 'package:Tunein/components/artistAlbumsList.dart';
import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/albumSongList.dart';
import 'package:Tunein/components/genericSongList.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/models/playback.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/management/AddSongsToPlaylist.dart';
import 'package:Tunein/pages/management/EditPlaylist.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Tunein/components/ArtistCell.dart';
import 'package:rxdart/rxdart.dart';

class SinglePlaylistPage extends StatelessWidget {
  Playlist playlist;
  BehaviorSubject<Playlist> playlistStream = new BehaviorSubject<Playlist>();
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();

  SinglePlaylistPage({this.playlist}){
    playlistStream.add(this.playlist);
  }

  @override
  Widget build(BuildContext context) {
  Size screenSize = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: playlistStream,
      builder: (BuildContext context,
          AsyncSnapshot<Playlist> snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: Text(
                "LOADING PLAYLIST",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              )
          );
        }

        final _playlist = snapshot.data;

        if(_playlist!=null){
          return new Container(
            child: Column(
              children: <Widget>[
                Material(
                  child: Container(
                    child: new Container(
                      margin: EdgeInsets.all(0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height:60,
                              width:60,
                              child: FadeInImage(
                                placeholder: AssetImage('images/track.png'),
                                fadeInDuration: Duration(milliseconds: 200),
                                fadeOutDuration: Duration(milliseconds: 100),
                                image: playlist.covertArt != null
                                    ? FileImage(
                                  new File(playlist.covertArt),
                                )
                                    : AssetImage('images/track.png'),
                              ),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            flex: 8,
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            (playlist.name == null)
                                                ? "Unnamed Playlist"
                                                : playlist.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        flex: 8,
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            playlist.songs.length!=0?Material(
                                              color: Colors.transparent,
                                              child: Padding(
                                                  padding: const EdgeInsets.only(right: 30.0),
                                                  child:InkWell(
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 26,
                                                      color: MyTheme.darkRed,
                                                    ),
                                                    onTap: (){
                                                      openAddSongsToPlaylistPage(playlist,context);
                                                    },
                                                  )
                                              )
                                              ,
                                            ):Container(),
                                            Material(
                                              child: PopupMenuButton<ContextMenuOptions>(
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    splashColor: MyTheme.darkgrey,
                                                    radius: 30.0,
                                                    child: Padding(
                                                        padding: const EdgeInsets.only(right: 10.0),
                                                        child:Icon(
                                                          IconData(0xea7c, fontFamily: 'boxicons'),
                                                          size: 22,
                                                          color: Colors.white70,
                                                        )
                                                    ),
                                                  ),
                                                ),
                                                elevation: 3.2,
                                                onCanceled: () {
                                                  print('You have not chosen anything');
                                                },
                                                tooltip: 'Playing options',
                                                onSelected: (ContextMenuOptions choice){
                                                  switch(choice.id){
                                                    case 1: {
                                                      openAddSongsToPlaylistPage(playlist,context);
                                                      break;
                                                    }
                                                    case 2: {
                                                      musicService.updatePlaylist(playlist.songs);
                                                      musicService.stopMusic();
                                                      musicService.playMusic(playlist.songs[0], isPartOfAPlaylist: true, playlist: playlist);
                                                      musicService.updatePlaylistState(PlayerState.playing,playlist);
                                                      break;
                                                    }
                                                    case 3:{
                                                      musicService.updatePlaylist(playlist.songs);
                                                      musicService.updatePlayback(Playback.shuffle);
                                                      musicService.stopMusic();
                                                      musicService.playMusic(playlist.songs[0], isPartOfAPlaylist: true, playlist: playlist);
                                                      musicService.updatePlaylistState(PlayerState.playing,playlist);
                                                      break;
                                                    }
                                                    case 4:{
                                                      openEditPlaylistPage(playlist,context);
                                                      break;
                                                    }
                                                    case 5:{
                                                      deletePlaylist(playlist,context,message: "Confirm deleting the playlist : \"${playlist.name}\"");
                                                    }
                                                  }
                                                },
                                                itemBuilder: (BuildContext context) {
                                                  return playlistCardContextMenulist.map((ContextMenuOptions choice) {
                                                    return PopupMenuItem<ContextMenuOptions>(
                                                      value: choice,
                                                      child: Text(choice.title),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                              color: Colors.transparent,
                                            )
                                          ],
                                        ),
                                        flex: playlist.songs.length==0?2:4,
                                      )
                                    ],
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                  Text(
                                    (_playlist.songs.length == 0)
                                        ? "No Songs"
                                        : "${_playlist.songs.length} song(s)",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    margin: EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            "${Duration(milliseconds: sumDurationsofPlaylist(_playlist).floor()).inMinutes} min",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          margin: EdgeInsets.only(right: 5),
                                        ),
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white70,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.only(right: 10, left: 10),
                              alignment: Alignment.center,
                            ),
                          )
                        ],
                      ),
                      height: 100,
                    ),
                    color: MyTheme.bgBottomBar,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top
                    ),
                  ),
                  elevation: 5.0,
                ),
                Flexible(
                  child: _playlist.songs.length!=0?
                  GenericSongList(
                    songs: _playlist.songs,
                    screenSize: screenSize,
                    staticOffsetFromBottom: 100.0,
                    bgColor: null,
                    contextMenuOptions: (song){
                      return playlistSongCardContextMenulist;
                    },
                    onContextOptionSelect: (choice,tune){
                      switch(choice.id){
                        case 1: {
                          musicService.playOne(tune);
                          break;
                        }
                        case 2:{
                          musicService.startWithAndShuffleQueue(tune, _playlist.songs);
                          break;
                        }
                        case 3:{
                          musicService.startWithAndShuffleAlbum(tune);
                          break;
                        }
                        case 4:{
                          musicService.playAlbum(tune);
                        }
                      }
                    },
                    onSongCardTap: (song,state,isSelectedSong){
                      print("tapped ${song.title}");
                    },
                  ):
                  GestureDetector(
                    child: Material(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "NO SONGS IN THIS PLAYLIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Tap to add new songs",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Icon(
                              Icons.add,
                              size: 25,
                              color: MyTheme.darkRed,
                            )
                          ],
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                    onTap: (){
                      openAddSongsToPlaylistPage(playlist,context);
                    },
                  ),
                )
              ],
            ),
          );
        }else{
          return Center(
              child: Text(
                "LOADING PLAYLIST",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              )
          );
        }

      },
    );

  }

  Future<bool> savePlaylistToDisk(Playlist playlist){
    return musicService.updateSongPlaylist(playlist);
  }

  int countSongsInAlbums(List<Album> albums) {
    int count = 0;
    albums.forEach((elem) {
      count += elem.songs.length;
    });
    return count;
  }

  double sumDurationsofPlaylist(Playlist playlist) {
    double FinalDuration = 0;

    playlist.songs.forEach((song) {
      FinalDuration += song.duration;
    });

    return FinalDuration;
  }

  dynamic openEditPlaylistPage(Playlist playlist, context) async{
    ///The returned value will be the list of songs to Delete and the name of the playlist if it is changed (otherwise will be null)
     Map<String, dynamic> returnedSongsToBeDeleted = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPlaylist(
          playlist: playlist,
        ),
      ),
    );

     if(returnedSongsToBeDeleted!=null && returnedSongsToBeDeleted["removedSongsId"]?.length!=0){
       ///Deleting songs based on the returnedSongsToBeDeleted Ids

       playlist.songs.removeWhere((song){

         return returnedSongsToBeDeleted["removedSongsId"]?.contains(song.id)??false;
       });
     }

     if(returnedSongsToBeDeleted!=null && returnedSongsToBeDeleted["playlist"]!=null){
       playlist.name=returnedSongsToBeDeleted["playlist"].name;
     }


     savePlaylistToDisk(playlist);

     playlistStream.add(playlist);

     DialogService.showToast(context,
         backgroundColor: MyTheme.darkBlack,
         color: MyTheme.grey300,
         message: "Playlist saved",
         duration: 2
     );
  }

  Future<bool> openAddSongsToPlaylistPage(Playlist playlist, context)async{
    //To prevent the reference passing of the playlist from adding songs automatically we added a
    //temporary song list to reaffect if the song addition is canceled
    List<Tune> tempList = List.from(playlist.songs);
    List<Tune> returnedSongs = await  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSongsToPlaylist(
            playlist: playlist,
        ),
      ),
    );

    if(returnedSongs!=null && returnedSongs.length!=0){

      playlist.songs=returnedSongs;

      savePlaylistToDisk(playlist);

      playlistStream.add(playlist);
      return true;
    }else{
      playlist.songs = tempList;
      return false;
    }
  }



  Future<bool> deletePlaylist(Playlist playlist, context,{message}) async{
    bool deleting = await DialogService.showConfirmDialog(context,
        title: "Confirm Your Action",
        message: message,
        titleColor: MyTheme.darkRed
    );
    if(deleting!=null && deleting==true){
      await musicService.deleteAPlaylist(playlist);
      Navigator.of(context).pop();
      return true;
    }
  }

}
