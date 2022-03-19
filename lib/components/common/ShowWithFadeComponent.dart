import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';



class ShowWithFade extends StatelessWidget {
  Widget child;
  final Duration fadeDuration;
  final Duration durationUntilFadeStarts;
  final Widget shallowWidget;
  final Curve inCurve;
  Stream<Widget> inStream;
  ShowWithFade({@required this.child, this.fadeDuration, this.durationUntilFadeStarts,
  this.shallowWidget, this.inCurve});


  ShowWithFade.fromStream({this.inStream, this.fadeDuration,
    this.durationUntilFadeStarts, this.shallowWidget, this.inCurve});

  @override
  Widget build(BuildContext context) {
    if(this.inStream!=null){
      return buildWithStream(this.inStream);
    }
    Widget fadedWidget = Stack(
      children: <Widget>[
        shallowWidget??Container(
          color: MyTheme.bgBottomBar,
          constraints: BoxConstraints.expand(),
        )
      ],
    );
    return StreamBuilder(
      stream: Future.delayed(durationUntilFadeStarts??Duration(milliseconds: 200), ()=>true).asStream(),
      builder: (context, AsyncSnapshot<dynamic> snapshot){
        return AnimatedSwitcher(
          switchInCurve: inCurve??Curves.linear,
          duration: fadeDuration??Duration(milliseconds: 200),
          child: !snapshot.hasData?fadedWidget:Container(
            child: child,
          ),
        );
      },
    );
  }


  Widget buildWithStream(Stream<Widget> inStream){
    Widget fadedWidget = Stack(
      children: <Widget>[
        shallowWidget??Container(
          color: MyTheme.bgBottomBar,
          constraints: BoxConstraints.expand(),
        )
      ],
    );
    return StreamBuilder(
      stream: Future.delayed(durationUntilFadeStarts??Duration(milliseconds: 0), ()=>inStream.first).asStream(),
      builder: (context, AsyncSnapshot<Widget> snapshot){
        return AnimatedSwitcher(
          switchInCurve: inCurve??Curves.linear,
          duration: fadeDuration??Duration(milliseconds: 200),
          child: !snapshot.hasData?fadedWidget:Container(
            child: snapshot.data,
          ),
        );
      },
    );
  }
}
