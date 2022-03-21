import 'package:Tunein/components/bottomPanel.dart';
import 'package:Tunein/components/playing.dart';
import 'package:Tunein/globals.dart';
import 'package:Tunein/plugins/nano.dart';
import 'package:Tunein/root.dart';
import 'package:Tunein/services/layout.dart';
import 'package:Tunein/services/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'services/locator.dart';
import 'services/languageService.dart';
Nano nano = Nano();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
  PermissionStatus permission = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
  print(permission);
  setupLocator();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  //final LanguageService = locator<languageService>();
  @override
  Widget build(BuildContext context) {
    //LanguageService.flutterI18nDelegate.load(null);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tune In Music Player",
      localizationsDelegates: [
        //LanguageService.flutterI18nDelegate,
      ],
      home: Wrapper(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Root(),
            ),
            Container(
              height: 60,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  final Widget child;
  Wrapper({Key key, this.child}) : super(key: key);

  final layoutService = locator<LayoutService>();

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: NowPlayingScreen(controller: layoutService.albumPlayerPageController),
      controller: layoutService.globalPanelController,
      minHeight: 60,
      maxHeight: MediaQuery.of(context).size.height,
      backdropEnabled: true,
      backdropOpacity: 0.5,
      parallaxEnabled: true,
        onPanelClosed:(){
          layoutService.albumPlayerPageController.jumpToPage(1);
        },
        onPanelSlide: (value){
          if(value>=0.3){
            layoutService.onPanelOpen(value);
          }
        },
      collapsed: Material(
        child: BottomPanel(),
      ),
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Tune In Music Player",
        color: MyTheme.darkRed,
        home: child,
      ),
    );
  }
}
