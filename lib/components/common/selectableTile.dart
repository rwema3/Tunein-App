import 'dart:io';

import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';





class SelectableTile extends StatefulWidget {
  final String imageUri;
  Widget leadingWidget;
  final String title;
  String subtitle;
  Color initialSubtitleColor;
  Color selectedSubtitleColor;
  dynamic Function(dynamic) onTap;
  bool isSelected;
  final String placeHolderAssetUri;
  Color initialTextColor;
  Color initialBackgroundColor;
  Color selectedTextColor;
  Color selectedBackgroundColor;
  String type="normal";
  SelectableTile({this.imageUri, this.title, this.onTap, this.isSelected, this.placeHolderAssetUri,
    this.initialBackgroundColor, this.selectedBackgroundColor, this.selectedTextColor, this.initialTextColor, this.leadingWidget});

  SelectableTile.mediumWithSubtitle({this.imageUri, this.title, this.onTap, this.isSelected, this.placeHolderAssetUri,
    this.initialBackgroundColor, this.selectedBackgroundColor, this.selectedTextColor, this.initialTextColor, this.subtitle, this.initialSubtitleColor, this.selectedSubtitleColor, this.leadingWidget}){
    this.type="mediumsub";
  }

  @override
  _SelectableTileState createState() => _SelectableTileState();
}

class _SelectableTileState extends State<SelectableTile> {
  String imageUri;
  String title;
  dynamic Function(dynamic) onTap;
  bool isSelected;
  Color initialTextColor;
  Color initialBackgroundColor;
  Color selectedTextColor;
  Color selectedBackgroundColor;
  String placeHolderAssetUri;
  String subtitle;
  Color initialSubtitleColor;
  Color selectedSubtitleColor;
  Widget leadingWidget;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateAllItemsWidget();
  }
  @override
  Widget build(BuildContext context) {

    switch(widget.type){
      case "normal":{
        return buildNormal();
      }
      case "mediumsub":{
        return buildMediumSithSub();
      }

      default:{
        return buildNormal();
      }
    }
  }

  @override
  void didUpdateWidget(SelectableTile oldWidget) {
    if(
    imageUri!=widget.imageUri||
    title!= widget.title||
    onTap!=widget.onTap||
    isSelected!=widget.isSelected||
    placeHolderAssetUri!= widget.placeHolderAssetUri||
    initialBackgroundColor!=widget.initialBackgroundColor||
    initialTextColor!=widget.initialTextColor||
    selectedTextColor!=widget.selectedTextColor||
    selectedBackgroundColor!=widget.selectedBackgroundColor||
    subtitle!=widget.subtitle||
    initialSubtitleColor!=widget.initialSubtitleColor||
    selectedSubtitleColor!=widget.selectedSubtitleColor||
    leadingWidget!=widget.leadingWidget
    ) {
      setState((){
        updateAllItemsWidget();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  updateAllItemsWidget(){
    imageUri=widget.imageUri;
    title= widget.title;
    onTap=widget.onTap;
    isSelected=widget.isSelected??false;
    placeHolderAssetUri= widget.placeHolderAssetUri;
    initialBackgroundColor=widget.initialBackgroundColor;
    initialTextColor=widget.initialTextColor;
    selectedTextColor=widget.selectedTextColor;
    selectedBackgroundColor=widget.selectedBackgroundColor;
    subtitle=widget.subtitle;
    initialSubtitleColor=widget.initialSubtitleColor;
    selectedSubtitleColor=widget.selectedSubtitleColor;
    leadingWidget=widget.leadingWidget;
  }

  Widget buildMediumSithSub(){
    return Material(
      color: isSelected?selectedBackgroundColor??MyTheme.darkBlack:initialBackgroundColor??MyTheme.darkBlack,
      elevation: 16,
      child: InkWell(
        onTap: (){
          onTap!=null?onTap(!isSelected):null;
          setState(() {
            isSelected=!isSelected;
          });
        },
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: leadingWidget??FadeInImage(
                    placeholder: AssetImage(placeHolderAssetUri??'images/track.png'),
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeOutDuration: Duration(milliseconds: 100),
                    image: imageUri != null
                        ? FileImage(
                      new File(imageUri),
                    )
                        : AssetImage(placeHolderAssetUri??'images/track.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          (title == null)
                              ? ""
                              : title,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          textWidthBasis: TextWidthBasis.parent,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected?selectedTextColor??MyTheme.grey300:initialTextColor??MyTheme.grey300,
                          ),
                        )

                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          ( subtitle== null)
                              ? ""
                              : subtitle,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          textWidthBasis: TextWidthBasis.parent,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected?selectedSubtitleColor??MyTheme.grey300:initialSubtitleColor??MyTheme.grey300,
                          ),
                        )

                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNormal(){
    return Material(
      color: isSelected?selectedBackgroundColor??MyTheme.darkBlack:initialBackgroundColor??MyTheme.darkBlack,
      elevation: 16,
      child: InkWell(
        onTap: (){
          print("tapped element, will setState anyways");
          onTap!=null?onTap(!isSelected):null;
          setState(() {
            isSelected=!isSelected;
          });
        },
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: leadingWidget??FadeInImage(
                    placeholder: AssetImage(placeHolderAssetUri??'images/track.png'),
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeOutDuration: Duration(milliseconds: 100),
                    image: imageUri != null
                        ? FileImage(
                      new File(imageUri),
                    )
                        : AssetImage(placeHolderAssetUri??'images/track.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          (title == null)
                              ? "Unknon Album"
                              : title,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          textWidthBasis: TextWidthBasis.parent,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected?selectedTextColor??MyTheme.grey300:initialTextColor??MyTheme.grey300,
                          ),
                        )

                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


