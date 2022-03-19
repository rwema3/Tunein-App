import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;


class StageScrollingPhysics extends ScrollPhysics {
  /// Creates scroll physics that prevent the scroll offset from exceeding the
  /// bounds of the content..
  ///
  int currentStage;
  List<double> stages;
  StageScrollingPhysics({ ScrollPhysics parent,this.stages, this.currentStage=0 }) : super(parent: parent);

  @override
  StageScrollingPhysics applyTo(ScrollPhysics ancestor) {
    return StageScrollingPhysics(parent: buildParent(ancestor), stages: this.stages, currentStage: this.currentStage);
  }


  double _getPixels() {
    return stages[currentStage];
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    if (velocity < -tolerance.velocity) {
      if(currentStage-1>=0)currentStage --;
    } else if (velocity > tolerance.velocity) {
      if(currentStage+1<this.stages.length)currentStage ++;
    }
    return _getPixels();
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, position.pixels>target?-200:200,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}