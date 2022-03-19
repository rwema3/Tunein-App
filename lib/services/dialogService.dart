import 'dart:io';

import 'package:Tunein/components/common/ShowWithFadeComponent.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/plugins/upnp.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:rxdart/rxdart.dart';
import 'package:upnp/upnp.dart' as upnp;
import 'locator.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/services/layout.dart';
import 'package:flushbar/flushbar.dart';
import 'package:toast/toast.dart';

final layoutService = locator<LayoutService>();
final castService = locator<CastService>();

class DialogService{

  static showBasicDialog(context,{message}){
    return YYDialog().build(context)
      ..width = 220
      ..height = 500
      ..barrierColor =MyTheme.bgdivider.withOpacity(.3)
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: Text(message),
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..borderRadius = 4.0
      ..show();
  }

  static showToast(context, {String message, Color color, Color backgroundColor, int duration}){
    Toast.show(message, context,
      textStyle:  TextStyle(
        color: color??MyTheme.grey300
      ),
      duration: duration??2,
      gravity: 0,
      backgroundRadius : 2,
      backgroundColor: backgroundColor??MyTheme.bgBottomBar.withOpacity(0.7),
      rootNavigator: true,
    );
  }

  static showFlushbar(context, {String message, String title, Color color, Widget titleText, Widget messageText, Duration showDuration, Icon leftIcon}){
    Flushbar(
      icon: leftIcon,
      title:  title,
      titleText: titleText,
      message:  message,
      messageText: messageText,
      borderRadius: 2,
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 200),
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.linearToEaseOut,
      duration:  showDuration??Duration(milliseconds: 1000),
    )..show(context);
  }

  static Future<bool> showConfirmDialog(context, {String message, Color titleColor, Color messageColor ,String title, String confirmButtonText, String cancelButtonText}){
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              title,
              style: TextStyle(
                  color: titleColor!=null?titleColor:Colors.white70
              ),
            ),
            content: Text(
              message!=null?message:"Confirm?",
              style: TextStyle(
                color: messageColor!=null?messageColor:Colors.white
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  confirmButtonText??"CONFIRM",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
              ),
              FlatButton(
                  child: Text(
                    cancelButtonText??"Cancel",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(false))
            ],
          );
        });
  }
  static Future<bool> showAlertDialog(context, {String message, Color titleColor, Color messageColor ,String title, Widget content, EdgeInsets padding}){
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            insetPadding: padding,
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              title,
              style: TextStyle(
                  color: titleColor!=null?titleColor:Colors.white70
              ),
            ),
            content: content??Text(
              message!=null?message:"Alert",
              style: TextStyle(
                color: messageColor!=null?messageColor:Colors.white
              ),
            ),
            //contentPadding: padding??EdgeInsets.fromLTRB(24.0,20.0,24.0,24.0),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: MyTheme.darkRed
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
              ),
            ],
          );
        });
  }

  static Future<upnp.Device> openDevicePickingDialog(context, List<upnp.Device> devices,{ Widget content}){
    Widget devicesNotSent;
    Widget ShallowWidget = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: MyTheme.darkgrey.withOpacity(.01),
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
              child: Text("No devices registered",
                style: TextStyle(
                    color: MyTheme.grey300,
                    fontSize: 18
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text("Searching for devices",
                style: TextStyle(
                    color: MyTheme.grey300,
                    fontSize: 17
                ),
              ),
            )
          ],
        ),
      ),
    );
    if(devices==null){
      devicesNotSent = StreamBuilder(
        stream: castService.searchForDevices().asStream(),
        builder: (context, AsyncSnapshot<List<upnp.Device>> snapshot){
          devices=snapshot.data;
          Widget animtableChild;
          if(!snapshot.hasData){
            animtableChild=ShallowWidget;
          }else{
            if(devices.length!=0){
              animtableChild = ListView.builder(
                padding: EdgeInsets.all(3),
                itemBuilder: (context, index){
                  upnp.Device device = devices[index];
                  return SelectableTile.mediumWithSubtitle(
                    subtitle: "IP : ${Uri.parse(device.url).host}",
                    initialSubtitleColor: MyTheme.grey300.withOpacity(.7),
                    imageUri:null,
                    title: device.friendlyName,
                    isSelected: false,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      Navigator.of(context, rootNavigator: true).pop(device);
                    },
                    placeHolderAssetUri: "images/blackbgUpnp.png",
                  );
                },
                semanticChildCount: devices.length,
                cacheExtent: 60,
                itemCount: devices.length,
              );
            }else{
              animtableChild= Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text("No Devices Found",
                        style: TextStyle(
                            color: MyTheme.grey300,
                            fontSize: 17
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          }
          return AnimatedSwitcher(
            reverseDuration: Duration(milliseconds: 300),
            duration: Duration(milliseconds: 300),
            switchInCurve: Curves.easeInToLinear,
            child:animtableChild,
          );
        },
      );
    }
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Choosing Cast Devices",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: content??Container(
              height: MediaQuery.of(context).size.height/2.5,
              width: MediaQuery.of(context).size.width/1.2,
              child: devices==null?devicesNotSent:devices.length!=0?ListView.builder(
                padding: EdgeInsets.all(3),
                itemBuilder: (context, index){
                  upnp.Device device = devices[index];
                  return SelectableTile(
                    imageUri:null,
                    title: device.friendlyName,
                    isSelected: false,
                    selectedBackgroundColor: MyTheme.darkRed,
                    onTap: (willItBeSelected){
                      Navigator.of(context, rootNavigator: true).pop(device);
                    },
                    placeHolderAssetUri: "images/blackbgUpnp.png",
                  );
                },
                semanticChildCount: devices.length,
                cacheExtent: 60,
                itemCount: devices.length,
              ):Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text("No Devices Found",
                        style: TextStyle(
                            color: MyTheme.grey300,
                            fontSize: 17
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop())
            ],
          );
        });

  }


  static Future<dynamic> openImagePickingDialog(context, List<Album> albums){
    PageController controller= PageController(initialPage: 1);
    BehaviorSubject<MediaCollection> selectedCollections = new BehaviorSubject<MediaCollection>();
    int albumItemsPerRow= 3;
    double height = MediaQuery.of(context).size.height*.60;
    Widget Content = Container(
      height: height,
      width: MediaQuery.of(context).size.width*.90,
      child: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          GestureDetector(
            onHorizontalDragEnd: (dragDetails){
              print(dragDetails.primaryVelocity);
              if(dragDetails.primaryVelocity<500){
                controller.animateToPage(1,duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
              }
            },
            child: FutureBuilder(
              future: Future.sync(() => albums.where((element) => element.albumArt!=null).map((e) => e.albumArt).toList()),
              builder: (context, AsyncSnapshot<List<String>> snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                    ),
                  );
                }
                List<String> urlList = snapshot.data;
                return Container(
                  child: GridView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: urlList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: albumItemsPerRow,
                      mainAxisSpacing: albumItemsPerRow.toDouble(),
                      crossAxisSpacing: albumItemsPerRow.toDouble(),
                      childAspectRatio: (100 / (100 + 50)),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop(Future.sync(() => File(urlList[index])));
                        },
                        child: FadeInImage(
                          placeholder: AssetImage('images/track.png'),
                          fadeInDuration: Duration(milliseconds: 200),
                          fadeOutDuration: Duration(milliseconds: 100),
                          image: urlList[index] != null
                              ? FileImage(
                            new File(urlList[index]),
                          )
                              : AssetImage('images/track.png'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Container(
                      child: Center(
                        child: Text("Existent Albums",
                            style: TextStyle(
                                color: MyTheme.grey300,
                                fontSize: 25
                            )
                        ),
                      ),
                      height: height/2,
                    ),
                    onTap: (){
                      controller.animateToPage(0,duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                    },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Container(
                      height: height/2,
                      child: Center(
                        child: Text("Photo Library",
                            style: TextStyle(
                                color: MyTheme.grey300,
                                fontSize: 25
                            )
                        ),
                      ),
                    ),
                    onTap: (){
                      controller.animateToPage(2,duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                    },
                  ),
                ),

              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragEnd: (dragDetails){
              print(dragDetails.primaryVelocity);
              if(dragDetails.primaryVelocity>500){
                controller.animateToPage(1,duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
              }
            },
            child: FutureBuilder(
              future: MediaGallery.listMediaCollections(
                mediaTypes: [MediaType.image, MediaType.video],
              ),
              builder: (context, AsyncSnapshot<dynamic> snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                    ),
                  );
                }
                List<MediaCollection> collections = snapshot.data;
                int itemsPerRow= 3;
                return GridView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: collections.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: itemsPerRow,
                    mainAxisSpacing: itemsPerRow.toDouble(),
                    crossAxisSpacing: itemsPerRow.toDouble(),
                    childAspectRatio: (100 / (100 + 50)),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        selectedCollections.add(collections[index]);
                        controller.animateToPage(3, duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                      },
                      child: ShowWithFade.fromStream(
                        inStream: collections[index].getThumbnail(width: 120, height: 135, highQuality: true).then(
                                (value) => Image.memory(value)
                        ).asStream(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
              child : GestureDetector(
                onHorizontalDragEnd: (dragDetails){
                  print(dragDetails.primaryVelocity);
                  if(dragDetails.primaryVelocity>500){
                    controller.animateToPage(2,duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
                  }
                },
                child: StreamBuilder(
                  stream: selectedCollections.asyncMap((event) => event.getMedias(mediaType: MediaType.image)),
                  builder: (context, AsyncSnapshot<dynamic> snapshot){
                    if(!snapshot.hasData){
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5.0,
                        ),
                      );
                    }
                    MediaPage pageCollections = snapshot.data;
                    List<Media> mediaCollection = pageCollections.items;
                    int itemsPerRow= 3;
                    return GridView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: mediaCollection.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: itemsPerRow,
                        mainAxisSpacing: itemsPerRow.toDouble(),
                        crossAxisSpacing: itemsPerRow.toDouble(),
                        childAspectRatio: (120 / (120 + 50)),
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        int newIndex = (index%itemsPerRow)+2;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop(mediaCollection[index].getFile());
                          },
                          child: ShowWithFade.fromStream(
                            inStream: mediaCollection[index].getThumbnail(width: 120, height: 135, highQuality: true).then(
                                    (value) => Image.memory(value)
                            ).asStream(),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
          )
        ],
      ),
    );
    return DialogService.showPersistentDialog(context, content:
    Content,
        title: "Pick a photo",
        padding: EdgeInsets.all(12).add(EdgeInsets.only(top:8))
    );
  }

  static Future<dynamic> showPersistentDialog(context, {String message, Color titleColor, Color messageColor ,String title, Widget content, EdgeInsets padding= const EdgeInsets.all(24), bool showCancelAction = false}){
    return showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        useSafeArea: false,
        builder: (_) {
          return AlertDialog(
            contentPadding: padding,
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              title,
              style: TextStyle(
                  color: titleColor!=null?titleColor:Colors.white70
              ),
            ),
            content: content??Text(
              message!=null?message:"Alert",
              style: TextStyle(
                  color: messageColor!=null?messageColor:Colors.white
              ),
            ),
            actions: <Widget>[
              if(showCancelAction)
                FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(false))
            ],
          );
        });
  }
}

