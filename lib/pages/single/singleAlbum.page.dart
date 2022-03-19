import 'dart:ffi';
import 'dart:io';

import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/albumSongList.dart';
import 'package:Tunein/components/cards/optionsCard.dart';
import 'package:Tunein/components/common/ShowWithFadeComponent.dart';
import 'package:Tunein/components/itemListDevider.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/components/songInfoWidget.dart';
import 'package:Tunein/components/threeDotPopupMenu.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/memoryCacheService.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/routes/pageRoutes.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/services/uiScaleService.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:upnp/upnp.dart' as upnp;

class SingleAlbumPage extends StatelessWidget {
  final Tune song;
  final Album album;
  final double heightToSubstract;
  final musicService = locator<MusicService>();
  final memoryCacheService = locator<MemoryCacheService>();
  final castService = locator<CastService>();
  final themeService = locator<ThemeService>();



  SingleAlbumPage(song,{album, double heightToSubstract=0}):
        this.song=song,
        this.album=album,
        this.heightToSubstract=heightToSubstract,
        assert((song!=null && album==null) || (song==null && album !=null) || (song==null && album==null));

  @override
  Widget build(BuildContext context){
    Size screenSize = MediaQuery.of(context).size;
    if(album!=null){
      return singleAlbumPageContent(
        context: context,
        album: album,
        screenSize: screenSize,
        heightToSubstract: heightToSubstract
      );

    }else
    return StreamBuilder(
      stream: musicService.fetchAlbum(artist: song.artist, title: song.album),
      builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data.length == 0) {
          return new Container();
        }
        Album album = snapshot.data[0];

        return singleAlbumPageContent(
            context: context,
            album: album,
            screenSize: screenSize,
          heightToSubstract: heightToSubstract
        );
      },
    );
  }


  Widget singleAlbumPageContent({context, Album album, Size screenSize, double heightToSubstract=0}){
    bool songsFound = album.songs.length!=0;
    double definitionBarHeight = uiScaleService.AlbumArtistInfoPage(screenSize);
    List<int> bgColor = album?.songs?.length!=0? album.songs[0].colors:null;
    return Container(
      child: Column(
        children: <Widget>[
          Material(
            child: Container(
              child: new Container(
                margin: MediaQuery.of(context).padding.add(EdgeInsets.only(right: 10, left: 10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: FadeInImage(
                          placeholder: AssetImage('images/track.png'),
                          fadeInDuration: Duration(milliseconds: 200),
                          fadeOutDuration: Duration(milliseconds: 100),
                          image: album.albumArt != null
                              ? FileImage(
                            new File(album.albumArt),
                          )
                              : AssetImage('images/track.png'),
                        ),
                      ),
                      flex: 4,
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        height: screenSize.width/3,
                        /*margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8, right: 8))
                                  .add(EdgeInsets.only(top: 10)),*/
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      (album.title == null)
                                          ? "Unknon Title"
                                          : album.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.w700,
                                        color: bgColor!=null?Color(bgColor[2]).withAlpha(200):Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
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
                                              color: bgColor!=null?Color(bgColor[2]).withAlpha(200):Colors.white70,
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
                                          musicService.playEntireAlbum(album);
                                          break;
                                        }
                                        case 2:{
                                          musicService.shuffleEntireAlbum(album);
                                          break;
                                        }
                                        case 3:{
                                          musicService.shuffleEntireAlbum(album);
                                          break;
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuItem<ContextMenuOptions>> itemList = albumCardContextMenulist.map((ContextMenuOptions choice) {
                                        return PopupMenuItem<ContextMenuOptions>(
                                          value: choice,
                                          child: Text(choice.title),
                                        );
                                      }).toList();
                                      itemList.add(PopupMenuItem<ContextMenuOptions>(
                                        value: ContextMenuOptions(title: "Edit Album Tags", id: 3, icon: Icons.edit),
                                        child: Text("Edit Album Tags"),
                                      ));
                                      return ;
                                    },
                                  ),
                                  color: Colors.transparent,
                                )
                              ],
                            ),
                            Text(
                              (album.artist == null)
                                  ? "Unknown Artist"
                                  : album.artist,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w400,
                                color: bgColor!=null?Color(bgColor[2]):Colors.white,
                              ),
                              strutStyle: StrutStyle(
                                  height: 0.9,
                                  forceStrutHeight: true
                              )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.bottomRight,
                                  margin: EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                      ),
                                      Container(
                                        child: Text(
                                          "${Duration(milliseconds: sumDurationsofAlbum(album).floor()).inMinutes} min",
                                          style: TextStyle(
                                            color: bgColor!=null?Color(bgColor[2]):Colors.white70,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        margin: EdgeInsets.only(left: 5),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
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
                                )
                              ],
                            )
                          ],
                        ),
                        padding: EdgeInsets.only(right: 10, left :10),
                        alignment: Alignment.topCenter,
                      ),
                    )
                  ],
                ),
              ),
              height: definitionBarHeight,
              color: bgColor!=null?Color(bgColor[0]):MyTheme.bgBottomBar,
            ),
            elevation: 12.0,
          ),

          songsFound?Flexible(
            child: ShowWithFade(
              child: Container(
                color: MyTheme.darkBlack,
                height: screenSize.height-definitionBarHeight-heightToSubstract,
                child: CustomScrollView(
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  slivers: <Widget>[
                    SliverAppBar(
                      elevation: 0,
                      expandedHeight: 131,
                      backgroundColor: MyTheme.bgBottomBar,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: <Widget>[
                            ItemListDevider(DeviderTitle: "More choices"),
                            Container(
                              color:MyTheme.bgBottomBar,
                              height: 120,
                              child: ListView.builder(
                                itemExtent: 180,
                                itemCount: 1,
                                cacheExtent:MediaQuery.of(context).size.width,
                                addAutomaticKeepAlives: true,
                                shrinkWrap: false,

                                scrollDirection: Axis.horizontal,

                                itemBuilder: (context, index){
                                  String uniqueID = "MP${album.albumArt??album.title.split(" ").join()}";
                                  return MoreOptionsCard(
                                    uniqueID: uniqueID,
                                    backgroundWidget: memoryCacheService.isItemCached(uniqueID)?
                                    Image.memory(memoryCacheService.getCacheItem(uniqueID)):null,
                                    imageUri: album.albumArt,
                                    colors: album.songs[0].colors,
                                    bottomTitle: "Most Played",
                                    onPlayPressed: (){
                                      musicService.playMostPlayedOfAlbum(album);
                                    },
                                    onSavePressed: () async{
                                      Playlist newPlaylsit = Playlist(
                                          "Most played of ${album.title}",
                                          musicService.getMostPlayedOfAlbum(album),
                                          PlayerState.stopped,
                                          null
                                      );
                                      /// This is a temporary way fo handling until we incorporate the name changing in playlists
                                      /// The better way is that the passed playlist gets modified inside the dialog return function and then is returned
                                      /// instead of the listofSongsToBeDeleted TODO
                                      List<Tune> songsToBeDeleted = await openEditPlaylistBeforeSaving(context, newPlaylsit);
                                      if(songsToBeDeleted!=null){
                                        if(songsToBeDeleted.length!=0){
                                          List<String> idList = songsToBeDeleted.map((elem)=>elem.id);
                                          newPlaylsit.songs.removeWhere((elem){
                                            return idList.contains(elem.id);
                                          });
                                          musicService.addPlaylist(newPlaylsit).then(
                                                  (data){
                                                DialogService.showToast(context,
                                                    backgroundColor: MyTheme.darkBlack,
                                                    color: MyTheme.darkRed,
                                                    message: "Playlist : ${"Most played of ${newPlaylsit.name}"} has been saved"
                                                );
                                              }
                                          );
                                        }else{
                                          DialogService.showToast(context,
                                              backgroundColor: MyTheme.darkBlack,
                                              color: MyTheme.darkRed,
                                              message: "Chosen playlist is Empty"
                                          );
                                        }

                                      }else{
                                        print("NO SONGS FOUND");
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      stretch: true,
                      stretchTriggerOffset: 166,
                      floating: false,
                    ),
                    SliverPersistentHeader(
                      delegate: DynamicSliverHeaderDelegate(
                          child: Material(
                            child: ItemListDevider(DeviderTitle: "Tracks"),
                            color: Colors.transparent,
                          ),
                          minHeight: 35,
                          maxHeight: 35
                      ),
                      pinned: true,
                    ),
                    SliverFixedExtentList(
                      itemExtent: 62,
                      delegate: SliverChildBuilderDelegate((context, index){
                        if (index == 0) {
                          return Material(
                            child: PageHeader(
                              "Suffle",
                              "All Tracks",
                              MapEntry(
                                  IconData(Icons.shuffle.codePoint,
                                      fontFamily: Icons.shuffle.fontFamily),
                                  Colors.white),
                            ),
                            color: Colors.transparent,
                          );
                        }

                        int newIndex = index - 1;
                        return MyCard(
                          song: album.songs[newIndex],
                          choices: songCardContextMenulist,
                          ScreenSize: screenSize,
                          StaticContextMenuFromBottom: 0.0,
                          onContextSelect: (choice) async{
                            switch(choice.id){
                              case 1: {
                                musicService.playOne(album.songs[newIndex]);
                                break;
                              }
                              case 2:{
                                musicService.startWithAndShuffleQueue(album.songs[newIndex], album.songs);
                                break;
                              }
                              case 3:{
                                musicService.startWithAndShuffleAlbum(album.songs[newIndex]);
                                break;
                              }
                              case 4:{
                                musicService.playAlbum(album.songs[newIndex]);
                                break;
                              }
                              case 5:{
                                if(castService.currentDeviceToBeUsed.value==null){
                                  upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                  if(result!=null){
                                    castService.setDeviceToBeUsed(result);
                                  }
                                }
                                musicService.castOrPlay(album.songs[newIndex], SingleCast: true);
                                break;
                              }
                              case 6:{
                                upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                if(result!=null){
                                  musicService.castOrPlay(album.songs[newIndex], SingleCast: true, device: result);
                                }
                                break;
                              }
                              case 7: {
                                DialogService.showAlertDialog(context,
                                    title: "Song Information",
                                    content: SongInfoWidget(null, song: album.songs[newIndex]),
                                    padding: EdgeInsets.only(top: 10)
                                );
                                break;
                              }
                              case 8:{
                                PageRoutes.goToAlbumSongsList(album.songs[newIndex], context);
                                break;
                              }
                              case 9:{
                                PageRoutes.goToSingleArtistPage(album.songs[newIndex], context);
                                break;
                              }
                              case 10:{
                                PageRoutes.goToEditTagsPage(album.songs[newIndex], context, subtract60ForBottomBar: true);
                                break;
                              }
                            }
                          },
                          onContextCancel: (choice){
                            print("Cancelled");
                          },
                          onTap: (){
                            musicService.updatePlaylist(album.songs);
                            musicService.playOrPause(album.songs[newIndex]);
                          },
                        );
                      },
                          childCount: album.songs.length+1
                      ),
                    )
                    /*AlbumSongList(album)*/
                  ],
                ),
              ),
              durationUntilFadeStarts: Duration(milliseconds: 270),
              fadeDuration: Duration(milliseconds: 150),
              inCurve: Curves.easeIn,
              shallowWidget: Container(
                color: MyTheme.bgBottomBar,
              ),
            ),
          ):Container(
                color: MyTheme.darkgrey,
              )
        ],
      ),
    );
  }

  double sumDurationsofAlbum(Album album) {
    return ConversionUtils.songListToDuration(album.songs);
  }

  Future<List<Tune>> openEditPlaylistBeforeSaving(context,Playlist playlist) async{
    String keyword="";
    List<Tune> songsToBeDeleted=[];
    List<Artist> selectedArtists=List<Artist>();
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Editing Playlist${playlist!=null?" : "+playlist.name:""}",
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
                  Tune songs = playlist.songs[index];
                  return SelectableTile(
                    imageUri: songs.albumArt,
                    title: songs.title,
                    isSelected: true,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      print("Selected ${songs.title}");
                      if(willItBeSelected){
                        songsToBeDeleted.add(songs);
                      }else{
                        songsToBeDeleted.removeAt(songsToBeDeleted.indexWhere((elem)=>elem.title==songs.title));
                      }
                    },
                    placeHolderAssetUri: "images/track.png",
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                  childAspectRatio: 3,
                ),
                semanticChildCount: playlist.songs.length,
                cacheExtent: 120,
                itemCount: playlist.songs.length,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Save Playlist",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(songsToBeDeleted);
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

