import 'dart:async';
import 'dart:isolate';
import 'package:Tunein/components/customPageView.dart';
import 'package:Tunein/components/drawer/sideDrawer.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/collection/collection.page.dart';
import 'package:Tunein/pages/library/library.page.dart';
import 'package:Tunein/pages/settings/settings.page.dart';
import 'package:Tunein/plugins/NotificationControlService.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/layout.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicMetricsService.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:Tunein/services/sideDrawerService.dart';
import 'package:Tunein/utils/messaginUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/bottomnavbar.dart';
import 'globals.dart';
enum StartupState { Busy, Success, Error }

class Root extends StatefulWidget {
  RootState createState() => RootState();
}

class RootState extends State<Root> with TickerProviderStateMixin {
  final musicService = locator<MusicService>();
  final metricService = locator<MusicMetricsService>();
  final layoutService = locator<LayoutService>();
  final SettingService = locator<settingService>();
  final MusicServiceIsolate = locator<musicServiceIsolate>();
  final NotificationService = locator<notificationControlService>();
  final drawerService = locator<SideDrawerService>();

  final _androidAppRetain = MethodChannel("android_app_retain");

  final StreamController<StartupState> _startupStatus =
      StreamController<StartupState>();
  @override
  void initState() {
    MusicServiceIsolate.callerCreateIsolate().then((value){
      MusicServiceIsolate.sendReceive("Hello").then((retunedValue)async{
        print("the returned value is ${retunedValue}");
        await SettingService.fetchSettings();
        MusicServiceIsolate.callerCreatePluginEnabledIsolate({})
            .then((value){
          print("isolate with plugins initiated");
          musicService.manualAudioPlayerInit();
          musicService.showUI();
          MessagingUtils.sendNewStandardIsolateCommand(command: "createServerAndAddFilesHosting",
              message: [
                SettingService.getCurrentMemorySetting(SettingsIds.SET_OUT_GOING_HTTP_SERVER_IP),
                SettingService.getCurrentMemorySetting(SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT)
              ]);
          loadFiles();
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _startupStatus.close();
    musicService.hideUI();
    super.dispose();
  }

  Future loadFiles() async {
    _startupStatus.add(StartupState.Busy);
    //fetching all userMetrics doesn't need to be awaited
    metricService.fetchAllMetrics();

    MessagingUtils.sendNewIsolateCommand(command: "LoadStarterFiles").then((value){
      List<Tune> newSongs = (value["songs"] as List<Map>).map((e) =>Tune.fromMap(e)).toList();
      List<Album> newAlbums =(value["albums"] as List<Map>).map((e) => Album.fromMap(e)).toList();
      List<Artist> newArtists = (value["artists"] as List<Map>).map((e) => Artist.fromMap(e)).toList();
      List<Playlist> newPlaylists = (value["playlists"] as List<Map>).map((e) => Playlist.fromMap(e)).toList();
      List<Tune> newFavs = (value["favs"] as List<Map>).map((e) => Tune.fromMap(e)).toList();
      bool newStartup = value["notNewStartup"]==null;
      musicService.songs$.add(newSongs);
      musicService.albums$.add(newAlbums);
      musicService.artists$.add(newArtists);
      musicService.playlists$.add(newPlaylists);
      musicService.favorites$.add(newFavs);
      if(newStartup){
        loadLastTimeSongsAndPlaylists();
      }
      _startupStatus.add(StartupState.Success);
    });
  }

  loadLastTimeSongsAndPlaylists(){
    //This will set the last song that was played as currently playing after an app reboot
    StreamSubscription metricsLoaded;
    metricsLoaded = metricService.metrics.listen((data) async{
      if(data!=null){
        List<Tune> lastPlayedSongs = data[MetricIds.MET_GLOBAL_LAST_PLAYED_SONGS];
        Playlist lastPlayedPlaylist = data[MetricIds.MET_GLOBAL_LAST_PLAYED_PLAYLIST];

        //Playlist update first
        if(lastPlayedPlaylist!=null){
          musicService.updatePlaylist(lastPlayedPlaylist.songs);
        }else{
          if(lastPlayedSongs.length!=0){
            musicService.updatePlaylist(musicService.songs$.value);
          }
        }

        if(lastPlayedSongs.length!=0){
          //A problem occurred here that the lastPlayedSongs[lastPlayedSongs.length-1] which is the last played song
          //doesn't ave the same reference as the same song in the songs lists that is generated when the app boots
          //and that is causing problems with songs.indexOF(song), it has been fixed elsewhere. This might be a further issue.
          musicService.updatePlayerState(PlayerState.paused, lastPlayedSongs[lastPlayedSongs.length-1]);
        }

        if(lastPlayedPlaylist!=null){
          musicService.updatePlaylistState(PlayerState.paused, lastPlayedPlaylist);
        }

        if(lastPlayedSongs.length!=0){
          //setting the position to Zero
          musicService.updatePosition(Duration(milliseconds: 0));
          ByteData dibd = await rootBundle.load("images/cover.png");
          List<int> defaultImageBytes = dibd.buffer.asUint8List();
          ByteData artistBundleImage = await rootBundle.load("images/artist.jpg");
          List<int> defaultBgImageBytes = artistBundleImage.buffer.asUint8List();
          Tune songToshowONNotification = musicService.playerState$.value.value;
          if(SettingsService.getOrCreateSingleSettingStream(SettingsIds.SET_CUSTOM_NOTIFICATION_PLAYBACK_CONTROL).value=="true"){
            Artist artist = musicService.artistsImages$.value!=null?musicService.artistsImages$.value[songToshowONNotification.artist]:null;
            NotificationService.show(
                title: '${songToshowONNotification.title?? "Unknown Title"}',
                author: '${songToshowONNotification.artist?? "Unknown Artist"}',
                play: false,
                image: songToshowONNotification.albumArt,
                BitmapImage:
                songToshowONNotification.albumArt == null ? defaultImageBytes : null,
                titleColor: songToshowONNotification.colors.length!=0?Color(songToshowONNotification.colors[1]): MyTheme.grey300,
                subtitleColor: songToshowONNotification.colors.length!=0?Color(songToshowONNotification.colors[1]).withAlpha(50): MyTheme.grey300,
                iconColor: songToshowONNotification.colors.length!=0?Color(songToshowONNotification.colors[1]): MyTheme.grey300,
                bigLayoutIconColor: artist.colors!=null && artist.colors.length!=0?Color(artist.colors[1]):null,
                bgImage: songToshowONNotification.artist!=null?artist.coverArt:null,
                bgBitmapImage: artist.coverArt==null? defaultBgImageBytes:null,
                bgImageBackgroundColor: (artist.colors!=null && artist.colors.length!=0)?Color(artist.colors[0]):MyTheme.darkBlack,
                bgColor: songToshowONNotification.colors.length!=0?Color(songToshowONNotification.colors[0]): MyTheme.grey300
            );
          }

          if(SettingsService.getOrCreateSingleSettingStream(SettingsIds.SET_ANDROID_NOTIFICATION_PLAYBACK_CONTROL).value=="true"){

            musicService.setAndroidNativeNotificationItem(
              title: songToshowONNotification.title,
              albumArt: songToshowONNotification.albumArt,
              album: songToshowONNotification.album,
              artist: songToshowONNotification.artist,
              uri: songToshowONNotification.uri
            ).then((itemSet){
              musicService.showAndroidNativeNotifications();
            });
          }
        }
        metricsLoaded.cancel();
      }
    });
  }

  Widget getDrawer(){
    return SideDrawerComponent(
      layoutService.sideDrawerKey,
        Scaffold(
          key: layoutService.scaffoldKey,
          bottomNavigationBar: BottomNavBar(),
          backgroundColor: MyTheme.darkBlack,
          body: StreamBuilder<StartupState>(
            stream: _startupStatus.stream,
            builder:
                (BuildContext context, AsyncSnapshot<StartupState> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data == StartupState.Busy) {
                return Container(
                  constraints: BoxConstraints.expand(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          strokeWidth: 5.0,
                        ),
                        Text(
                            "Scanning Your Library ...",
                            style: TextStyle(
                                color: MyTheme.darkRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                height: 2.0
                            )
                        )
                      ],
                    ),
                  ),
                );
              }
              return Theme(
                data: Theme.of(context).copyWith(accentColor: MyTheme.darkRed),
                child: Padding(
                  padding: MediaQuery.of(context).padding,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: CustomPageView(
                                    controller:
                                    layoutService.globalPageController,
                                    physics: NeverScrollableScrollPhysics(),
                                    //scrollDirection: Axis.horizontal,
                                    shallowWidget: Container(color: MyTheme.bgBottomBar),
                                    pages: [
                                      LibraryPage(),
                                      CollectionPage(),
                                      SettingsPage()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                alignment: Alignment.center,
                                color: MyTheme.darkBlack,
                                height: 50,
                                width: 53,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      drawerService.toggle();
                                    },
                                    child: Icon(
                                      IconData(0xeae9, fontFamily: 'boxicons'),
                                      size: 22,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ///If the playing panel is open, go back to the player page and then close it first
        if (!layoutService.globalPanelController.isPanelClosed()) {
          if(layoutService.albumPlayerPageController.page!=1){
            layoutService.albumPlayerPageController.jumpToPage(1);
          }else{
            layoutService.globalPanelController.close();
          }
        } else {
          ///If the panel is not open
          ///IF you are in the ALbums Page and you have opened the single page page
          if(layoutService.pageServices[0].pageViewController.hasClients && layoutService.albumListPageController.hasClients && layoutService.pageServices[0].pageViewController.page==2.0 && layoutService.albumListPageController.page>0.0){
            layoutService.albumListPageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
          }else{
            ///If you are not in the albumPage and did not open the single album page
            if(layoutService.pageServices[0].pageViewController.hasClients && layoutService.pageServices[0].pageViewController.page!=0.0){
              ///IF you are somewhere in the other pages like artist, or album  always go back to tracks
              layoutService.pageServices[0].pageViewController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
            }else{
              ///OtehrWise just put the app to backgRound
              _androidAppRetain.invokeMethod("sendToBackground");
              return Future.value(false);
            }
          }
        }
      },
      child: getDrawer(),
    );
  }
}
