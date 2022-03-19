



import 'dart:math';

import 'package:flutter/material.dart';

class uiScaleService{
  static ArtistGridCellHeight(Size screenSize){
    return min<double>(screenSize.height/4,155);
  }

  static AlbumsGridCellHeight(Size screenSize){
    return min<double>(screenSize.height/4,155);
  }

  static AlbumArtistInfoPage(Size screenSize){
    return min<double>(screenSize.height/3.5,200);
  }
}