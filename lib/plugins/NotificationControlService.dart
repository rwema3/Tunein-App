import 'dart:convert';
import 'dart:isolate';

import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';



class notificationControlService{
  final MusicServiceIsolate = locator<musicServiceIsolate>();

  notificationControlService();

  Future sendNewIsolateCommand({@required String command, String message=""}){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: command,
        message: message
    ));
    return tempPort.forEach((data){
      if(data!="OK"){
        tempPort.close();
        return data;
      }
    });
  }

  Future show({
    String title,
    String author,
    bool play,
    String image,
    List<int> BitmapImage,
    String bgImage,
    Color bgImageBackgroundColor,
    List<int> bgBitmapImage,
    Color titleColor,
    Color subtitleColor,
    Color iconColor,
    Color bigLayoutIconColor,
    Color bgColor,
  }) async{
    String messageToSend = json.encode({
      "title":title??"",
      "author":author??"",
      "bgImage":bgImage,
      "bgBitmapImage": bgBitmapImage,
      "bgImageBackgroundColor":bgImageBackgroundColor!=null?bgImageBackgroundColor.value.toString():Colors.white,
      "play":play??false,
      "image":image??null,
      "BitmapImage":BitmapImage??null,
      "titleColor":titleColor!=null?titleColor?.value.toString():Colors.white,
      "subtitleColor":subtitleColor!=null?subtitleColor?.value.toString():Colors.white,
      "iconColor":iconColor!=null?iconColor?.value.toString():Colors.white,
      "bigLayoutIconColor":bigLayoutIconColor?.value.toString(),
      "bgColor":bgColor!=null?bgColor?.value.toString():Colors.black
    });
    sendNewIsolateCommand(
      command: "showNotification",
      message: messageToSend
    ).then((value) {
      return value;
    });
  }


  Future hide() async{
    return await sendNewIsolateCommand(
      command: "hideNotification",
      message: ""
    );
  }

  BehaviorSubject<dynamic> subscribeToPlayButton(){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: "subscribeToPlay",
        message: ""
    ));

    BehaviorSubject<dynamic> returnedSubject= new BehaviorSubject<dynamic>();
    tempPort.forEach((data){
      if(data!=null && data!="OK"){
        returnedSubject.add(data);
      }
    });
    /*returnedSubject.doOnCancel(() {
      tempPort.close();
    });*/
    return returnedSubject;
  }

  BehaviorSubject<dynamic> subscribeToPauseButton(){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: "subscribeToPause",
        message: ""
    ));

    BehaviorSubject<dynamic> returnedSubject= new BehaviorSubject<dynamic>();
    tempPort.forEach((data){
      if(data!=null && data!="OK"){
        returnedSubject.add(data);
      }
    });
    /*returnedSubject.doOnCancel(() {
      tempPort.close();
    });*/
    return returnedSubject;
  }
  BehaviorSubject<dynamic> subscribeToPrevButton(){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: "subscribeToPrev",
        message: ""
    ));

    BehaviorSubject<dynamic> returnedSubject= new BehaviorSubject<dynamic>();
    tempPort.forEach((data){
      if(data!=null && data!="OK"){
        returnedSubject.add(data);
      }
    });
    /*returnedSubject.doOnCancel(() {
      tempPort.close();
    });*/
    return returnedSubject;
  }
  BehaviorSubject<dynamic> subscribeToNextButton(){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: "subscribeToNext",
        message: ""
    ));

    BehaviorSubject<dynamic> returnedSubject= new BehaviorSubject<dynamic>();
    tempPort.forEach((data){
      if(data!=null && data!="OK"){
        returnedSubject.add(data);
      }
    });
    /*returnedSubject.doOnCancel(() {
      tempPort.close();
    });*/
    return returnedSubject;
  }
  BehaviorSubject<dynamic> subscribeToSelectButton(){
    ReceivePort tempPort = ReceivePort();
    MusicServiceIsolate.sendCrossPluginIsolatesMessage(CrossIsolatesMessage<String>(
        sender: tempPort.sendPort,
        command: "subscribeToSelect",
        message: ""
    ));

    BehaviorSubject<dynamic> returnedSubject= new BehaviorSubject<dynamic>();
    tempPort.forEach((data){
      if(data!=null && data!="OK"){
        returnedSubject.add(data);
      }
    });
    /*returnedSubject.doOnCancel(() {
      tempPort.close();
    });*/
    return returnedSubject;
  }


  Future setNotificationTo(bool value) async{
    return await sendNewIsolateCommand(
        command: "setTo",
        message: value.toString()
    );
  }

  Future setNotificationStatusIcon(String iconName) async{
    return await sendNewIsolateCommand(
        command: "setStatusIcon",
        message: iconName.toString()
    );
  }

  Future setNotificationTitle(String iconName) async{
    return await sendNewIsolateCommand(
        command: "setTitle",
        message: iconName.toString()
    );
  }
  Future setNotificationSubtitle(String iconName) async{
    return await sendNewIsolateCommand(
        command: "setSubtitle",
        message: iconName.toString()
    );
  }
  Future toggleNotificationPlayPause() async{
    return await sendNewIsolateCommand(
        command: "togglePlaypauseButton",
        message: ""
    );
  }



}