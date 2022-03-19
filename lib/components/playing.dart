import 'dart:async';
import 'dart:io';
import 'package:Tunein/components/customPageView.dart';
import 'package:Tunein/pages/single/singlePlaylistPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/services/layout.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:Tunein/components/slider.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:flutter/widgets.dart';
import 'package:Tunein/pages/single/singleAlbum.page.dart';
import 'controlls.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Tunein/pages/single/playingQueue.dart';
import 'package:badges/badges.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:dart_tags/dart_tags.dart';


class NowPlayingScreen extends StatefulWidget {
  PageController controller;

  NowPlayingScreen({controller}) {
    this.controller = controller != null ? controller : new PageController(
      initialPage: 1
    );
  }

  @override
  NowPlayingScreenState createState() => NowPlayingScreenState();
}

class NowPlayingScreenState extends State<NowPlayingScreen> {
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _screenHeight = MediaQuery.of(context).size.height;
    BehaviorSubject<Tune> songStream = new BehaviorSubject<Tune>();
    Tune song;
    return CustomPageView(
      controller: widget.controller,
      shallowWidget : Container(color:MyTheme.bgBottomBar),
      pages: <Widget>[
        playingQueue(),
        PlayingPage(songStream),
        AlbumSongs(songStream: musicService.playerState$),
      ],
    );
  }
}

class PlayingPage extends StatefulWidget {
  BehaviorSubject<Tune> getTuneWhenReady;

  PlayingPage(this.getTuneWhenReady);

  @override
  _PlayingPageState createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage>
    with AutomaticKeepAliveClientMixin<PlayingPage> {
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  final layoutService = locator<LayoutService>();
  MapEntry<MapEntry<PlayerState, Tune>, List<Tune>> tempState;
  BehaviorSubject<MapEntry<MapEntry<PlayerState, Tune>, List<Tune>>> newStream = new BehaviorSubject<MapEntry<MapEntry<PlayerState, Tune>, List<Tune>>>();
  Timer isScheduelingtoPushData;

  void _proceedArg(String path) {
    final fileType = FileStat.statSync(path).type;
    switch (fileType) {
      case FileSystemEntityType.directory:
        Directory(path)
            .list(recursive: true, followLinks: false)
            .listen((FileSystemEntity entity) {
          if (entity.statSync().type == FileSystemEntityType.file &&
              entity.path.endsWith('.mp3')) {
            printFileInfo(entity.path);
          }
        });
        break;
      case FileSystemEntityType.file:
        if (path.endsWith('.mp3')) {
          printFileInfo(path);
        }
        break;
      case FileSystemEntityType.notFound:
        print('file not found');
        break;
      default:
        print('sorry dude I don`t know what I must to do with that...\n');
    }
  }

  void printFileInfo(String fileName) {
    final file = File(fileName);
    TagProcessor().getTagsFromByteArray(file.readAsBytes()).then((l) {
      print('FILE: $fileName');
      l.forEach((data){
        print(data);
      });
      print('\n');
    });


  }

  @override
  void initState() {

    Stream<MapEntry<MapEntry<PlayerState, Tune>, List<Tune>>>  originalStream = Rx.combineLatest2(
      musicService.playerState$,
      musicService.favorites$,
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
  Widget build(BuildContext context) {
    final _screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<MapEntry<MapEntry<PlayerState, Tune>, List<Tune>>>(
      stream: newStream,
      builder: (BuildContext context,
          AsyncSnapshot<MapEntry<MapEntry<PlayerState, Tune>, List<Tune>>>
              snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: MyTheme.bgBottomBar,
          );
        }

        final _state = snapshot.data.key.key;
        final _currentSong = snapshot.data.key.value;
        final List<Tune> _favorites = snapshot.data.value;
        //_proceedArg(_currentSong.uri);
        print(_currentSong.artist);
        print(_currentSong.album);
        print(_currentSong.title);
        final int index =
            _favorites.indexWhere((song) => song.id == _currentSong.id);
        final bool _isFavorited = index == -1 ? false : true;

        if (_currentSong.id == null) {
          return Scaffold(
            backgroundColor: MyTheme.bgBottomBar,
          );
        }
        widget.getTuneWhenReady.add(_currentSong);
        MapEntry<PlayerState, Playlist> currentPlaylist = musicService.currentPlayingPlaylist$.value;
        final List<int> colors = (_currentSong.colors!=null && _currentSong.colors.length!=0)?_currentSong.colors:themeService.defaultColors;
        MapEntry<Tune, Tune> songs = musicService.getNextPrevSong(_currentSong);

        if (_currentSong == null || songs == null) {
          return Container(
            height: _screenHeight,
          );
        }
        //Album/Playlist menu

        Key widgetKey = GlobalKey();
        PopupMenu menu = PopupMenu(
            backgroundColor: Color(colors[1]),
            lineColor: Colors.transparent,
            maxColumn: 2,
            context: context,
            items: [
              MenuItem(
                  title: 'Album',
                  textStyle: TextStyle(
                      fontSize: 10.0,
                      color:  Color(colors[0])
                  ),
                  image: Icon(
                    Icons.album,
                    size: 30,
                    color: Color(colors[0]).withOpacity(.9),
                  )
              ),
              MenuItem(
                  title: 'Playlist',
                  textStyle: TextStyle(fontSize: 10.0, color:  Color(colors[0])),
                  image: Icon(
                    Icons.playlist_add_check,
                    size: 30,
                    color: Color(colors[0]).withOpacity(.9),
                  )
              ),
            ],
            onClickMenu: (provider){
              print("provider got is : ${provider}");
              switch(provider.menuTitle){
                case "Album":{
                  gotoFullAlbumPage(context, _currentSong);
                  break;
                }
                case "Playlist":{
                  gotoFullPlaylistPage(context, currentPlaylist.value);
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
        Widget AlbumButton = InkWell(
          radius: 90.0,
          child: currentPlaylist.value!=null?Badge(
            key: widgetKey,
            child: Icon(
              Icons.album,
              size: 30,
              color: Color(colors[1]).withOpacity(.7),
            ),
            badgeContent: Center(
              child: Icon(Icons.playlist_play,
                size: 19,
                color: MyTheme.darkRed,
              ),
            ),
            padding: EdgeInsets.all(1),
            position: BadgePosition.topEnd(
                top: -9,
                end: -6
            ),
            badgeColor: Color(colors[0]),
          ):Icon(
            Icons.album,
            size: 30,
            color: Color(colors[1]).withOpacity(.7),
          ),
          onTap: () {
            if(currentPlaylist.value==null){
              gotoFullAlbumPage(context, _currentSong);
            }else{
              print("gona launch");
              menu.show(widgetKey: widgetKey);
            }

          },

        );

        //Next and Previous songs

        String image = songs.value.albumArt;
        String image2 = songs.key.albumArt;

        return Scaffold(
          backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                AnimatedContainer(
                  padding: MediaQuery.of(context).padding,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.decelerate,
                  color: Color(colors[0]),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Material(
                        elevation: 22,
                        color:Colors.transparent,
                        child: Container(
                            color: Colors.transparent,
                            height: _screenHeight,
                            constraints: BoxConstraints(
                                maxHeight: _screenHeight / 2, minHeight: _screenHeight / 2),
                            padding: const EdgeInsets.all(10),
                            child: Dismissible(
                              key: UniqueKey(),
                              background: image == null
                                  ? Image.asset("images/cover.png")
                                  : Image.file(File(image),height: _screenHeight/2,fit: BoxFit.fill,),
                              secondaryBackground: image2 == null
                                  ? Image.asset("images/cover.png")
                                  : Image.file(File(image2),height: _screenHeight/2,fit: BoxFit.fill,),
                              movementDuration: Duration(milliseconds: 500),
                              resizeDuration: Duration(milliseconds: 2),
                              dismissThresholds: const {
                                DismissDirection.endToStart: 0.3,
                                DismissDirection.startToEnd: 0.3
                              },
                              direction: DismissDirection.horizontal,
                              onDismissed: (DismissDirection direction) {
                                if (direction == DismissDirection.startToEnd) {
                                  musicService.playPreviousSong();
                                } else {
                                  musicService.playNextSong();
                                }
                              },
                              child: _currentSong.albumArt == null
                                  ? Image.asset("images/cover.png")
                                  : Image.file(File(_currentSong.albumArt),height: _screenHeight/2,fit: BoxFit.fill,),
                            )
                        ),
                      ),

                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: [
                              new BoxShadow(
                                  color: Color(colors[0]),
                                  blurRadius: 50,
                                  spreadRadius: 50,
                                  offset: new Offset(0, -20)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    child: InkWell(
                                      child: Icon(
                                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: new Color(colors[1]).withOpacity(.7),
                                        size: 30,
                                      ),
                                      onTap: () {
                                        if (_isFavorited) {
                                          musicService.removeFromFavorites(_currentSong);
                                        } else {
                                          musicService.addToFavorites(_currentSong);
                                        }
                                      },
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          _currentSong.title,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(colors[1]).withOpacity(.7),
                                            fontSize: 18,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            MyUtils.getArtists(_currentSong.artist),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(colors[1]).withOpacity(.7),
                                              fontSize: 15,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    child: AlbumButton,
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                ],
                              ),
                              NowPlayingSlider(colors),
                              MusicBoardControls(colors, state: _state, currentSong: _currentSong),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    right: 3,
                    top: (_screenHeight / 2)-40,
                    child: Container(
                      child:
                      RotatedBox(
                        quarterTurns: -1,
                        child: Column(
                          children: <Widget>[
                            Text("Album songs",
                                style: TextStyle(
                                    color: Color(colors[1]).withOpacity(0.4),
                                    fontSize: 12.5)
                            ),
                            Container(
                              constraints: BoxConstraints.tightFor(height: 4.0),
                              margin: EdgeInsets.only(top: 1),
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Color(colors[1]),
                                  borderRadius:
                                  BorderRadius.circular(9.5708)),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
                Positioned(
                    left: 3,
                    top: (_screenHeight / 2)-40,
                    child: Container(
                      child:
                      RotatedBox(
                        quarterTurns: 1,
                        child: Column(
                          children: <Widget>[
                            Text("Playing queue",
                                style: TextStyle(
                                    color: Color(colors[1]).withOpacity(0.4),
                                    fontSize: 12.5)
                            ),
                            Container(
                              constraints: BoxConstraints.tightFor(height: 4.0),
                              margin: EdgeInsets.only(top: 1),
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Color(colors[1]),
                                  borderRadius:
                                  BorderRadius.circular(9.5708)),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
              ],
            )
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  String getDuration(Tune _song) {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      return _minutes.toString() + ":" + _seconds.toString();
    } else {
      return _minutes.toString() + ":0" + _seconds.toString();
    }
  }

  //Returns the entire Player page widget
  //deprecated
  /*getPlayinglayout(Tune _currentSong, List<int> colors, double _screenHeight,
      bool _isFavorited, PlayerState state, MapEntry<PlayerState, Playlist> currentPlaylist, context) {
    MapEntry<Tune, Tune> songs = musicService.getNextPrevSong(_currentSong);

    if (_currentSong == null || songs == null) {
      return Container(
        height: _screenHeight,
      );
    }
    //Album/Playlist menu

    Key widgetKey = GlobalKey();
    PopupMenu menu = PopupMenu(
        backgroundColor: Color(colors[1]),
        lineColor: Colors.transparent,
        maxColumn: 2,
        context: context,
        items: [
          MenuItem(
              title: 'Album',
              textStyle: TextStyle(
                fontSize: 10.0,
                color:  Color(colors[0])
              ),
              image: Icon(
                Icons.album,
                size: 30,
                color: Color(colors[0]).withOpacity(.9),
              )
          ),
          MenuItem(
              title: 'Playlist',
              textStyle: TextStyle(fontSize: 10.0, color:  Color(colors[0])),
              image: Icon(
                Icons.playlist_add_check,
                size: 30,
                color: Color(colors[0]).withOpacity(.9),
              )
          ),
        ],
        onClickMenu: (provider){
          print("provider got is : ${provider}");
          switch(provider.menuTitle){
            case "Album":{
              gotoFullAlbumPage(context, _currentSong);
              break;
            }
            case "Playlist":{
              gotoFullPlaylistPage(context, currentPlaylist.value);
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
    Widget AlbumButton = InkWell(
      radius: 90.0,
      child: currentPlaylist.value!=null?Badge(
        key: widgetKey,
        child: Icon(
          Icons.album,
          size: 30,
          color: Color(colors[1]).withOpacity(.7),
        ),
        badgeContent: Center(
          child: Icon(Icons.playlist_play,
            size: 17,
            color: MyTheme.darkRed,
          ),
        ),
        padding: EdgeInsets.all(1),
        position: BadgePosition.topRight(
            top: -9,
            right: -6
        ),
        badgeColor: Color(colors[0]),
      ):Icon(
        Icons.album,
        size: 30,
        color: Color(colors[1]).withOpacity(.7),
      ),
      onTap: () {
        if(currentPlaylist.value==null){
          gotoFullAlbumPage(context, _currentSong);
        }else{
          print("gona launch");
          menu.show(widgetKey: widgetKey);
        }

      },

    );

    //Next and Previous songs

    String image = songs.value.albumArt;
    String image2 = songs.key.albumArt;

    //Actual Widget
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
            height: _screenHeight,
            constraints: BoxConstraints(
                maxHeight: _screenHeight / 2, minHeight: _screenHeight / 2),
            padding: const EdgeInsets.all(10),
            child: Dismissible(
              key: UniqueKey(),
              background: image == null
                  ? Image.asset("images/cover.png")
                  : Image.file(File(image)),
              secondaryBackground: image2 == null
                  ? Image.asset("images/cover.png")
                  : Image.file(File(image2)),
              movementDuration: Duration(milliseconds: 500),
              resizeDuration: Duration(milliseconds: 2),
              dismissThresholds: const {
                DismissDirection.endToStart: 0.3,
                DismissDirection.startToEnd: 0.3
              },
              direction: DismissDirection.horizontal,
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.startToEnd) {
                  musicService.playPreviousSong();
                } else {
                  musicService.playNextSong();
                }
              },
              child: _currentSong.albumArt == null
                  ? Image.asset("images/cover.png")
                  : Image.file(File(_currentSong.albumArt)),
            )
        ),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                new BoxShadow(
                    color: Color(colors[0]),
                    blurRadius: 50,
                    spreadRadius: 50,
                    offset: new Offset(0, -20)),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      child: InkWell(
                        child: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: new Color(colors[1]).withOpacity(.7),
                          size: 30,
                        ),
                        onTap: () {
                          if (_isFavorited) {
                            musicService.removeFromFavorites(_currentSong);
                          } else {
                            musicService.addToFavorites(_currentSong);
                          }
                        },
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            _currentSong.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(colors[1]).withOpacity(.7),
                              fontSize: 18,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              MyUtils.getArtists(_currentSong.artist),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(colors[1]).withOpacity(.7),
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      child: AlbumButton,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ],
                ),
                NowPlayingSlider(colors),
                MusicBoardControls(colors, state: state, currentSong: _currentSong,),
              ],
            ),
          ),
        ),
      ],
    );
  }*/


  gotoFullAlbumPage(context, Tune song) {
    ///opens an other page, Deprecated in favor of a pageView slide
    //MyUtils.createDelayedPageroute(context, SingleAlbumPage(song),this.widget);
    layoutService.albumPlayerPageController
        .nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  gotoFullPlaylistPage(context, Playlist playlist) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SinglePlaylistPage(
          playlist: playlist,
        ),
      ),
    );
  }
}

class AlbumSongs extends StatefulWidget {
  Stream songStream;
  Tune song;

  AlbumSongs({songStream, song}) {
    this.songStream = songStream;
    this.song = song;
    assert((song == null && songStream != null) ||
        (song != null && songStream == null));
  }

  @override
  _AlbumSongsState createState() => _AlbumSongsState();
}

class _AlbumSongsState extends State<AlbumSongs>
    with AutomaticKeepAliveClientMixin<AlbumSongs> {
  @override
  Widget build(BuildContext context) {
    if (widget.song != null) {
      return SingleAlbumPage(widget.song);
    } else
      return StreamBuilder<MapEntry<PlayerState, Tune>>(
        stream: widget.songStream,
        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: MyTheme.bgBottomBar,
            );
          }
          final _currentSong = snapshot.data.value;

          if (_currentSong.id == null) {
            return Scaffold(
              backgroundColor: MyTheme.bgBottomBar,
            );
          }
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleAlbumPage(_currentSong),
          );
        },
      );
  }

  @override
  bool get wantKeepAlive => true;
}
