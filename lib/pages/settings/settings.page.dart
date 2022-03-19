import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Tunein/components/common/ShowWithFadeComponent.dart';
import 'package:Tunein/components/common/selectableTile.dart';
import 'package:Tunein/components/pagenavheader.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/pages/metrics/metrics.page.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/dialogService.dart';
import 'package:Tunein/services/fileService.dart';
import 'package:Tunein/services/layout.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:Tunein/utils/messaginUtils.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';


class SettingsPage extends StatefulWidget {
  PageController controller;
  SettingsPage({Key key, controller}) : this.controller = controller != null ? controller : new PageController(), super(key: key);

  _SettingsPageState createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin<SettingsPage> {

  final SettingService = locator<settingService>();
  final layoutService = locator<LayoutService>();
  final FileService = locator<fileService>();
  final musicService = locator<MusicService>();


  @override
  Widget build(BuildContext gcontext) {
    super.build(gcontext);
    Size screenSize = MediaQuery.of(gcontext).size;
    return Material(
      color: MyTheme.darkBlack,
      child: Column(
        children: <Widget>[
          PageNavHeader(
            pageIndex: 2,
          ),
          Flexible(
            child: PageView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: layoutService.pageServices[2].pageViewController,
              children: <Widget>[
                StreamBuilder(
                  stream: SettingService.settings$,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<SettingsIds,String>> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final _settings = snapshot.data;
                    return Container(
                      child: SettingsList(
                        backgroundColor: MyTheme.darkBlack,
                        textColor: MyTheme.grey300,
                        headingTextColor: MyTheme.darkRed,
                        sections: [
                          SettingsSection(
                            title: 'Region Settings',
                            tiles: [
                              SettingsTile(
                                title: 'Language',
                                subtitle: _settings[SettingsIds.SET_LANG],
                                leading: Icon(
                                  Icons.language,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () {
                                  changeSystemLanguage(gcontext, _settings[SettingsIds.SET_LANG]);
                                },
                              ),

                            ],
                          ),
                          SettingsSection(
                            title: 'Artists',
                            tiles: [
                              SettingsTile.switchTile(
                                title: 'Update Artist thumbnails',
                                subtitle: 'Automatically update artist thumbnails via the internet',
                                leading: Icon(
                                    Icons.update,
                                    color: MyTheme.grey300
                                ),
                                switchValue: _settings[SettingsIds.SET_ARTIST_THUMB_UPDATE]=="true",
                                onToggle: (bool value) async{
                                  print("got the value : ${value}");
                                  bool validityCheck = await checkDiscogAPIValidity(context);
                                  if(!validityCheck){
                                    DialogService.showAlertDialog(context,
                                      message: "Can't turn on this feature unless all necessary fields are correctly filled",
                                      title: "Feature not available"
                                    );
                                  }else{
                                    SettingService.updateSingleSetting(SettingsIds.SET_ARTIST_THUMB_UPDATE, value.toString());
                                    if(value){
                                      bool result = await DialogService.showConfirmDialog(context,
                                        message: "Do you want to start the thumbnail update NOW ?",
                                        title: "Start Thumbnail update",
                                        confirmButtonText: "Start Now"
                                      );
                                      if(result!=null && result){
                                        musicService.getArtistDataAndSaveIt().then((value) {
                                          DialogService.showToast(context,
                                            message: "Artist thumbnail update started",
                                            color: MyTheme.darkRed
                                          );
                                        });
                                      }
                                    }
                                  }
                                },
                              ),
                              SettingsTile(
                                title: 'Delete artist thumbnails',
                                subtitle: "Delete all downloaded artist thumbnails",
                                leading: Icon(
                                  Icons.broken_image,
                                  color: MyTheme.grey300,
                                ),
                                trailing: Material(
                                  color: MyTheme.bgBottomBar,
                                  elevation: 12,
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  child: IconButton(
                                    color: MyTheme.darkgrey,
                                    icon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.delete_sweep, color: MyTheme.darkRed, size: 20)
                                      ],
                                    ),
                                    onPressed: (){
                                      Future.delayed(Duration(milliseconds: 200), ()async{
                                        bool confirm = await DialogService.showConfirmDialog(context,
                                            title: "Confirm DELETING all thumbnails",
                                          cancelButtonText: "Cancel",
                                          confirmButtonText: "Delete All",
                                          message: "You are about to delete all downloaded artist thumbnails",
                                          titleColor: MyTheme.darkRed,
                                          messageColor: MyTheme.grey300
                                        );
                                        if(confirm!=null && confirm==true){
                                          int deletedNumber = await deleteAllArtistsThumbnail(context);
                                          DialogService.showToast(context,message: "Deleted ${deletedNumber} Thumbs", color: MyTheme.darkRed, backgroundColor: MyTheme.darkBlack.withOpacity(.7));
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SettingsTile(
                                title: 'Rescan Library',
                                subtitle: "Rescan Library for new and old songs",
                                leading: Icon(
                                  Icons.library_music,
                                  color: MyTheme.grey300,
                                ),
                                trailing: Material(
                                  color: MyTheme.bgBottomBar,
                                  elevation: 12,
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  child: IconButton(
                                    color: MyTheme.darkgrey,
                                    icon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.settings_overscan, color: MyTheme.darkRed, size: 20)
                                      ],
                                    ),
                                    onPressed: (){
                                      Future.delayed(Duration(milliseconds: 200), ()async{
                                        DialogService.showPersistentDialog(context,
                                          title: "Rescan Music Library",
                                          titleColor: MyTheme.grey300,
                                          content: Container(

                                            child: Center(
                                              heightFactor: 1,
                                              widthFactor: 1,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  CircularProgressIndicator(
                                                    strokeWidth: 3.5,
                                                    valueColor: AlwaysStoppedAnimation(MyTheme.darkRed),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 5),
                                                    child: Text("Scanning Library",
                                                      style: TextStyle(
                                                          color: MyTheme.grey300,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w700
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        );
                                        int resultedNewSongs = await musicService.rescanLibrary(context);
                                        Navigator.of(context, rootNavigator: true).pop();
                                        if(resultedNewSongs==0){
                                          DialogService.showToast(context,
                                              message: "No new songs found",
                                              color: MyTheme.darkRed,
                                              backgroundColor: MyTheme.darkBlack
                                          );
                                        }else{
                                          DialogService.showToast(context,
                                              message: "${resultedNewSongs} new songs found",
                                              color: MyTheme.darkRed,
                                              backgroundColor: MyTheme.darkBlack
                                          );

                                        }
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          SettingsSection(
                            title: 'Advanced Settings',
                            tiles: [
                              SettingsTile(
                                title: 'Discogs API Token',
                                subtitle: _settings[SettingsIds.SET_DISCOG_API_KEY]!=null?"key is set":"no key is set",
                                leading: Icon(
                                  Icons.vpn_key,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async {
                                  String newKey = await openDiscogKeyTypeDialog(gcontext, _settings[SettingsIds.SET_DISCOG_API_KEY]);
                                  if(newKey!=_settings[SettingsIds.SET_DISCOG_API_KEY] && newKey!=null){
                                    SettingService.updateSingleSetting(SettingsIds.SET_DISCOG_API_KEY, newKey);
                                  }
                                },
                              ),
                              SettingsTile(
                                title: 'Discogs thumbnail quality',
                                subtitle: _settings[SettingsIds.SET_DISCOG_THUMB_QUALITY],
                                leading: Icon(
                                  Icons.high_quality,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async {
                                  changeDiscogThumbnailDownloadQuality(gcontext, _settings[SettingsIds.SET_DISCOG_THUMB_QUALITY]);
                                },
                              ),
                              SettingsTile.switchTile(
                                title: 'Custom notification playback controls',
                                subtitle:"Show and hide the notification playback controls",
                                leading: Icon(
                                    Icons.play_circle_outline,
                                    color: MyTheme.grey300
                                ),
                                switchValue: _settings[SettingsIds.SET_CUSTOM_NOTIFICATION_PLAYBACK_CONTROL]=="true",
                                onToggle: (bool value) async{
                                  print("got the value : ${value}");

                                  SettingService.updateSingleSetting(SettingsIds.SET_CUSTOM_NOTIFICATION_PLAYBACK_CONTROL, value.toString());
                                },
                              ),
                              SettingsTile.switchTile(
                                title: 'Android native notification playback controls',
                                subtitle:"Show and hide the native android notification playback controls",
                                leading: Icon(
                                    Icons.play_circle_outline,
                                    color: MyTheme.grey300
                                ),
                                switchValue: _settings[SettingsIds.SET_ANDROID_NOTIFICATION_PLAYBACK_CONTROL]=="true",
                                onToggle: (bool value) async{
                                  print("got the value : ${value}");

                                  SettingService.updateSingleSetting(SettingsIds.SET_ANDROID_NOTIFICATION_PLAYBACK_CONTROL, value.toString());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                  },
                ),
                StreamBuilder(
                  stream: SettingService.getOrCreateSingleSettingStream(SettingsIds.SET_ALBUM_LIST_PAGE),
                  builder: (BuildContext context,
                      AsyncSnapshot<String> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final _settings = snapshot.data;
                    Map<LIST_PAGE_SettingsIds, String> UISettings = SettingService.DeserializeUISettings(_settings);
                    return Container(
                      child: SettingsList(
                        backgroundColor: MyTheme.darkBlack,
                        textColor: MyTheme.grey300,
                        headingTextColor: MyTheme.darkRed,
                        sections: [
                          SettingsSection(
                            title: 'Album List',
                            tiles: [
                              SettingsTile(
                                title: 'Album box animation duration',
                                subtitle: "${UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_BOX_FADE_IN_DURATION]} ms",
                                leading: Icon(
                                  Icons.av_timer,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  String newValue = await openChangeNumericalValueDialog(context,"${UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_BOX_FADE_IN_DURATION]} ms",
                                    title: "Change Animation Duration",
                                    hint: "*0 value will stop the animation completely"
                                  );
                                  if(newValue!=null && newValue!=""){
                                    saveAlbumPageSettingValue(LIST_PAGE_SettingsIds.ALBUMS_PAGE_BOX_FADE_IN_DURATION,newValue, UISettings);
                                  }
                                },
                              ),
                              SettingsTile(
                                title: 'Row\'s Item count',
                                subtitle: "${UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_GRID_ROW_ITEM_COUNT]} items per row",
                                leading: Icon(
                                  Icons.grid_on,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  String newValue = await openChangeNumericalValueDialog(context,"${UISettings[LIST_PAGE_SettingsIds.ALBUMS_PAGE_GRID_ROW_ITEM_COUNT]} items per row",
                                      title: "Change Item Count Per Row"
                                  );
                                  if(newValue!=null && newValue!=""){
                                    saveAlbumPageSettingValue(LIST_PAGE_SettingsIds.ALBUMS_PAGE_GRID_ROW_ITEM_COUNT,newValue, UISettings);
                                  }
                                },
                              ),

                            ],
                          ),
                          SettingsSection(
                            title: 'Artist List',
                            tiles: [
                              SettingsTile(
                                title: 'Artist box animation duration',
                                subtitle: "${UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_BOX_FADE_IN_DURATION]} ms",
                                leading: Icon(
                                  Icons.av_timer,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  String newValue = await openChangeNumericalValueDialog(context,"${UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_BOX_FADE_IN_DURATION]} ms",
                                      title: "Change Animation Duration",
                                      hint: "*0 value will stop the animation completely"
                                  );
                                  if(newValue!=null && newValue!=""){
                                    saveAlbumPageSettingValue(LIST_PAGE_SettingsIds.ARTISTS_PAGE_BOX_FADE_IN_DURATION,newValue, UISettings);
                                  }
                                },
                              ),
                              SettingsTile(
                                title: 'Row\'s Item count',
                                subtitle: "${UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_GRID_ROW_ITEM_COUNT]} items per row",
                                leading: Icon(
                                  Icons.grid_on,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  String newValue = await openChangeNumericalValueDialog(context,"${UISettings[LIST_PAGE_SettingsIds.ARTISTS_PAGE_GRID_ROW_ITEM_COUNT]} items per row",
                                      title: "Change Item Count Per Row"
                                  );
                                  if(newValue!=null && newValue!=""){
                                    saveAlbumPageSettingValue(LIST_PAGE_SettingsIds.ARTISTS_PAGE_GRID_ROW_ITEM_COUNT,newValue, UISettings);
                                  }
                                },
                              ),

                            ],
                          )
                        ],
                      ),
                    );

                  },
                ),
                MetricsPage(),
                StreamBuilder(
                  stream: SettingService.settings$,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<SettingsIds,String>> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final _settings = snapshot.data;
                    return Container(
                      child: SettingsList(
                        backgroundColor: MyTheme.darkBlack,
                        textColor: MyTheme.grey300,
                        headingTextColor: MyTheme.darkRed,
                        sections: [
                          SettingsSection(
                            title: 'Outgoing HTTP Server',
                            tiles: [
                              SettingsTile(
                                title: 'IP & Port',
                                subtitle: "${_settings[SettingsIds.SET_OUT_GOING_HTTP_SERVER_IP]}:${_settings[SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT]}",
                                leading: Icon(
                                  Icons.laptop_chromebook,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  MapEntry<String,String> newValue = await openHttpServerIpAndPort(context,_settings[SettingsIds.SET_OUT_GOING_HTTP_SERVER_IP],_settings[SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT]);
                                  bool changesHappened=false;
                                  if(newValue!=null){
                                    if(newValue.key!=null && newValue.key!=""){
                                      await saveSettingValue(SettingsIds.SET_OUT_GOING_HTTP_SERVER_IP,newValue.key);
                                      changesHappened=true;
                                    }
                                    if(newValue.value!=null && newValue.value!=""){
                                      await saveSettingValue(SettingsIds.SET_OUT_GOING_HTTP_SERVER_PORT,newValue.value);
                                      changesHappened=true;
                                    }
                                    if(changesHappened){
                                      DialogService.showToast(context,
                                          backgroundColor: MyTheme.darkBlack,
                                          color: MyTheme.darkRed,
                                          message: "Settings Saved",
                                          duration: 2
                                      );
                                    }
                                  }
                                },
                              ),
                              SettingsTile(
                                title: 'Externally Accessible File list',
                                subtitle: "A list of exposed files (that are accessible externally) via the HTTP server",
                                leading: Icon(
                                  Icons.insert_drive_file,
                                  color: MyTheme.grey300,
                                ),
                                onTap: () async{
                                  openNetworkOpenFileList(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                  },
                ),

                /*Container(
                  width: screenSize.width,
                  child: Center(
                    child: Text(
                      "SERVERS SETTINGS",
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                          fontSize: 40,
                          color: MyTheme.grey300,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                )*/
              ],
            ),
          )
        ],
      ),
    );

  }


  changeSystemLanguage(context, String current)async{
    String Language = await openLanguageSelectDialog(context, current);
    SettingService.updateSingleSetting(SettingsIds.SET_LANG, Language);
  }

  changeDiscogThumbnailDownloadQuality(context, String current)async{
    String quality = await openThumbDownloadQualityDialog(context, current);
    if(quality!=null){
      SettingService.updateSingleSetting(SettingsIds.SET_DISCOG_THUMB_QUALITY, quality);
    }
  }

  Future<MapEntry<String,String>> openHttpServerIpAndPort(context, String currentIp, String currentPort){
    String currentKey = "";
    String newIP="";
    String newPort;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            buttonPadding: EdgeInsets.all(5),
            insetPadding: EdgeInsets.all(12),
            title: Text(
              "Outgoing Ip address and Port",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Material(
              color: Colors.transparent,
              child: Container(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("**",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: MyTheme.grey300,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text("These changes will only work properly after app restart. Your casting will NOT work until you restart the app",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: MyTheme.grey300,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.2
                                  ),
                                ),
                                flex: 11,
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: TextField(
                                  autofocus: true,
                                  onChanged: (string){
                                    newIP=string;
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                      hintText: currentIp,
                                      hintStyle: TextStyle(
                                          color: MyTheme.grey500.withOpacity(0.6)
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.grey300.withOpacity(.7),
                                              style: BorderStyle.solid,
                                              width: 1
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.darkRed.withOpacity(.9),
                                              style: BorderStyle.solid,
                                              width: 2
                                          )
                                      ),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: "IP address",
                                      labelStyle: TextStyle(
                                        fontSize: 17,
                                        color: MyTheme.darkRed.withOpacity(.8),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.4,
                                      )
                                  ),
                                ),
                                margin: EdgeInsets.only(right: 8),
                              ),
                              flex: 8,
                            ),
                            Expanded(
                              child: Container(
                                child: TextField(
                                  autofocus: true,
                                  onChanged: (string){
                                    newPort=string;
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                      hintText: currentPort,
                                      hintStyle: TextStyle(
                                          color: MyTheme.grey500.withOpacity(0.6)
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.grey300.withOpacity(.7),
                                              style: BorderStyle.solid,
                                              width: 1
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.darkRed.withOpacity(.9),
                                              style: BorderStyle.solid,
                                              width: 2
                                          )
                                      ),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: "Port",
                                      labelStyle: TextStyle(
                                        fontSize: 17,
                                        color: MyTheme.darkRed.withOpacity(.8),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.4,
                                      )
                                  ),
                                ),
                                margin: EdgeInsets.only(right: 8),
                              ),
                              flex: 4,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                padding: EdgeInsets.all(0),
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                      color: MyTheme.grey300
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(MapEntry(newIP,newPort));
                },
              ),
              FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(null))
            ],
          );
        });
  }


  @override
  bool get wantKeepAlive {
    return true;
  }

  Future<bool> openNetworkOpenFileList(context){
    return DialogService.showAlertDialog(context,
      title: "Exposed File list",
      padding: EdgeInsets.all(10),
      content: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height/2.5,
          width: MediaQuery.of(context).size.width/1.3,
          child: StreamBuilder<dynamic>(
            stream: MessagingUtils.sendNewStandardIsolateCommand<Map<String,String>>(command: "getServedFilesList",message: "").asStream(),
            initialData: null,
            builder: (bcontext, AsyncSnapshot<dynamic> snapshot){
              if(snapshot.data==null){
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text("Looking For Files",
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
              if(snapshot.data.length==0){
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text("No Exposed Files",
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
              Map<String,MapEntry<String,String>> data =  snapshot.data as  Map<String,MapEntry<String,String>>;
              return Container(
                child: ListView(
                  children: data.map((key, value) {
                    List<String> parts = value.key.split("/");
                    String title = parts[parts.length-1];
                    return MapEntry(value.key,
                        SelectableTile.mediumWithSubtitle(
                          leadingWidget: FadeInImage(
                            placeholder: AssetImage('images/track.png'),
                            fadeInDuration: Duration(milliseconds: 200),
                            fadeOutDuration: Duration(milliseconds: 100),
                            image: value.value =="image/jpeg"
                                ? FileImage(
                              new File(value.key),
                            )
                                : AssetImage('images/track.png'),
                          ),
                          title: title.split(".")[0],
                          subtitle: value.key,
                        )
                    );
                  }).values.toList(),
                ),
              );
            },
          ),
        ),
      )
    );
  }
  Future<bool> checkDiscogAPIValidity(context) async{
    //This will check the validity of the discog API INFO stored in teh settings
    //in the future this should be a generic check for any API that can be used and exactly the API that is selected from a list

    Map<SettingsIds,String> currentSettings = SettingService.settings$.value;
    //checks in place
    //check for Token
    if(currentSettings[SettingsIds.SET_DISCOG_API_KEY]!=null){
      return true;
    }else{
      return false;
    }
  }


  Future<String> openLanguageSelectDialog(context, String current){

    void changeLanguage(String language) {
      Navigator.of(context, rootNavigator: true).pop(language);
    }

    bool isSelectedLanguage(String lang){
      return current==lang;
    }

    List<dynamic> languages = [
      "English",
      "Spanish",
      "Chinese",
      "German"
    ];

    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Select language",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Material(
              child: Container(
                height: MediaQuery.of(context).size.height/2.5,
                width: MediaQuery.of(context).size.width/1.2,
                child: SettingsList(
                  textColor: MyTheme.grey300,
                  sections: [
                    SettingsSection(
                      title: "Chose the language to use",
                        tiles: languages.map((lang){
                          return SettingsTile(
                            trailing: isSelectedLanguage(lang)?Icon(Icons.check, color: MyTheme.grey300):Icon(null),
                            title: lang,
                            onTap: () {
                              changeLanguage(lang);
                            },
                          );
                        }).toList().cast<SettingsTile>()
                    ),
                  ],
                ),
              ),
              color:Colors.transparent
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(null))
            ],
          );
        });
  }
  Future<String> openThumbDownloadQualityDialog(context, String current){

    void changeQuality(String language) {
      Navigator.of(context, rootNavigator: true).pop(language);
    }

    bool isSelectedquality(String lang){
      return current==lang;
    }

    List<dynamic> qualitites = [
      "Low",
      "Medium",
      "High",
    ];

    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Select Discog thumbnail download quality",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Material(
              child: Container(
                height: MediaQuery.of(context).size.height/2.5,
                width: MediaQuery.of(context).size.width/1.2,
                child: SettingsList(
                  textColor: MyTheme.grey300,
                  sections: [
                    SettingsSection(
                      title: "Chose the quality to use",
                        tiles: qualitites.map((quality){
                          return SettingsTile(
                            trailing: isSelectedquality(quality)?Icon(Icons.check, color: MyTheme.grey300):Icon(null),
                            title: quality,
                            onTap: () {
                              changeQuality(quality);
                            },
                          );
                        }).toList().cast<SettingsTile>()
                    ),
                  ],
                ),
              ),
              color:Colors.transparent
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(null))
            ],
          );
        });
  }

  Future<String> openDiscogKeyTypeDialog(context, String current){
    String currentKey = "";
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              "Discog API key",
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: TextField(
              autofocus: true,
              onChanged: (string){
                currentKey=string;
              },
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  hintText: "${current}",
                  hintStyle: TextStyle(
                      color: MyTheme.grey500.withOpacity(0.2)
                  )
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                      color: MyTheme.grey300
                  ),
                ),
                onPressed: (){
                  print("keyset is ${currentKey}");
                  Navigator.of(context, rootNavigator: true).pop(currentKey);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(null))
            ],
          );
        });
  }
  Future<String> openChangeNumericalValueDialog(context, String current, {String title="Change the numeric value", String hint}){
    String currentKey = "";
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: MyTheme.darkBlack,
            title: Text(
              title,
              style: TextStyle(
                  color: Colors.white70
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  onChanged: (string){
                    currentKey=string;
                  },
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      hintText: "${current}",
                      hintStyle: TextStyle(
                          color: MyTheme.grey500.withOpacity(0.2)
                      )
                  ),
                ),
                hint!=null?Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(hint,
                    style: TextStyle(
                        color: MyTheme.grey300.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w100,
                        fontSize: 13
                    ),
                  ),
                ):Container()
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Save Changes",
                  style: TextStyle(
                      color: MyTheme.grey300
                  ),
                ),
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop(currentKey);
                },
              ),
              FlatButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: MyTheme.darkRed
                    ),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(null))
            ],
          );
        });
  }




  Future saveSettingValue(SettingsIds setting, value){
    if(setting!=null){
      return SettingService.updateSingleSetting(setting, value);
    }
  }

  Future saveAlbumPageSettingValue(LIST_PAGE_SettingsIds albumPageSetting, value, Map<LIST_PAGE_SettingsIds,String> originalAlbumSettingListValue) async{
    if(albumPageSetting!=null){
      originalAlbumSettingListValue[albumPageSetting] = value;
      Map<String,String> TransformedMap = originalAlbumSettingListValue.map((key, value) => MapEntry(SettingService.getAlbumListEnumValue(key), value));
      print(TransformedMap);
      SettingService.updateSingleSetting(SettingsIds.SET_ALBUM_LIST_PAGE, json.encode(TransformedMap));
      return true;
    }else{
      return null;
    }
  }


  Future<int> deleteAllArtistsThumbnail(context) async{
    List<Artist> currentArtistList = musicService.artists$.value;
    List<String> UriList = currentArtistList.map((e) => (e.coverArt)).toList();
    DialogService.showPersistentDialog(context, title: "Deleting Files ...");
    UriList.forEach((element) async{
      await FileService.deleteFile(element);
    });
    musicService.artists$.add(currentArtistList.map((e) {
      e.coverArt=null;
      return e;
    }).toList());
    Navigator.of(context, rootNavigator: true).pop(null);
    return UriList.where((element) => (element!=null)).toList().length;
  }




}

