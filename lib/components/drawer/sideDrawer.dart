


import 'dart:io';

import 'package:Tunein/components/drawer/DrawerControls.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/components/smallControlls.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/pages/single/AboutPage.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:marquee/marquee.dart';

class SideDrawerComponent extends StatelessWidget {


  Key _innerDrawerKey;
  Widget insideWidget;
  final musicService = locator<MusicService>();

  SideDrawerComponent(this._innerDrawerKey, this.insideWidget);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: musicService.playerState$,
      builder: (context, AsyncSnapshot<MapEntry<PlayerState, Tune>> snapshot){
        bool dataON = snapshot.hasData;
        MapEntry<PlayerState,Tune> data = snapshot.data;
        Color primaryColor = (dataON && data.value.colors!=null && data.value.colors.length!=0)?Color(data.value.colors[0]):MyTheme.darkBlack;
        Color secondaryColor = (dataON && data.value.colors!=null && data.value.colors.length!=0)?Color(data.value.colors[1]):MyTheme.grey300;
        return InnerDrawer(
          key: _innerDrawerKey,
          onTapClose: true, // default false
          swipe: true, // default true
          colorTransitionChild: MyTheme.darkRed.withOpacity(.5), // default Color.black54
          colorTransitionScaffold: Colors.black54, // default Color.black54

          offset: IDOffset.only(bottom: 0, right: 0.0, left: 0.0),

          scale: IDOffset.horizontal( 1 ), // set the offset in both directions

          proportionalChildArea : true,
          borderRadius: 10,
          leftAnimationType: InnerDrawerAnimation.static,
          rightAnimationType: InnerDrawerAnimation.quadratic,
          backgroundDecoration: BoxDecoration(color: dataON && data.value.colors.length!=0?Color(data.value.colors[0]):MyTheme.bgBottomBar,  ),
          onDragUpdate: (double val, InnerDrawerDirection direction) {

          },
          leftChild: Material(
            color: Colors.transparent,
            child: dataON?Container(
              margin: MediaQuery.of(context).padding,
              child: Center(
                child:  CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          padding: EdgeInsets.all(5),
                          child: FadeInImage(
                            placeholder: AssetImage('images/track.png'),
                            fadeInDuration: Duration(milliseconds: 200),
                            fadeOutDuration: Duration(milliseconds: 100),
                            image: dataON && data.value.albumArt != null
                                ? FileImage(
                              new File(data.value.albumArt),
                            )
                                : AssetImage('images/track.png'),
                          ),
                        ),
                        elevation: 12,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            child: (data.value.title.length<25)?Text(
                              (data.value.title == null)
                                  ? "Unknon Title"
                                  : data.value.title,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              textWidthBasis: TextWidthBasis.parent,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: secondaryColor.withAlpha(200),
                              ),
                            ): Container(
                              height: 15,
                              child: Marquee(
                                text: (data.value.title == null)
                                    ? "Unknon Title"
                                    : data.value.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryColor.withAlpha(200),
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: data.value.title.length*2.0,
                                velocity: (data.value.title == null)?30.0:data.value.title.length*1.2,
                                pauseAfterRound: Duration(seconds: (1+data.value.title.length*0.110).floor()),
                                startPadding: 0.0,
                                accelerationDuration: Duration(milliseconds: (data.value.title == null)?500:data.value.title.length*40),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: Duration(milliseconds: (data.value.title == null)?500:data.value.title.length*30),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                            padding: EdgeInsets.only(bottom: 10),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Text(
                              (data.value.artist == null)
                                  ? "Unknown Artist"
                                  : data.value.artist,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: secondaryColor.withAlpha(100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(right: 20, left:20),
                        child: DrawerMusicControls(entrySong: data.value, entryState: data.key),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            SelectableTile(
                              leadingWidget: Icon(
                                Icons.info_outline,
                                color: secondaryColor,
                                size: 28,
                              ),
                              title: "About TuneIn",
                              onTap: (data){
                                openAboutPage(context);
                              },
                            ),
                            SelectableTile(
                              leadingWidget: Icon(
                                Icons.star,
                                color: MyTheme.darkRed,
                                size: 28,
                              ),
                              title: "Source Code",
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ):Container(),
          ), // required if rightChild is not set
          //rightChild: Container(), // required if leftChild is not set

          //  A Scaffold is generally used but you are free to use other widgets
          // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
          scaffold: insideWidget??Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false
            ),
          ),
        );
      },
    );
  }


  openAboutPage(context){
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => AboutTuneInPage(),
      ),
    );
  }
}
