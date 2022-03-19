import 'dart:ui';
import 'package:flutter/material.dart';

class MyTheme {
  static final darkRed = Color(0xffff245a);
  static final darkBlack = Color(0xff111111);
  static final grey300 = Color(0xfff6f8fb);
  static final grey500 = Color(0xffdee5ec);
  static final grey700 = Color(0xfff5f5f5);
  static final darkgrey = Color(0xffa3acbd);
  static final bgBottomBar = Color(0xff1e1e1e);
  static final bgdivider = Color(0xff2c2c2c);
}

class MyUtils {
  static String getArtists(artists) {
    if(artists == null) return "Unknow Artist";
    return artists.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }

  static dynamic createDelayedPageroute(context, Widget page, Widget exitPage) async {

    Future<Widget> buildPageAsync() async {
      return Future.microtask(() {
        return page;
      });
    }

    var newPage = await buildPageAsync();
    //var route = MaterialPageRoute(builder: (_) => newPage,);
    Navigator.push(context, SlideRightRoute(page: newPage,exitPage: exitPage));
  }
}


class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final Widget exitPage;
  SlideRightRoute({this.page, this.exitPage})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        Stack(
          children: <Widget>[
            SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(-1.0, 0.0),
              ).animate(animation),
              child: exitPage,
            ),
            SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: page,
            )
          ],
        ),
  );
}
