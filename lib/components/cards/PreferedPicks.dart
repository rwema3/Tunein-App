import 'dart:io';
import 'dart:ui';

import 'package:Tunein/globals.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:flutter/material.dart';


final themeService = locator<ThemeService>();

class PreferredPicks extends StatelessWidget {

  final String bottomTitle;
  final String imageUri;
  final Widget backgroundWidget;
  final List<int> colors;
  final MapEntry<int,int> blurPower;
  final Color blurColor;
  final MapEntry<double, double> textPosition;
  final Key key;
  final Radius borderRadius;
  final bool allImageBlur;
  PreferredPicks({this.bottomTitle, this.imageUri, this.colors, this.backgroundWidget,
    this.blurPower,this.blurColor, this.textPosition, this.key, this.borderRadius, this.allImageBlur=true}): super(key: key);




  @override
  Widget build(BuildContext context) {
    Color shadowColor = ((colors!=null && colors.length!=0)?new Color(colors[0]):Color(themeService.defaultColors[0])).withOpacity(.7);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(borderRadius??Radius.circular(10)),
            border: Border.all(width: .3, color: MyTheme.bgBottomBar),
          ),
          child: Stack(
            overflow: Overflow.clip,
            children: <Widget>[
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                    sigmaX: blurPower!=null?blurPower.key:2, sigmaY: blurPower!=null?blurPower.value:3
                ),
                child: Container(
                  child: backgroundWidget??ConstrainedBox(
                    child: imageUri == null ? Image.asset("images/artist.jpg",fit: BoxFit.cover) : Image(
                      image: FileImage(File(imageUri)),
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.clear,
                    ),
                    constraints: BoxConstraints.expand(),
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(borderRadius??Radius.circular(10)),
                    border: Border.all(width: .3, color: MyTheme.bgBottomBar),
                  ),
                ),
              ),
              if(allImageBlur)Container(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blurPower!=null?blurPower.key:2, sigmaY: blurPower!=null?blurPower.value:3),
                      child: Container(
                          decoration: BoxDecoration(
                            color: blurColor??Colors.grey.shade100.withOpacity(0.2),
                            borderRadius: BorderRadius.all(borderRadius??Radius.circular(10)),
                            border: Border.all(width: .3, color: MyTheme.bgBottomBar),
                          )
                      ),
                    ),
                  )
              ),
              if(bottomTitle!=null)Positioned(
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
                bottom: textPosition!=null?textPosition.key:5,
                left: textPosition!=null?textPosition.value:5,
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(borderRadius??Radius.circular(10)),
        border: Border.all(width: .3, color: MyTheme.bgBottomBar),
      ),
    );
  }
}
