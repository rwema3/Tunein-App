import 'dart:io';

import 'package:Tunein/components/threeDotPopupMenu.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/globals.dart';

class ArtistGridCell extends StatelessWidget {
  final void Function(ContextMenuOptions) onContextSelect;
  final void Function(ContextMenuOptions) onContextCancel;
  List<ContextMenuOptions> choices;
  ArtistGridCell(this.artist, this.imageHeight, this.panelHeight,{this.onContextCancel, this.onContextSelect, this.choices,
    this.Screensize, this.StaticContextMenuFromBottom, this.useAnimation, this.animationDelay});
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  @required
  final Artist artist;
  final double imageHeight;
  final double panelHeight;
  final Size Screensize;
  final double StaticContextMenuFromBottom;
  bool useAnimation;
  int animationDelay;
  @override
  Widget build(BuildContext context) {
    List<int> songColors=(artist.colors!=null && artist.colors.length!=0)?artist.colors:null;
    int numberOfSongsPresentForThisArtist =countSongsInAlbums(artist.albums);
    Widget  shallowWidget;
    shallowWidget= Container(height: imageHeight+40, color: MyTheme.darkgrey.withOpacity(.01),);
    int animationDelayComputed = useAnimation?((animationDelay??0).isNegative?0:(animationDelay??0)):0;

    return StreamBuilder(
      stream: Future.delayed(Duration(milliseconds: 200), ()=>true).asStream(),
      builder: (context, AsyncSnapshot snapshot){
        Widget cellWidget =  Padding(
            padding: EdgeInsets.only(),
            child:Container(
                decoration: BoxDecoration(
                    color: (songColors!=null?new Color(songColors[0]).withAlpha(100):MyTheme.darkBlack).withOpacity(.7),
                    backgroundBlendMode: BlendMode.colorBurn
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    /* artist.coverArt == null ? Image.asset("images/artist.jpg",height: imageHeight+2, width: double.infinity, fit: BoxFit.cover) : Image(
                  image: FileImage(File(artist.coverArt)),
                  fit: BoxFit.fill,
                  height: imageHeight+2,
                  colorBlendMode: BlendMode.darken,
                ),*/
                    Container(
                      child: FadeInImage(
                        placeholder: AssetImage('images/artist.jpg'),
                        fadeInDuration: Duration(milliseconds: 300),
                        fadeOutDuration: Duration(milliseconds: 100),
                        height: imageHeight+2,
                        repeat: ImageRepeat.noRepeat,
                        fit: artist.coverArt != null?BoxFit.fill:BoxFit.cover,
                        image: artist.coverArt != null
                            ? FileImage(
                          new File(artist.coverArt),
                        )
                            : AssetImage('images/artist.jpg'),
                      ),
                      constraints: BoxConstraints.expand(height: imageHeight+2),
                    ),
                    Expanded(
                      child: Container(
                        height: panelHeight,
                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                        width: double.infinity,
                        color: songColors!=null?new Color(songColors[0]).withAlpha(225):MyTheme.darkgrey.withAlpha(70),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                artist.name!=null?artist.name:"Unknown Name",
                                overflow: TextOverflow.ellipsis,
                                strutStyle: StrutStyle(
                                    height: 1.1,
                                    forceStrutHeight: true
                                ),
                                style: TextStyle(
                                    fontSize: 13.5,
                                    color: (songColors!=null?new Color(songColors[1]):Color(0xffffffff)).withOpacity(.7),
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex:9,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        child: Text(
                                          artist.albums.length!=0?"${artist.albums.length} ${artist.albums.length>1?"Albums":"Album"}":"No Albums",
                                          overflow: TextOverflow.ellipsis,
                                          strutStyle: StrutStyle(
                                              height: 0.8,
                                              forceStrutHeight: true
                                          ),
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              color: (songColors!=null?new Color(songColors[1]):Color(0xffffffff)).withOpacity(.7)
                                          ),
                                        ),
                                        padding: EdgeInsets.only(bottom: 2),
                                      ),
                                      Text(
                                        artist.albums.length!=0?"${numberOfSongsPresentForThisArtist} ${numberOfSongsPresentForThisArtist>1?"Songs":"Song"}":"No Songs",
                                        overflow: TextOverflow.ellipsis,
                                        strutStyle: StrutStyle(
                                            height: 0.8,
                                            forceStrutHeight: true
                                        ),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: (songColors!=null?new Color(songColors[1]):Color(0xffffffff)).withOpacity(.7),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child:  choices!=null?ThreeDotPopupMenu(
                                    IconColor: (songColors!=null?new Color(songColors[1]):Color(0xffffffff)).withOpacity(.7)  ,
                                    choices: choices,
                                    onContextSelect: onContextSelect,
                                    screenSize: Screensize,
                                    staticOffsetFromBottom: StaticContextMenuFromBottom,
                                  ):Container(),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ))
        );

        if(animationDelayComputed==0){
          return cellWidget;
        }
        return AnimatedSwitcher(
            reverseDuration: Duration(milliseconds: animationDelayComputed),
            duration: Duration(milliseconds: animationDelayComputed),
            switchInCurve: Curves.easeInToLinear,
            child: !snapshot.hasData?shallowWidget:cellWidget);
      },
    );

  }

  int countSongsInAlbums(List<Album> albums){
    int count=0;
    albums.forEach((elem){
      count+=elem.songs.length;
    });
    return count;
  }

}

