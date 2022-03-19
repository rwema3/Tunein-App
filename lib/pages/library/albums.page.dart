import 'dart:io';

import 'package:Tunein/components/AlbumSongCell.dart';
import 'package:Tunein/components/gridcell.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:Tunein/services/uiScaleService.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/components/albumCard.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/pages/single/singleAlbum.page.dart';
import 'package:rxdart/rxdart.dart';

class AlbumsPage extends StatefulWidget {
  AlbumsPage({Key key, controller}) : super(key: key);

  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> with AutomaticKeepAliveClientMixin<AlbumsPage> {

  final musicService = locator<MusicService>();
  final SettingService = locator<settingService>();
  BehaviorSubject<Album> currentAlbum= new BehaviorSubject<Album>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    double albumGridCellHeight = uiScaleService.AlbumsGridCellHeight(size);

    return Container(
      child:  StreamBuilder(
        stream: Rx.combineLatest2(musicService.albums$, SettingService.getOrCreateSingleSettingStream(SettingsIds.SET_ALBUM_LIST_PAGE), (a, b) => MapEntry<List<Album>, String>(a,b)),
        builder: (BuildContext context,
            AsyncSnapshot<MapEntry<List<Album>,String>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          if(snapshot.data.key.length==0){
            return Container();
          }
          final _albums = snapshot.data.key;
          Map<LIST_PAGE_SettingsIds, String> UISettings = SettingService.DeserializeUISettings(snapshot.data.value);
          int itemsPerRow = int.tryParse(UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_GRID_ROW_ITEM_COUNT])??3;
          int animationDelay = int.tryParse(UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_BOX_FADE_IN_DURATION])??150;
          final double itemWidth = size.width / itemsPerRow;
          return GridView.builder(
            padding: EdgeInsets.all(0),
            itemCount: _albums.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemsPerRow,
              mainAxisSpacing: itemsPerRow.toDouble(),
              crossAxisSpacing: itemsPerRow.toDouble(),
              childAspectRatio: (itemWidth / (itemWidth + 50)),
            ),
            itemBuilder: (BuildContext context, int index) {
              int newIndex = (index%itemsPerRow)+2;
              return GestureDetector(
                onTap: () {
                  goToAlbumSongsList(_albums[index], context);
                },
                child: AlbumGridCell(_albums[index],
                  ((albumGridCellHeight*0.8)/itemsPerRow)*3,
                  albumGridCellHeight*0.20,
                  animationDelay: (animationDelay*newIndex) - (index<6?((6-index)*150):0),
                  useAnimation: !(animationDelay==0),
                  choices: albumCardContextMenulist,
                  onContextSelect: (choice){
                    switch(choice.id){
                      case 1: {
                        musicService.playEntireAlbum(_albums[index]);
                        break;
                      }
                      case 2:{
                        musicService.shuffleEntireAlbum(_albums[index]);
                        break;
                      }
                    }
                  },
                  Screensize: size,
                  onContextCancel: (option){
                    print("canceled");
                  },
                ),
              );
            },
          );

        },
      ),
    );
  }


  void goToAlbumSongsList(album, context) async {
      Size screenSize = MediaQuery.of(context).size;
      List<Tune> returnedSongs = await  Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SingleAlbumPage(null,
              album:album,
            heightToSubstract: 60,
          ),
        ),
      );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
