import 'dart:io';

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/globals.dart';

class GridCell extends StatelessWidget {
  GridCell(this.song);
  final musicService = locator<MusicService>();
  final themeService = locator<ThemeService>();
  @required
  final Tune song;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: themeService.getThemeColors(song).asStream(),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        List<int> songColors;
        if(snapshot.hasData) {
          songColors=snapshot.data;
        }
        return AnimatedContainer(
          duration: Duration(milliseconds: 180),
            color: MyTheme.darkgrey,
            curve: Curves.fastOutSlowIn,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                song.albumArt == null ? Image.asset("images/cover.png") : Image
                    .file(File(song.albumArt)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    color: songColors!=null?new Color(songColors[0]).withAlpha(225):MyTheme.darkgrey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            song.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: (songColors!=null?new Color(songColors[1]):Colors.white70).withOpacity(.7),
                            ),
                          ),
                        ),
                        Text(
                          song.artist,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: (songColors!=null?new Color(songColors[1]):Colors.white70).withOpacity(.7)
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }
  }

