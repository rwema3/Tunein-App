


import 'package:Tunein/components/Tune/songTags.dart';
import 'package:Tunein/pages/single/singleAlbum.page.dart';
import 'package:Tunein/pages/single/singleArtistPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final musicService = locator<MusicService>();

class PageRoutes{


  static void goToAlbumSongsList(Tune song, context, {Album album, bool subtract60ForBottomBar=false, bool rootRouter=false}){
    Album targetAlbum = album??musicService.getAlbumFromSong(song);
    if(targetAlbum!=null){
      Navigator.of(context, rootNavigator: rootRouter).push(
        MaterialPageRoute(
          builder: (context) => SingleAlbumPage(null,
            album:targetAlbum,
            heightToSubstract: subtract60ForBottomBar?60:0,
          ),
        ),
      );
    }
  }

  static void goToSingleArtistPage(Tune song, context, {Artist artist, bool subtract60ForBottomBar=false, bool rootRouter=false}){
    Artist targetArtist = artist??musicService.getArtistTitle(song.artist);
    if(targetArtist!=null){
      Navigator.of(context, rootNavigator: rootRouter).push(
        MaterialPageRoute(
          builder: (context) => SingleArtistPage(targetArtist, heightToSubstract: subtract60ForBottomBar?60:0),
        ),
      );
    }
  }

  static void goToEditTagsPage(Tune song, context, {bool subtract60ForBottomBar=false, bool rootRouter=false}){
    if(song!=null){
      Navigator.of(context, rootNavigator: rootRouter).push(
        MaterialPageRoute(
          builder: (context) => SongTags(song, heightToSubtract: subtract60ForBottomBar?60:0),
        ),
      );
    }
  }
}