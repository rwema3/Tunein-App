import 'dart:io';

import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/genericSongList.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/models/playback.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:rxdart/rxdart.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:Tunein/services/dialogService.dart' as Dialog;
import 'package:Tunein/services/layout.dart';
class AddSongsToPlaylist extends StatefulWidget {

  Playlist playlist;


  AddSongsToPlaylist({this.playlist});

  @override
  _AddSongsToPlaylistState createState() => _AddSongsToPlaylistState();
}

class _AddSongsToPlaylistState extends State<AddSongsToPlaylist> {
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  final layoutService = locator<LayoutService>();

  BehaviorSubject<List<Tune>> searchResultSongs =  BehaviorSubject<List<Tune>>();
  var _TextController = TextEditingController();
  List<Tune> returnedSongs=[];
  int NumberOfSongsToBeadded=0;
  final List<ContextMenuOptions> newList = List.from(playlistSearchSongCardContextMenulist);
  dynamic globalContext;
  @override
  void initState() {
      if(widget.playlist!=null)returnedSongs=widget.playlist.songs;
      globalContext = context;
  }

  bool isSongAlreadyAddedInPlaylist(Tune song){
    Iterable<Tune> songIPlaylist = returnedSongs.where((songT){
      return song.id==songT.id;
    });
    if(songIPlaylist.length!=0){
      return true;
    }else{
      return false;
    }
  }

  search(String keyword) async{
    List<String> keywordArray = keyword.split(" ");
    keyword=keyword.toLowerCase().trim();
    Map<double, Tune> songSimilarityArray = new Map();
    List<Tune> searchedsongs =[];
    if(keyword.length==0){
      print("adding all songs");
      searchedsongs.addAll(musicService.songs$.value);
      searchResultSongs.add(searchedsongs);
      return;
    }
    searchedsongs.addAll(musicService.songs$.value.where((song){
      if(((song.title!=null && song.title.toLowerCase().contains(keyword))
          || (song.album != null && song.album.toLowerCase().contains(keyword))
          || (song.artist != null && song.artist.toLowerCase().contains(keyword)))
          && (!isSongAlreadyAddedInPlaylist(song))
      ){
        return true;
      }
      return false;
    }));
   /* ///Finding the similar songs
     musicService.songs$.value.forEach((song){
      double similarity = StringSimilarity.compareTwoStrings(keyword, song.title);
      if(similarity>0.3){
        songSimilarityArray[similarity]= song;
      }else{
        if((song.title!=null && song.title.toLowerCase().contains(keyword)) || (song.album != null && song.album.toLowerCase().contains(keyword))){
          songSimilarityArray[1.0]= song;
        }
      }
    });
    ///Sorting the songs

    List<double> sortedKeys = songSimilarityArray.keys.toList();

    sortedKeys.sort((a,b){
      return b.compareTo(a);
    });
    sortedKeys.forEach((key){
      searchedsongs.add(songSimilarityArray[key]);
    });*/

    searchResultSongs.add(searchedsongs);
  }


  void showSuccessNotifier(Tune song, {message,title}){
    /*Dialog.DialogService.showFlushbar(
        layoutService.scaffoldKey.currentContext
        ,
        message: message==null?"Song Added":message,
        title: title==null?"${song.title}... added to ${widget.playlist.name}":title,
        color: MyTheme.darkBlack
    );*/

    Dialog.DialogService.showToast(context,
      message: message==null?"${song.title} added to ${widget.playlist.name}":message,
      color: MyTheme.darkRed,
      backgroundColor: MyTheme.darkBlack
    );
  }

  void addSongToPlaylsit(song){
    returnedSongs.add(song);
    NumberOfSongsToBeadded++;
    searchResultSongs.value.removeWhere((songToRemove){
      return song.id==songToRemove.id;
    });
    searchResultSongs.add(
        searchResultSongs.value
    );
    showSuccessNotifier(song);
    setState(() {

    });
  }




  void addAlbumToPlaylsit(Tune song){
    Album albumToAdd = musicService.albums$.value.firstWhere(
            (album){
          return (album.title==song.album && album.artist==song.artist);
        }
    );
    NumberOfSongsToBeadded+=albumToAdd.songs.length;
    returnedSongs.addAll(albumToAdd.songs);

    List<String> IdList = albumToAdd.songs.map((song){
      return song.id;
    }).toList();
    searchResultSongs.value.removeWhere((songToRemove){
      return  IdList.contains(songToRemove.id);
    });
    searchResultSongs.add(
        searchResultSongs.value
    );
    showSuccessNotifier(song,
      message: "Album Added",
      title: "Added all ${song.album} to ${widget.playlist.name}"
    );
    setState(() {

    });
  }

  @override
  Widget build(BuildContext Gcontext) {
    Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{
        if(NumberOfSongsToBeadded>0){
          bool saving = await Dialog.DialogService.showConfirmDialog(context,
            title: "Unsaved Changes",
            message: "You have picked songs to add to your playlist but not to saved them, would you like to save your songs now ?",
            titleColor: MyTheme.darkRed,
            messageColor: MyTheme.grey300,
            cancelButtonText: "Don't save",
            confirmButtonText: "SAVE & QUIT"
          );
          if(saving!=null && saving ==true){
            Navigator.of(context).pop(returnedSongs);

          }else{
            Navigator.of(context).pop(new List<Tune>(0));
          }
        }else{
          return true;
        }
      },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: MediaQuery.of(context).padding,
            ),
            Material(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xff0E0E0E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.5),
                      spreadRadius: 10,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(new List<Tune>(0));
                        },
                        iconSize: 26,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          autofocus: false,
                          cursorColor: MyTheme.darkRed,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          onChanged: (keyword){
                            print("Keyword is : ${keyword}");
                            search(keyword);
                          },
                          controller: _TextController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: MyTheme.darkBlack,
                            hintText: "TRACK, ALBUM, ARTIST",
                            hintStyle:
                            TextStyle(color: Colors.white54, fontSize: 18),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(returnedSongs);
                        },
                        iconSize: 26,
                        splashColor: MyTheme.grey700,
                        icon: Icon(
                          NumberOfSongsToBeadded==0? Icons.close : Icons.check,
                          color: MyTheme.darkRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: searchResultSongs,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Tune>> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  final _songs = snapshot.data;
                  _songs.sort((a, b) {
                    return a.title
                        .toLowerCase()
                        .compareTo(b.title.toLowerCase());
                  });
                  return GenericSongList(
                    songs: _songs ,
                    screenSize:screenSize,
                    contextMenuOptions:(song){

                      int numberOfSOngsInAlbum = musicService.albums$.value.firstWhere((album){
                        return album.artist== song.artist && album.title==song.album;
                      }, orElse: (){
                        return new Album(99999999999999999, "", "", "");
                      }).songs.length;

                      ///This should be done in an other cleaner way
                      ///the problem is that we can't create a fully new copy of the contextOptions list
                      ///since we always have to copy the reference of the ContextMenuOption object.


                      List<ContextMenuOptions> singleList =[
                        ContextMenuOptions(
                          id: 1,
                          title: "Add one",
                          icon: Icons.add,
                        ),
                        ContextMenuOptions(
                          id: 2,
                          title: "Add entire album",
                          icon: Icons.add,
                        ),
                      ] ;
                      singleList[1].title= "${singleList[1].title} (+${numberOfSOngsInAlbum})";
                      return singleList;
                    },
                    onSongCardTap: (song,state,isSelectedSong){

                    },
                    onContextOptionSelect: (choice, song){
                      switch(choice.id){
                        case 1: {
                          addSongToPlaylsit(song);
                          break;
                        }
                        case 2:{
                          addAlbumToPlaylsit(song);
                          break;
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
