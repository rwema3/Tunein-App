import 'dart:io';

import 'package:Tunein/components/itemListDevider.dart';
import 'package:Tunein/components/pagenavheader.dart';
import 'package:Tunein/components/scrollbar.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTuneInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    String fullName = "Mohamed Kadhem Mansour";
    String email = "kadhem03@gmail.com";
    String mode20GithubURL = "https://github.com/moda20";
    String mode20LinkedInURL = "https://www.linkedin.com/in/med-kadhem-mansour-984922a2/";
    String tuneInGithubURL = "https://github.com/moda20/flutter-tunein";
    String mediaNotificationGithubURL = "https://github.com/moda20/flutter_media_notification";
    String metaDataGithubURL = "https://github.com/moda20/flutter_file_meta_data";
    String audioPlayerGithubURL = "https://github.com/moda20/audioplayer";
    String GithubPortfolioURL = "https://moda20.github.io/Portfolio/";

    Size screenSize = MediaQuery.of(context).size;
    ScrollController descriptionTextController = new ScrollController();
    ScrollController aboutPageMainController = new ScrollController();
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: MediaQuery.of(context).padding,
        child: Column(
          children: <Widget>[
            PageNavHeader(
              pageIndex: 3,
            ),
            Flexible(
              child: Container(
                height: screenSize.height -140,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: CustomScrollView(
                          controller: aboutPageMainController,
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Material(
                                child: Container(
                                  height: 35,
                                  child: ItemListDevider(
                                    DeviderTitle: "TuneIn",
                                    backgroundColor: MyTheme.bgBottomBar,
                                  ),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  height: screenSize.height/3,
                                  color: MyTheme.bgBottomBar.withOpacity(.8),
                                  margin: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 15, right: 15
                                  ),
                                  child:  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: SingleChildScrollView(
                                            controller: descriptionTextController,
                                            child: RichText(
                                              strutStyle: StrutStyle(
                                                  forceStrutHeight: true,
                                                  height: 1.4
                                              ),
                                              text: TextSpan(
                                                text: "TuneIn is a music application built using Flutter. This project is not the first music player i have sought to do\", "
                                                    "in fact i already have an other project named \"Kadi\" which started high but quickly got way harder to continue developing it. "
                                                    "Tune in on the other hand started as a fork from a repository with the same name : \n",
                                                style: TextStyle(
                                                  color: MyTheme.grey300,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  letterSpacing: 1.2,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(text: 'https://github.com/Datlyfe/flutter-tunein', style: TextStyle(fontWeight: FontWeight.bold, color: MyTheme.darkRed)),
                                                  TextSpan(text: ". \n At first i liked the "
                                                      "initial aesthetics of the player and especially the state management concept it already used. My goal was first to finish the basic features like album and artist lists"
                                                      "but my reach grew wider and i started seeing how i can improve on the existing basic music player. During all of this i created and improved multiple plugins like the audioPlayer "
                                                      "and the custom layout notifications"),
                                                ],
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(top: 5, left: 5, bottom: 5),
                                        ),
                                        flex: 13,
                                      ),
                                      MyScrollbar(
                                        controller: descriptionTextController,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Material(
                                child: Container(
                                  height: 35,
                                  child: ItemListDevider(DeviderTitle: "The Creator: Moda20"),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  color: MyTheme.bgBottomBar,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: FadeInImage(
                                                placeholder: AssetImage('images/artist.jpg'),
                                                fadeInDuration: Duration(milliseconds: 200),
                                                fadeOutDuration: Duration(milliseconds: 100),
                                                image: null != null
                                                    ? FileImage(
                                                  new File(""),
                                                )
                                                    : AssetImage('images/artist.jpg'),
                                              ),
                                            ),
                                            flex: 4,
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Container(
                                              height: screenSize.width/3,
                                              /*margin: EdgeInsets.all(8).subtract(EdgeInsets.only(left: 8, right: 8))
                                  .add(EdgeInsets.only(top: 10)),*/
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                                                    child: Text(
                                                      fullName,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                        fontSize: 17.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                      "Moda20",
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.white,
                                                      ),
                                                      strutStyle: StrutStyle(
                                                          height: 0.9,
                                                          forceStrutHeight: true
                                                      )
                                                  ),
                                                  Text(
                                                      "A web, mobile developer and Crypto/Blockchain enthusiast",
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 2,
                                                      strutStyle: StrutStyle(
                                                          height: 1.4,
                                                          forceStrutHeight: true
                                                      )
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.only(right: 10, left :10),
                                              alignment: Alignment.topCenter,
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(IconData(0xE057, fontFamily: 'ligaturesymbols'),
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                              onPressed: (){
                                                openGithub(mode20GithubURL);
                                              },
                                              tooltip: "My github",
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.alternate_email,
                                                size: 25,
                                                color: Colors.amber,
                                              ),
                                              tooltip: "Email me",
                                              onPressed: (){
                                                openEmail(email);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(IconData(0xE083, fontFamily: 'ligaturesymbols'),
                                                size: 25,
                                                color: Color.fromRGBO( 1, 119, 181, 1),
                                              ),
                                              tooltip: "LinkedIn",
                                              onPressed: (){
                                                openLinkedIn(mode20LinkedInURL);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(IconData(0xE020, fontFamily: 'ligaturesymbols'),
                                                size: 25,
                                                color: Colors.green,
                                              ),
                                              tooltip: "Portfolio",
                                              onPressed: (){
                                                openBlog(GithubPortfolioURL);
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Material(
                                child: Container(
                                  height: 35,
                                  child: ItemListDevider(
                                    DeviderTitle: "Other Packages",
                                    backgroundColor: MyTheme.bgBottomBar,
                                  ),
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        child: Text("The following packages are part of TuneIn and are also maintained by Moda20",
                                          style: TextStyle(
                                            color: MyTheme.grey300,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            letterSpacing: 1.2,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        padding: EdgeInsets.only(
                                          bottom: 8, left: 10, right: 10, top: 8
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              SelectableTile.mediumWithSubtitle(
                                                title: "Media Notification",
                                                subtitle: "A custom player notification controls",
                                                leadingWidget: Icon(IconData(0xE057, fontFamily: 'ligaturesymbols'),
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                                onTap: (data){
                                                  openGithub(mediaNotificationGithubURL);
                                                },
                                              ),
                                              SelectableTile.mediumWithSubtitle(
                                                title: "AudioPlayer",
                                                subtitle: "An complete mp3 audio player",
                                                leadingWidget: Icon(IconData(0xE057, fontFamily: 'ligaturesymbols'),
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                                onTap: (data){
                                                  openGithub(audioPlayerGithubURL);
                                                },
                                              ),
                                              SelectableTile.mediumWithSubtitle(
                                                title: "File MetaData",
                                                subtitle: "A file meta data parser",
                                                leadingWidget: Icon(IconData(0xE057, fontFamily: 'ligaturesymbols'),
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                                onTap: (data){
                                                  openGithub(metaDataGithubURL);
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        padding: EdgeInsets.only(right: 10, left: 10, top: 10),
                      ),
                    ),
                    MyScrollbar(
                      controller: aboutPageMainController,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<bool> openEmail(String email){
    return _openUrl("mailto:${email}");
  }

  Future<bool> openGithub(String githubUrl){
    return _openUrl(githubUrl);
  }

  Future<bool> openLinkedIn(String linkedInUrl){
    return _openUrl(linkedInUrl);
  }

  Future<bool> openBlog(String blogURL){
    return _openUrl(blogURL);
  }


  Future<bool> _openUrl(String url) async {
    if (await canLaunch(url)) {
     return await launch(url);
    } else {
      return false;
    }
  }

}
