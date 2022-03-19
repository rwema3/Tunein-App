import 'package:flutter/material.dart';

import '../globals.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subTitle;
  final MapEntry<IconData,Color> icon;
  final bool hideText;
  PageHeader(this.title, this.subTitle, this.icon, {this.hideText=false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        height: 60,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                // color: Colors.red,
                alignment: Alignment.center,
                width: 50,
                child: Icon(
                  this.icon.key,
                  color: this.icon.value,
                  size: 30,
                ),
              ),
            ),
            !this.hideText?Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MyTheme.grey700,
                      ),
                    ),
                  ),
                  Text(
                    subTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ):Container(),
          ],
        ),
      ),
    );
  }
}
