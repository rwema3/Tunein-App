import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';

class MyScrollbar extends StatefulWidget {
  final ScrollController controller;
  final Color color;
  bool showFromTheStart;
  bool neverHide;
  MyScrollbar({Key key, this.controller,this.color, this.showFromTheStart=false, this.neverHide=false}) : super(key: key);
  _MyScrollbarState createState() => _MyScrollbarState();
}

class _MyScrollbarState extends State<MyScrollbar> {
  double scrollableAreaWidth = 10;
  double thumbWidth = 6;
  double thumbHeight = 50;
  RenderBox boxAfterRender;
  double thumbPos = 0;
  bool showFromTheStart=false;
  bool neverHide = false;
  bool _offstage = true;
  bool _closing = false;

  _onAfterBuild(BuildContext context) {
    boxAfterRender = context.findRenderObject();
  }

  _updateThumbPos(double newPos) {
    mounted?setState(() {
      thumbPos = newPos;
      _offstage = false;
    }):null;

    if (_closing) return;

    _closing = true;

    Future.delayed(Duration(milliseconds: 1500), () {
      mounted?setState(() {
        (neverHide==null || !neverHide)?_offstage = true:_offstage=false;
        _closing = false;
      }):null;
    });
  }

  @override
  initState() {
    widget.controller.addListener(() {
      double offset = widget.controller.offset;
      double p = offset / widget.controller.position.maxScrollExtent;
      double height = boxAfterRender.size.height;
      _updateThumbPos((height - thumbHeight) * p);
    });
    this.showFromTheStart=widget.showFromTheStart;
    this.neverHide=widget.neverHide;
    if(showFromTheStart){
      _offstage=false;
    }
    super.initState();
  }

  _doMagic(Offset offset, RenderBox box) {
    double verticalOffset = offset.dy;
    if (verticalOffset < 0) verticalOffset = 0;
    if (verticalOffset > box.size.height) verticalOffset = box.size.height;
    double p = verticalOffset / box.size.height;
    double newSrollPos = widget.controller.position.maxScrollExtent * p;
    widget.controller.jumpTo(newSrollPos);
    double p2 =
        widget.controller.offset / widget.controller.position.maxScrollExtent;
    _updateThumbPos((box.size.height - thumbHeight) * p2);
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails updateDetails) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(updateDetails.globalPosition);
    _doMagic(offset, box);
  }

  _onDragStart(BuildContext context, DragStartDetails startDetails) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(startDetails.globalPosition);
    _doMagic(offset, box);
  }

  _onDragEnd(BuildContext context, DragEndDetails startDetails) {
    // setState(() {
    //   _offstage = true;
    // });
  }

  @override
  MyScrollbar get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) =>
          _onDragUpdate(context, details),
      onVerticalDragStart: (DragStartDetails details) =>
          _onDragStart(context, details),
      onVerticalDragEnd: (DragEndDetails details) =>
          _onDragEnd(context, details),
      child: Container(
        color: widget.color!=null?widget.color:MyTheme.darkBlack,
        width: scrollableAreaWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: AnimatedOpacity(
                  opacity: !_offstage ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 150),
                  child: Container(
                    color: Colors.grey[800],
                    width: thumbWidth,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: thumbPos,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.white70,
                            width: thumbWidth,
                            height: thumbHeight,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
