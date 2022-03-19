import 'package:Tunein/components/common/ShowWithFadeComponent.dart';
import 'package:flutter/material.dart';


class CustomPageView extends StatefulWidget {


  List<Widget> pages;
  PageController controller;
  bool preload;
  Widget shallowWidget;
  ScrollPhysics physics;
  CustomPageView({Key key, pages, controller, shallowWidget, physics, preload}) : this.pages = pages ?? [],
        this.controller = controller ?? new PageController(keepPage: true),
        this.shallowWidget=shallowWidget,
        this.physics=physics,
        this.preload=preload??true,
        super(key: key);

  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {

  List savedPages = [];


  @override
  void initState() {
    super.initState();
    savedPages = widget.pages.map((elem)=> ShowWithFade(
        child: elem,
        shallowWidget: widget.shallowWidget??Container(color: Colors.red),
        durationUntilFadeStarts: durationUntilPageShow)
    ).toList();
  }

  Duration durationUntilPageShow = Duration(milliseconds: 200);
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.controller,
      physics: widget.physics,
      children:  savedPages,
    );
  }

}
