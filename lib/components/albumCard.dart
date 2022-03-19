import 'dart:io';

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:flutter/cupertino.dart';
import 'package:Tunein/pages/single/singleAlbum.page.dart';

import '../globals.dart';
class AlbumCard extends StatelessWidget {

  final Album _album;
  final VoidCallback onTap;

  AlbumCard({Key key,@required Album album, this.onTap}):
        _album=album,
        super(key: key);


  @override
  Widget build(BuildContext context) {
    double paddingOnSide =4;
    double cardHeight=120;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Stack(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(paddingOnSide),
                  child: FadeInImage(
                    placeholder: AssetImage('images/track.png'),
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeOutDuration: Duration(milliseconds: 100),
                    image: _album.albumArt != null
                        ? FileImage(
                      new File(_album.albumArt),
                    )
                        : AssetImage('images/track.png'),
                    height: cardHeight,
                    fit: BoxFit.cover,
                  )),
              Positioned(
                child: Container(
                  width: (MediaQuery.of(context).size.width/3)-(paddingOnSide*2),
                  child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              (_album.title == null)
                                  ? "Unknon Title"
                                  : _album.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Text(
                            (_album.artist == null)
                                ? "Unknon Artist"
                                : _album.artist,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                  ),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      backgroundBlendMode: BlendMode.darken,
                      color: Colors.black87
                  ),
                ),
                bottom: 0,
              ),
            ],
            alignment: Alignment.center,
          ),
        ),
        enableFeedback: false,
        onTap: (){
          if(onTap!=null){
            onTap();
          }else{
            gotoFullAlbumPage(context,_album.songs[0]);
          }
        },
      ),
    );

  }


  gotoFullAlbumPage(context,Tune song){
    MyUtils.createDelayedPageroute(context, SingleAlbumPage(song),this);
  }
}
