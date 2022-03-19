import 'dart:io';

import 'package:Tunein/components/threeDotPopupMenu.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/globals.dart';
import 'dart:math';
class AlbumGridCell extends StatelessWidget {
  AlbumGridCell(this.album, this.imageHeight, this.panelHeight,{
    this.animationDelay,
    this.useAnimation=false,
    this.choices,
    this.onContextSelect,
    this.onContextCancel,
    this.Screensize,
    this.StaticContextMenuFromBottom
  });
  final void Function(ContextMenuOptions) onContextSelect;
  final void Function(ContextMenuOptions) onContextCancel;
  List<ContextMenuOptions> choices;
  final Size Screensize;
  final double StaticContextMenuFromBottom;
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  @required
  final Album album;
  final double imageHeight;
  final double panelHeight;
  int animationDelay;
  bool useAnimation;
  @override
  Widget build(BuildContext context) {
    List<int> songColors;
    Widget  shallowWidget;
    shallowWidget= Container(height: imageHeight+40, color: MyTheme.darkgrey.withOpacity(.01),);
    int animationDelayComputed = useAnimation?((animationDelay??0).isNegative?0:(animationDelay??0)):0;
    return StreamBuilder<List<int>>(
      stream: themeService.getThemeColors(album.songs[0]).asStream(),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {

        if(snapshot.hasData) {
          songColors=snapshot.data;
        }
        Widget cellColumn = Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            album.albumArt == null ? Image.asset("images/cover.png",height: imageHeight+2,fit: BoxFit.cover,) : FadeInImage(
              image: FileImage(File(album.albumArt)),
              fit: BoxFit.fill,
              height: imageHeight+2,
              placeholder: AssetImage("images/cover.png"),
            ),
            Expanded(
              child: Container(
                color: MyTheme.darkgrey,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  width: double.infinity,
                  color: songColors!=null?new Color(songColors[0]).withAlpha(225):MyTheme.darkgrey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3, left: 2),
                        child: Text(
                            album.title!=null?album.title:"Unknown Title",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: (songColors!=null?new Color(songColors[1]):Colors.white70).withOpacity(.7),
                            ),
                            strutStyle: StrutStyle(
                                height: 0.95,
                                forceStrutHeight: true
                            )
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            flex:9,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                album.artist!=null?album.artist:"Unknown Artist",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                strutStyle: StrutStyle(
                                    height: 0.8,
                                    forceStrutHeight: true
                                ),
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: (songColors!=null?new Color(songColors[1]):Colors.white70).withOpacity(.7)
                                ),
                              ),
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
              ),
            )
          ],
        );
        if(animationDelayComputed==0){
          return cellColumn;
        }
        return AnimatedSwitcher(
          reverseDuration: Duration(milliseconds: animationDelayComputed),
          duration: Duration(milliseconds: animationDelayComputed),
            switchInCurve: Curves.easeInToLinear,
            child: !snapshot.hasData?shallowWidget:cellColumn);
      },
    );
  }
  }

