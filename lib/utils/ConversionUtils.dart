


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/fileService.dart';
import 'package:Tunein/services/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class ConversionUtils{

  static final FileService = locator<fileService>();

  static String DurationToFancyText(Duration duration, {showHours=true, showMinutes=true, showSeconds=true}){
    assert(duration!=null, "duration argument can't be null");
    String finalText ="";
    if(showHours && duration.inHours!=0){
      finalText+="${duration.inHours} hours ";
    }
    if(showMinutes && duration.inMinutes.remainder(60)!=0){
      finalText+="${duration.inMinutes.remainder(60)} min ";
    }
    if(showSeconds && duration.inSeconds.remainder(60)!=0){
      finalText+="${duration.inSeconds.remainder(60)} sec";
    }

    return finalText;
  }

  static String DurationToStandardTimeDisplay({Duration inputDuration, showHours=false, showMinutes=true, showSeconds=true}){
    String finalDuration="";

    if(showHours){
      int hours = inputDuration.inHours;
      finalDuration+="${hours<10?"0":""}${inputDuration.inHours}:";
    }
    if(showMinutes){
      if(showHours){
        int minutes = inputDuration.inMinutes.remainder(60);
        finalDuration+="${minutes<10?"0":""}${minutes}:";
      }else{
        int minutes = inputDuration.inMinutes;
        finalDuration+="${minutes<10?"0":""}${minutes}:";
      }
    }
    if(showSeconds){
      int seconds = inputDuration.inSeconds.remainder(60);
      finalDuration+="${seconds<10?"0":""}${seconds}";
    }

    return finalDuration;
  }


  static Future<List<int>> FileUriTo8Bit(String uri, {File fileInstead}) async{
    assert(uri!=null || fileInstead!=null, "one of uri and file needs to be supplied");
    if(fileInstead!=null){
      assert(fileInstead.existsSync(),"File Not Found");
      return fileInstead.readAsBytesSync();
    }else{
     return await FileService.readFile(uri,readAsBytes: true);
    }
  }


  static Future<Uint8List> fromWidgetGlobalKeyToImageByteList(GlobalKey widgetlobalKey) async{
    assert(widgetlobalKey!=null,"You can't pass a null global key");
    RenderRepaintBoundary boundary = widgetlobalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }


  static double songListToDuration(List<Tune> songs){
    double FinalDuration = 0;

    songs.forEach((elem) {
      FinalDuration += elem.duration;
    });

    return FinalDuration;
  }

  /// Creates an image from the given widget by first spinning up a element and render tree,
  /// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
  ///
  /// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
  static Future<Uint8List> createImageFromWidget(Widget widget, {Duration wait, Size logicalSize, Size imageSize}) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
    imageSize ??= ui.window.physicalSize;

    assert(logicalSize.aspectRatio == imageSize.aspectRatio);

    final RenderView renderView = RenderView(
      window: null,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner();

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: imageSize.width / logicalSize.width);
    final ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }
}