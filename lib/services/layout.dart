import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
//import 'package:preload_page_view/preload_page_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:Tunein/services/pageService.dart';

class LayoutService {
  // Main PageView
  PageController _globalPageController;
  PageController get globalPageController => _globalPageController;

  // Sub PageViews
  List<PageService> _pageServices;
  List<PageService> get pageServices => _pageServices;

  // Main Panel
  PanelController _globalPanelController;
  PanelController get globalPanelController => _globalPanelController;
  PageController _albumPlayerPageController;
  PageController get albumPlayerPageController => _albumPlayerPageController;
  PageController _albumListPageController;
  PageController get albumListPageController => _albumListPageController;
  VoidCallback _onPanelOpenCallback;
  VoidCallback get onPanelOpenCallback => _onPanelOpenCallback;


  set onPanelOpenCallback(VoidCallback value) {
    _onPanelOpenCallback = value;


  } // global keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  final GlobalKey<InnerDrawerState> _sideDrawerKey = GlobalKey<InnerDrawerState>();

  GlobalKey<InnerDrawerState> get sideDrawerKey => _sideDrawerKey;


  LayoutService() {
    _initGlobalPageView();
    _initSubPageViews();
    _initGlobalPanel();
    _initPlayingPageView();
    _initAlbumListPageView();
  }

  void _initSubPageViews() {
    _pageServices = List<PageService>(4);
    for (var i = 0; i < _pageServices.length; i++) {
      _pageServices[i] = PageService(i, Controller: i==0?PageController(keepPage: true):null);
    }
  }

  void _initGlobalPanel() {
    _globalPanelController = PanelController();
  }

  void _initGlobalPageView() {
    _globalPageController = PageController();
  }

  void _initPlayingPageView() {
    _albumPlayerPageController = PageController(
      initialPage: 1,
      keepPage: true
    );
  }

  void _initAlbumListPageView() {
    _albumListPageController = PageController();
  }

  void changeGlobalPage(int pageIndex) {
    Curve curve = Curves.fastOutSlowIn;
    _globalPageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: curve,
    );
  }

  //mainpanel functions

  onPanelOpen(dynamic data){
    if(onPanelOpenCallback!=null){
      onPanelOpenCallback();
    }
  }
}
