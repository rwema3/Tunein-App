import 'package:Tunein/components/gridcell.dart';
import 'package:Tunein/components/pageheader.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/models/playerstate.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin<FavoritesPage> {
  final musicService = locator<MusicService>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    return Container(
      padding: EdgeInsets.only(bottom: 85),
      height: double.infinity,
      width: double.infinity,
      color: MyTheme.darkBlack,
      child: Column(
        children: <Widget>[
          PageHeader(
            "Favorites",
            "All Tracks",
            MapEntry(IconData(0xeaaf, fontFamily: 'boxicons'), Colors.white),
          ),
          Expanded(
            child: StreamBuilder<List<Tune>>(
              stream: musicService.favorites$,
              builder: (context, AsyncSnapshot<List<Tune>> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                final _songs = snapshot.data;
                return GridView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: _songs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: (itemWidth / (itemWidth + 50)),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        musicService.updatePlaylist(_songs);
                        musicService.playOrPause(_songs[index]);
                      },
                      child: GridCell(_songs[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
