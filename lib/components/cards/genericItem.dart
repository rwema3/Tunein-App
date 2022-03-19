import 'package:Tunein/components/threeDotPopupMenu.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/ContextMenuOption.dart';
import 'package:flutter/material.dart';

class GenericItem extends StatefulWidget {

  List<ContextMenuOptions> choices;
  final Size ScreenSize;
  final double StaticContextMenuFromBottom;
  final void Function(ContextMenuOptions) onContextSelect;
  final void Function(ContextMenuOptions) onContextCancel;
  final void Function() onTap;
  final Widget leading;
  final String title;
  final String subTitle;
  List<Color> colors;
  double height;
  GenericItem({this.choices, this.ScreenSize, this.StaticContextMenuFromBottom,
    this.onContextCancel, this.onContextSelect, this.leading, this.subTitle, this.title, this.colors,
  this.onTap, this.height});

  @override
  _GenericItemState createState() => _GenericItemState();
}

class _GenericItemState extends State<GenericItem> {

  List<ContextMenuOptions> choices;
  Size ScreenSize;
  double StaticContextMenuFromBottom;
  void Function(ContextMenuOptions) onContextSelect;
  void Function(ContextMenuOptions) onContextCancel;
  void Function() onTap;
  Widget leading;
  String title;
  String subTitle;
  List<Color> colors;
  double height;
  @override
  void initState() {
    // TODO: implement initState
    this.choices = widget.choices;
    this.StaticContextMenuFromBottom=widget.StaticContextMenuFromBottom;
    this.ScreenSize=widget.ScreenSize;
    this.onContextCancel=widget.onContextCancel;
    this.onContextSelect=widget.onContextSelect;
    this.leading=widget.leading;
    this.title=widget.title;
    this.subTitle=widget.subTitle;
    this.colors=widget.colors;
    this.onTap=widget.onTap;
    this.height=widget.height;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              height: height??62,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      leading!=null?Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: leading,
                      ):Container(),
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                title??"",
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                textWidthBasis: TextWidthBasis.parent,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: colors!=null?colors[0].withAlpha(200):Colors.white,
                                ),
                              ),

                            ),
                            Text(
                              subTitle??"",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: colors!=null?colors[1].withAlpha(200):MyTheme.grey300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            flex: 12,
          ),
          choices!=null?ThreeDotPopupMenu(
            choices: choices,
            onContextSelect: onContextSelect,
            screenSize: ScreenSize,
            staticOffsetFromBottom: StaticContextMenuFromBottom,
          ):Container()
        ],
      ),
    );
  }
}
