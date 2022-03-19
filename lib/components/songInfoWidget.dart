import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:flutter/material.dart';


class SongInfoWidget extends StatelessWidget {
  final musicService = locator<MusicService>();
  final Map infoEntry;
  Tune song;
  SongInfoWidget(this.infoEntry,{this.song});

  @override
  Widget build(BuildContext context) {
    if(infoEntry==null){
      return StreamBuilder(
        stream: musicService.getSongInformation(song).asStream(),
        builder: (context, AsyncSnapshot<Map<dynamic,dynamic>> snapshot){
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: !snapshot.hasData?Container(
              color: MyTheme.bgBottomBar,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(MyTheme.darkRed),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text("Getting Info",
                        style: TextStyle(
                            color: MyTheme.grey300,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ):songInfoWidgeItemList(snapshot.data),
          );
        },
      );
    }

    return songInfoWidgeItemList(infoEntry);
  }



  Widget songInfoWidgeItemList(Map<String, dynamic> infoEntry){
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.title,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["title"]??"No Title",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.person,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["artist"]??"No Artist",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.timer,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["duration"]!=null?ConversionUtils.DurationToFancyText(infoEntry["duration"]):"No Duration",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.album,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["album"]??"No Album",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.audiotrack,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["genre"]??"No genre",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.insert_drive_file,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: Text(
                      infoEntry["path"]??"No Path",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            ),
            Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.playlist_add_check,
                      color: MyTheme.grey300,
                      size: 17,
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: (infoEntry["playlist"]!=null && infoEntry["playlist"].length!=0)?
                    Column(
                        children: (infoEntry["playlist"] as List<Playlist>).map((e) {
                          return SelectableTile.mediumWithSubtitle(
                            imageUri: e.covertArt,
                            title: "Playlist: ${e.name}",
                            subtitle: "${e.songs.length} songs",
                          );
                        }).toList()
                    ):Text(
                      "Not part of a playlist",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          color: MyTheme.grey300
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 10),
            )
          ],
        ),
      ),
    );
  }
}
