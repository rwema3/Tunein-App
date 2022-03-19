import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';





class ItemListDevider extends StatelessWidget {

  final TextStyle textStyle;
  final double height;
  final String DeviderTitle;
  final Color backgroundColor;
  final String secondaryTitle;

  const ItemListDevider({this.textStyle, this.height, this.DeviderTitle, this.backgroundColor, this.secondaryTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        child: Row(
          children: [
            Text(DeviderTitle??"Albums",
              style: textStyle??TextStyle(
                fontSize: 15.5,
                color: MyTheme.grey300,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
            if(secondaryTitle!=null)Padding(
              child: Text(secondaryTitle??"Albums",
                style: textStyle??TextStyle(
                  fontSize: 10,
                  color: MyTheme.grey300,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.25,
                ),
                strutStyle: StrutStyle(
                    forceStrutHeight: true,
                    height: 1.3,
                  fontStyle: FontStyle.italic
                ),
                textAlign: TextAlign.left,
              ),
               padding: EdgeInsets.only(left: 5),
            )
          ],
        ),
        padding: EdgeInsets.all(8).add(EdgeInsets.only(top: 2,left: 4)),
      ),
      color: backgroundColor??MyTheme.bgBottomBar,
      constraints: BoxConstraints.expand(height: height??35),
    );
  }
}


class DynamicSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  const DynamicSliverHeaderDelegate({
    @required this.child,
    this.maxHeight = 250,
    this.minHeight = 80,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  // @override
  // bool shouldRebuild(DynamicSliverHeaderDelegate oldDelegate) => true;

  @override
  bool shouldRebuild(DynamicSliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;
}
