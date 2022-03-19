import 'dart:io';

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';


class PlaylistCell extends StatelessWidget {

  final Playlist playlistItem;
  VoidCallback onTap;
  List<ContextMenuOptions> choices;
  final void Function(ContextMenuOptions) onContextSelect;
  final void Function() onContextCancel;
  PlaylistCell({this.playlistItem, this.onTap, this.choices, this.onContextSelect, this.onContextCancel});

  final _textColor = Colors.white54;
  final _fontWeight = FontWeight.w400;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: MyTheme.darkgrey,
                  child:Container(
                    constraints: BoxConstraints.expand(),
                    child:  Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: SizedBox(
                            height: 62,
                            width: 62,
                            child: FadeInImage(
                              placeholder: AssetImage('images/track.png'),
                              fadeInDuration: Duration(milliseconds: 200),
                              fadeOutDuration: Duration(milliseconds: 100),
                              image: playlistItem.covertArt != null
                                  ? FileImage(
                                new File(playlistItem.covertArt),
                              )
                                  : AssetImage('images/track.png'),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  (playlistItem.name == null)
                                      ? "Unknon Title"
                                      : playlistItem.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: _fontWeight,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                (playlistItem.songs == null)
                                    ? "No songs"
                                    : "${playlistItem.songs.length} song(s)",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: _fontWeight,
                                  color: _textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: (){
                    onTap();
                  },
                ),
              ),
            ),
            flex: 12,
          ),
          Expanded(
            flex: 2,
            child: Material(
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
                          color: Colors.white70,
                        )
                    ),
                  ),
                ),
                elevation: 3.2,
                onCanceled: () {
                  print('You have not chosen anything');
                  onContextCancel();
                },
                tooltip: 'Playing options',
                onSelected: (ContextMenuOptions choice){
                  onContextSelect(choice);
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((ContextMenuOptions choice) {
                    return PopupMenuItem<ContextMenuOptions>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
