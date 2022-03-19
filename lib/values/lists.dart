import 'package:flutter/material.dart';

final Map<int, List<MapEntry<String, GlobalKey>>> headerItems = {
  0: [
    MapEntry(
      "Home",
      GlobalKey(),
    ),
    MapEntry(
      "Tracks",
      GlobalKey(),
    ),
    MapEntry(
      "Artists",
      GlobalKey(),
    ),
    MapEntry(
      "Albums",
      GlobalKey(),
    )
  ],
  1: [
    MapEntry("Playlists", GlobalKey()),
    MapEntry("Favorites", GlobalKey()),
  ],
  2:[
    MapEntry("General", GlobalKey()),
    MapEntry("Interface", GlobalKey()),
    MapEntry("Metrics", GlobalKey()),
    MapEntry("Servers", GlobalKey())
  ],
  3:[
    MapEntry("About", GlobalKey()),
  ]
};

final List<MapEntry<String, Icon>> bottomNavBarItems = [
  MapEntry("Library", Icon(IconData(0xec2f, fontFamily: 'boxicons'))),
  MapEntry("Playlists", Icon(IconData(0xeccd, fontFamily: 'boxicons'))),
  MapEntry("Search", Icon(IconData(0xeb2e, fontFamily: 'boxicons'))),
  MapEntry("Equalizer", Icon(IconData(0xea86, fontFamily: 'boxicons'))),
  MapEntry("Settings", Icon(IconData(0xec2e, fontFamily: 'boxicons'))),
];
