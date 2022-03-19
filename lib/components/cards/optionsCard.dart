import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:Tunein/components/common/ShowWithFadeComponent.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/memoryCacheService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:Tunein/utils/ConversionUtils.dart';
import 'package:flutter/material.dart';


final themeService = locator<ThemeService>();
final memoryCacheService = locator<MemoryCacheService>();

class MoreOptionsCard extends StatelessWidget {
  final String uniqueID;
  final String bottomTitle;
  final String imageUri;
  final List<int> colors;
  Widget backgroundWidget;
  VoidCallback onSavePressed;
  VoidCallback onPlayPressed;


  MoreOptionsCard({this.bottomTitle, this.imageUri, this.colors,
    this.onSavePressed, this.onPlayPressed, this.backgroundWidget, this.uniqueID});

  @override
  Widget build(BuildContext context) {
    Color shadowColor = ((colors!=null && colors.length!=0)?new Color(colors[0]):Color(themeService.defaultColors[0])).withOpacity(.7);

    return Container(
      height: 60,
      width: 60,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        color: MyTheme.bgBottomBar,
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            backgroundWidget??ShowWithFade.fromStream(
              inStream: ConversionUtils.createImageFromWidget(
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child:Stack(
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: 2, sigmaY: 3
                          ),
                          child: Container(
                            child: Container(
                              color: shadowColor,
                              child: ConstrainedBox(
                                child: imageUri == null ? Image.asset("images/artist.jpg",fit: BoxFit.cover) : Image(
                                  image: FileImage(File(imageUri)),
                                  fit: BoxFit.cover,
                                  colorBlendMode: BlendMode.darken,
                                ),
                                constraints: BoxConstraints.expand(),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: Border.all(width: .3, color: MyTheme.bgBottomBar),
                            ),
                          ),
                        ),
                        Positioned(
                          child: Text(bottomTitle??"Choice card",
                            style: TextStyle(
                                color: ((colors!=null && colors.length!=0)?new Color(colors[1]):Color(0xffffffff)).withOpacity(.8),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow( // bottomLeft
                                      offset: Offset(-1.2, -1.2),
                                      color: shadowColor,
                                      blurRadius: 2
                                  ),
                                  Shadow( // bottomRight
                                      offset: Offset(1.2, -1.2),
                                      color: shadowColor,
                                      blurRadius: 2
                                  ),
                                  Shadow( // topRight
                                      offset: Offset(1.2, 1.2),
                                      color: shadowColor,
                                      blurRadius: 2
                                  ),
                                  Shadow( // topLeft
                                    offset: Offset(-1.2, 1.2),
                                    color: shadowColor,
                                    blurRadius: 2,
                                  ),
                                ]
                            ),
                          ),
                          bottom: 5,
                          left: 5,
                        ),
                      ],
                    ),
                  ),
                  imageSize: Size(200, 150),
                  logicalSize: Size(200, 150),
                  wait: Duration(milliseconds: 450)
              ).then((value) {
                memoryCacheService.setCacheItem(uniqueID, value);
                return Image.memory(value);
              }).asStream(),
              inCurve: Curves.easeIn,
              fadeDuration: Duration(milliseconds: 50),
              durationUntilFadeStarts: Duration(milliseconds: 0),
              shallowWidget: Container(
                height: 120,
                width: 180,
                color: MyTheme.darkBlack.withOpacity(.6),
              ),
            ),

            Positioned(
              child: Material(
                color:Colors.transparent,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: IconButton(
                        icon: Container(
                          decoration: BoxDecoration(
                            boxShadow:[
                              BoxShadow( // bottomLeft
                                  offset: Offset(-1.1, -1.2),
                                  color: shadowColor.withOpacity(.7),
                                  blurRadius: 1.1
                              ),
                              BoxShadow( // bottomRight
                                  offset: Offset(1.2, -1.2),
                                  color: shadowColor.withOpacity(.7),
                                  blurRadius: 1.1
                              ),
                              BoxShadow( // topRight
                                  offset: Offset(1.2, 1.2),
                                  color: shadowColor.withOpacity(.7),
                                  blurRadius: 1.1
                              ),
                              BoxShadow( // topLeft
                                offset: Offset(-1.2, 1.2),
                                color: shadowColor.withOpacity(.7),
                                blurRadius: 1.1,
                              ),
                            ],
                            border: Border.all(
                              color: shadowColor,
                              width: 0.8
                            ),
                            borderRadius: BorderRadius.circular(100)
                          ),
                          child: Icon(
                            IconData(0xf144, fontFamily: 'fontawesome'),
                            size: 22,
                          ),
                        ),
                        onPressed: (){
                          onPlayPressed!=null?onPlayPressed():(){print("play button pressed");};
                        },
                        color: ((colors!=null && colors.length!=0)?new Color(colors[1]):Color(themeService.defaultColors[1])).withOpacity(.9),
                        tooltip: "Play this playlist",
                        padding: const EdgeInsets.all(1),
                        splashColor: ((colors!=null && colors.length!=0)?new Color(colors[0]):Color(themeService.defaultColors[0])).withOpacity(.7),
                        iconSize: 22,
                      ),
                    ),
                    Container(
                      child: IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(1),
                          constraints: BoxConstraints.tightFor(),
                          decoration: BoxDecoration(
                              boxShadow:[
                                BoxShadow( // bottomLeft
                                    offset: Offset(-1.2, -1.2),
                                    color: shadowColor.withOpacity(.6),
                                    blurRadius: 1.1
                                ),
                                BoxShadow( // bottomRight
                                    offset: Offset(1.2, -1.2),
                                    color: shadowColor.withOpacity(.6),
                                    blurRadius: 0.9
                                ),
                                BoxShadow( // topRight
                                    offset: Offset(1.2, 1.2),
                                    color: shadowColor.withOpacity(.6),
                                    blurRadius: 0.9
                                ),
                                BoxShadow( // topLeft
                                  offset: Offset(-1.2, 1.2),
                                  color: shadowColor.withOpacity(.6),
                                  blurRadius: 1.1,
                                ),
                              ],
                              border: Border.all(
                                  color: shadowColor,
                                  width: 0.8
                              ),
                              borderRadius: BorderRadius.circular(6)
                          ),
                          child: Icon(
                            IconData(0xf0c7, fontFamily: 'fontawesome'),
                            size: 22,
                          ),
                        ),
                        onPressed: (){
                          onSavePressed!=null?onSavePressed():(){print("save button pressed");};
                        },
                        color: ((colors!=null && colors.length!=0)?new Color(colors[1]):Color(themeService.defaultColors[1])).withOpacity(.9),
                        tooltip: "Save this playlist",
                        splashColor: ((colors!=null && colors.length!=0)?new Color(colors[0]):Color(themeService.defaultColors[0])).withOpacity(.7),
                        iconSize: 22,
                        padding: const EdgeInsets.all(1),
                      ),
                    )
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
              top: 0,
              right: 0,
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: MyTheme.bgBottomBar,
        borderRadius: BorderRadius.all(Radius.circular(25)),
        border: Border.all(width: .3, color: MyTheme.bgBottomBar),
      ),
    );
  }
}
