import 'package:Tunein/components/drawer/sideDrawer.dart';
import 'package:Tunein/services/layout.dart';
import 'package:Tunein/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
//import 'package:preload_page_view/preload_page_view.dart';

class SideDrawerService{


  final layoutService = locator<LayoutService>();

  //  Current State of InnerDrawerState
   GlobalKey<InnerDrawerState> _innerDrawerKey;


  SideDrawerService(){
    _innerDrawerKey= layoutService.sideDrawerKey;

  }


  //making the over scroll from the library pages  : scrolling pst the first page , open the drawer




  void toggle()
  {
    _innerDrawerKey.currentState.toggle(
      // direction is optional
      // if not set, the last direction will be used
      //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.start
    );
  }
}
