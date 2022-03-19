import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';


class ExpandableItem extends StatefulWidget {

  Color backgroundColor;
  Widget backgroundWidget;
  String title;
  Color titleColor;
  Widget expandedPortion;
  ExpandableItem({this.backgroundColor, this.backgroundWidget, this.title, this.titleColor, this.expandedPortion});

  @override
  _ExpandableItemState createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> with SingleTickerProviderStateMixin {


  /// The [AnimationController] is a Flutter Animation object that generates a new value
  /// whenever the hardware is ready to draw a new frame.
  AnimationController _controller;

  /// Since the above object interpolates only between 0 and 1, but we'd rather apply a curve to the current
  /// animation, we're providing a custom [Tween] that allows to build more advanced animations, as seen in [initState()].
  static final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  /// The [Animation] object itself, which is required by the [SizeTransition] widget in the [build()] method.
  Animation<double> _sizeAnimation;

  /// Detects which state the widget is currently in, and triggers the animation upon change.
  bool _isExpanded = false;

  /// Here we initialize the fields described above, and set up the widget to its initial state.
  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// This curve is controlled by [_controller].
    final CurvedAnimation curve =
    CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    /// [_sizeAnimation] will interpolate using this curve - [Curves.fastOutSlowIn].
    _sizeAnimation = _sizeTween.animate(curve);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Whenever a tap is detected, toggle a change in the state and move the animation forward
  /// or backwards depending on the initial status.
  _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    print("isExpandable? ${_isExpanded}");
    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _toggleExpand,
        child: Container(
            height: 150.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: widget.backgroundColor??MyTheme.darkBlack),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                        left: 0,
                        top: 0,
                        child: widget.backgroundWidget??Container(color: widget.backgroundColor??MyTheme.darkBlack,)),
                    Column(children: <Widget>[
                      Flexible(
                        child: SizeTransition(
                            axisAlignment: 1.0,
                            axis: Axis.vertical,
                            sizeFactor: _sizeAnimation,
                            child: Container(
                                child: widget.expandedPortion
                        ),
                      )
                      )
                    ]),
                  ],
                ))));
  }
}
