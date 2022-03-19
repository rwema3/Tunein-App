import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/playlistCell.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/management/AddSongsToPlaylist.dart';
import 'package:Tunein/pages/management/EditPlaylist.dart';
import 'package:Tunein/pages/single/singlePlaylistPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Tunein/models/playback.dart';
import 'dart:math';
import 'dart:core';
import 'package:Tunein/values/contextMenus.dart';


class PlaylistsPage extends StatefulWidget {
  PlaylistsPage({Key key}) : super(key: key);

  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin<PlaylistsPage> {
  String newPlaylistName;
  final musicService = locator<MusicService>();
  ScrollController controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      alignment: Alignment.center,
      color: MyTheme.darkBlack,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: StreamBuilder(
                        stream: musicService.playlists$,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Playlist>> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                                child: Text(
                                  "LOADING PLAYLISTS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                            );
                          }

                          final _playlists = snapshot.data;

                          if(_playlists.length==0){
                            return GestureDetector(
                              onTap:(){
                                openEditOrNexModal(null);
                              },
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "NO PLAYLISTS",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "Tap to add",
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
                            );
                          }
                          //playlists=_playlists;
                          _playlists.sort((a, b) {
                            return a.name
                                .toLowerCase()
                                .compareTo(b.name.toLowerCase());
                          });
                          return ListView.builder(
                            padding: EdgeInsets.all(0),
                            controller: controller,
                            shrinkWrap: true,
                            itemExtent: 62,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: _playlists.length,
                            itemBuilder: (context, index) {
                              final Playlist _currentPlaylist = _playlists[index];

                              return InkWell(
                                enableFeedback: false,
                                child: PlaylistCell(
                                  choices: playlistCardContextMenulist,
                                  onContextSelect: (choice){
                                    switch(choice.id){
                                      case 1: {
                                        openAddSongsToPlaylistPage(_currentPlaylist,context);
                                        break;
                                      }
                                      case 2: {
                                        musicService.updatePlaylist(_currentPlaylist.songs);
                                        musicService.stopMusic();
                                        musicService.playMusic(_currentPlaylist.songs[0], isPartOfAPlaylist: true, playlist: _currentPlaylist);
                                        musicService.updatePlaylistState(PlayerState.playing,_currentPlaylist);
                                        break;
                                      }
                                      case 3:{
                                        musicService.updatePlaylist(_currentPlaylist.songs);
                                        musicService.updatePlayback(Playback.shuffle);
                                        musicService.stopMusic();
                                        musicService.playMusic(_currentPlaylist.songs[0], isPartOfAPlaylist: true, playlist: _currentPlaylist);
                                        musicService.updatePlaylistState(PlayerState.playing,_currentPlaylist);
                                        break;
                                      }
                                      case 4:{
                                        openEditPlaylistPage(_currentPlaylist,context);
                                        break;
                                      }
                                      case 5:{
                                        deletePlaylist(_currentPlaylist,context,message: "Confirm deleting the playlist : \"${_currentPlaylist.name}\"");
                                      }
                                    }
                                  },
                                  onContextCancel: (){
                                    print("Cancelled");
                                  },
                                  playlistItem: _playlists[index],
                                  onTap: (){
                                    goToSinglePlaylistPage(_currentPlaylist);
                                  },
                                ),
                              );
                            },
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
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              child: Icon(
                  Icons.playlist_add,
                size: 26,
                color: MyTheme.darkRed,
              ),
              backgroundColor: MyTheme.bgdivider,
              elevation: 12.0,
              onPressed: (){
                openEditOrNexModal(null);
              },
            ),
          )
        ],
      ),
    );
  }



  void goToSinglePlaylistPage(Playlist playlist){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SinglePlaylistPage(
          playlist: playlist,
        ),
      ),
    );
  }


  dynamic openEditPlaylistPage(Playlist playlist, context) async{
    ///The returned value will be the list of songs to Delete and the name of the playlist if it is changed (otherwise will be null)
    MapEntry<List<String>,String> returnedSongsToBeDeleted = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPlaylist(
          playlist: playlist,
        ),
      ),
    );

    if(returnedSongsToBeDeleted!=null && returnedSongsToBeDeleted.key.length!=0){
      ///Deleting songs based on the returnedSongsToBeDeleted Ids

      playlist.songs.removeWhere((song){
        return returnedSongsToBeDeleted.key.contains(song.id);
      });

      if(returnedSongsToBeDeleted.value!=null){
        playlist.name=returnedSongsToBeDeleted.value;
      }

      savePlaylistToDisk(playlist);

    }
  }

  Future<bool> savePlaylistToDisk(Playlist playlist){
    return musicService.updateSongPlaylist(playlist);
  }

  Future<bool> deletePlaylist(Playlist playlist, context,{message}) async{
    bool deleting = await DialogService.showConfirmDialog(context,
        title: "Confirm Your Action",
        message: message,
        titleColor: MyTheme.darkRed
    );
    if(deleting!=null && deleting==true){
      await musicService.deleteAPlaylist(playlist);
      return true;
    }
  }

  Future<bool> openAddSongsToPlaylistPage(Playlist playlist, context)async{
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

      return true;
    }else{
      playlist.songs = tempList;
      return false;
    }
  }


  Future<Playlist> openEditOrNexModal(Playlist playlist){
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
                "Adding playlist",
              style: TextStyle(
                color: Colors.white70
              ),
            ),
            content: TextField(
              onChanged: (string){
                this.newPlaylistName=string;
              },
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Choose a playlist name",
                hintStyle: TextStyle(
                  color: MyTheme.grey500.withOpacity(0.2)
                )
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                    "Add",
                  style: TextStyle(
                    color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Playlist playlist = new Playlist(this.newPlaylistName, [], PlayerState.stopped, null);
                  musicService.addPlaylist(playlist).then(
                      (data){
                        Navigator.of(context, rootNavigator: true).pop(playlist);
                      }
                  );
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

   /* Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => EditPlaylist(playlist: playlist),
          fullscreenDialog: true
      ),
    );*/
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
