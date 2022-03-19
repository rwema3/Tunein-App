///DEPRECATED WARNING
/// /////////////////////////////////////////////////////////
///THIS HAS BEEN DEPRECATED AND MAY BE REMOVED IN THE FUTURE
/// /////////////////////////////////////////////////////////


import 'package:Tunein/components/card.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/songInfoWidget.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/single/singleArtistPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/routes/pageRoutes.dart';
import 'package:Tunein/values/contextMenus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:upnp/upnp.dart' as upnp;

class AlbumSongList extends StatefulWidget {

  final Album album;
  ScrollController controller;
  AlbumSongList(this.album, {ScrollController this.controller});

  @override
  _AlbumSongListState createState() => _AlbumSongListState();
}

class _AlbumSongListState extends State<AlbumSongList> {
  final musicService = locator<MusicService>();
  final castService = locator<CastService>();
  ScrollController controller;
  ScrollController parentController;
  @override
  void initState() {
    // TODO: implement initState
    controller = ScrollController();
    parentController = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return StreamBuilder(
      stream:  themeService.getThemeColors(widget.album.songs[0]).asStream(),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot){
        List<int> bgColor;

        bgColor=snapshot.data;

        return Container(
          alignment: Alignment.center,
          color: bgColor!=null?Color(bgColor[0]).withRed(30).withGreen(30).withBlue(30):MyTheme.darkBlack,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0).add(EdgeInsets.only(
                            left:10
                        )),
                        controller: controller,
                        shrinkWrap: true,
                        itemExtent: 62,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: widget.album.songs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Material(
                              child: PageHeader(
                                "Suffle",
                                "All Tracks",
                                MapEntry(
                                    IconData(Icons.shuffle.codePoint,
                                        fontFamily: Icons.shuffle.fontFamily),
                                    Colors.white),
                              ),
                              color: Colors.transparent,
                            );
                          }

                          int newIndex = index - 1;
                          return MyCard(
                            song: widget.album.songs[newIndex],
                            choices: songCardContextMenulist,
                            ScreenSize: screenSize,
                            StaticContextMenuFromBottom: 0.0,
                            onContextSelect: (choice) async{
                              switch(choice.id){
                                case 1: {
                                  musicService.playOne(widget.album.songs[newIndex]);
                                  break;
                                }
                                case 2:{
                                  musicService.startWithAndShuffleQueue(widget.album.songs[newIndex], widget.album.songs);
                                  break;
                                }
                                case 3:{
                                  musicService.startWithAndShuffleAlbum(widget.album.songs[newIndex]);
                                  break;
                                }
                                case 4:{
                                  musicService.playAlbum(widget.album.songs[newIndex]);
                                  break;
                                }
                                case 5:{
                                  if(castService.currentDeviceToBeUsed.value==null){
                                    upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                    if(result!=null){
                                      castService.setDeviceToBeUsed(result);
                                    }
                                  }
                                  musicService.castOrPlay(widget.album.songs[newIndex], SingleCast: true);
                                  break;
                                }
                                case 6:{
                                  upnp.Device result = await DialogService.openDevicePickingDialog(context, null);
                                  if(result!=null){
                                    musicService.castOrPlay(widget.album.songs[newIndex], SingleCast: true, device: result);
                                  }
                                  break;
                                }
                                case 7: {
                                  DialogService.showAlertDialog(context,
                                      title: "Song Information",
                                      content: SongInfoWidget(null, song: widget.album.songs[newIndex]),
                                      padding: EdgeInsets.only(top: 10)
                                  );
                                  break;
                                }
                                case 8:{

                                  break;
                                }
                                case 9:{
                                  PageRoutes.goToSingleArtistPage(widget.album.songs[0], context, subtract60ForBottomBar: true);
                                  break;
                                }
                                case 10:{
                                  PageRoutes.goToEditTagsPage(widget.album.songs[0], context, subtract60ForBottomBar: true);
                                  break;
                                }
                              }
                            },
                            onContextCancel: (choice){
                              print("Cancelled");
                            },
                            onTap: (){
                              musicService.updatePlaylist(widget.album.songs);
                              musicService.playOrPause(widget.album.songs[newIndex]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              MyScrollbar(
                controller: controller,
                color: bgColor!=null?Color(bgColor[0]).withRed(30).withGreen(30).withBlue(30):null,
              ),
            ],
          ),
        );
      },
    );

  }
}

