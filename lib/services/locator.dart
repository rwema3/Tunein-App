import 'package:Tunein/plugins/NotificationControlService.dart';
import 'package:Tunein/services/castService.dart';
import 'package:Tunein/services/fileService.dart';
import 'package:Tunein/services/http/httpRequests.dart';
import 'package:Tunein/services/http/requests.dart';
import 'package:Tunein/services/http/utilsRequests.dart';
import 'package:Tunein/services/languageService.dart';
import 'package:Tunein/services/layout.dart';
import 'package:Tunein/services/memoryCacheService.dart';
import 'package:Tunein/services/musicMetricsService.dart';
import 'package:Tunein/services/musicService.dart';
import 'package:Tunein/services/isolates/musicServiceIsolate.dart';
import 'package:Tunein/services/platformService.dart';
import 'package:Tunein/services/queueService.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:Tunein/services/sideDrawerService.dart';
import 'package:Tunein/services/themeService.dart';
import 'package:get_it/get_it.dart';


GetIt locator = new GetIt();

void setupLocator() {
  locator.registerSingleton(MemoryCacheService());
  locator.registerSingleton(fileService());
  locator.registerSingleton(PlatformService());
  locator.registerSingleton(musicServiceIsolate());
  locator.registerSingleton(notificationControlService());
  locator.registerSingleton(settingService());
  locator.registerSingleton(CastService());
  locator.registerSingleton(MusicMetricsService());
  locator.registerSingleton(ThemeService());
  locator.registerSingleton(QueueService());
  locator.registerSingleton(MusicService());

  locator.registerSingleton(LayoutService());
  locator.registerSingleton(SideDrawerService());

  locator.registerSingleton(languageService());
  locator.registerSingleton(httpRequests());
  locator.registerSingleton(Requests());
  locator.registerSingleton(UtilsRequests());

}
