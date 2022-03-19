import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/components/trackListDeckItem.dart';
import 'package:Tunein/globals.dart';
import 'package:flutter/material.dart';




class TrackListDeck extends StatelessWidget {

  List<TrackListDeckItem> items;
  bool hideText;


  TrackListDeck({this.items, this.hideText=true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.3,
              color: MyTheme.darkgrey.withOpacity(.4)
            )
          ),
        ),
        child: ListView(
          itemExtent: hideText?65:120,
          children: items??<Widget>[
            TrackListDeckItem(
                title: "Shuffle",
                subtitle:"All Tracks",
                icon: Icon(Icons.shuffle),
            ),
            TrackListDeckItem(
              title: "Sort",
              subtitle:"All Tracks",
              icon: Icon(Icons.sort),
            ),
            TrackListDeckItem(
              title: "Filter",
              subtitle:"All Tracks",
              icon: Icon(Icons.filter_list),
            )
          ],
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
