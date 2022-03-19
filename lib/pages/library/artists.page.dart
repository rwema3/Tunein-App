import 'dart:io';

import 'package:Tunein/components/AlbumSongCell.dart';
import 'package:Tunein/components/ArtistCell.dart';
import 'package:Tunein/components/gridcell.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/single/singleArtistPage.dart';
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
import 'package:animations/animations.dart';

class ArtistsPage extends StatefulWidget {
  PageController controller;
  ArtistsPage({Key key, controller}) : this.controller = controller != null ? controller : new PageController(), super(key: key);

  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> with AutomaticKeepAliveClientMixin<ArtistsPage> {



  final musicService = locator<MusicService>();
  final SettingService = locator<settingService>();

  BehaviorSubject<Album> currentAlbum= new BehaviorSubject<Album>();
  ContainerTransitionType transitionType = ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    double artistGridCellHeight = uiScaleService.ArtistGridCellHeight(size);
    return Container(
      child:  StreamBuilder(
        stream: Rx.combineLatest2(musicService.artists$, SettingService.getOrCreateSingleSettingStream(SettingsIds.SET_ALBUM_LIST_PAGE), (a, b) => MapEntry<List<Artist>, String>(a,b)),
        builder: (BuildContext context,
            AsyncSnapshot<MapEntry<List<Artist>,String>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          if(snapshot.data.key.length==0){
            return Container();
          }
          final _artists = snapshot.data.key;
          Map<LIST_PAGE_SettingsIds, String> UISettings = SettingService.DeserializeUISettings(snapshot.data.value);
          int itemsPerRow = int.tryParse(UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_GRID_ROW_ITEM_COUNT])??3;
          int animationDelay = int.tryParse(UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_BOX_FADE_IN_DURATION])??150;
          final double itemWidth = size.width / itemsPerRow;
          return GridView.builder(
            padding: EdgeInsets.all(0),
            itemCount: _artists.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemsPerRow,
              mainAxisSpacing: itemsPerRow.toDouble(),
              crossAxisSpacing: itemsPerRow.toDouble(),
              childAspectRatio: (itemWidth / (itemWidth + 50)),
            ),
            itemBuilder: (BuildContext context, int index) {
              int newIndex = (index%itemsPerRow)+(itemsPerRow-1);
              return GestureDetector(
                onTap: () {
                  goToSingleArtistPage(_artists[index]);
                },
                child: ArtistGridCell(
                  _artists[index],
                  ((artistGridCellHeight*0.75)/itemsPerRow)*3,
                  artistGridCellHeight*0.25,
                  choices: artistCardContextMenulist,
                  animationDelay: (animationDelay*newIndex) - (index<6?((6-index)*150):0),
                  useAnimation: animationDelay!=0,
                  onContextSelect: (choice){
                    switch(choice.id){
                      case 1: {
                        musicService.playAllArtistAlbums(_artists[index]);
                        break;
                      }
                      case 2:{
                        musicService.suffleAllArtistAlbums(_artists[index]);
                        break;
                      }
                    }
                  },
                  onContextCancel: (choice){
                    print("Cancelled");
                  },
                  Screensize: size,
                ),
              );
            },
          );
        },
      ),
    );
  }




  void goToSingleArtistPage(Artist artist){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleArtistPage(artist, heightToSubstract: 60,),
      ),
    );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }


}
