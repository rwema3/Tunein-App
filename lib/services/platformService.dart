import 'package:connectivity/connectivity.dart';
import 'package:dart_ping/dart_ping.dart';

class PlatformService{

  Future<bool> isOnWifi() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
  }


  Future<String> getCurrentIP() async {
    String ipAddress = await (Connectivity().getWifiIP());
    return ipAddress;
  }

  Future<dynamic> pingIp(String ip, {Duration interval = const Duration(seconds: 1), int pingNumber=2}) async{
    Stream<PingInfo> stream = await ping("ip", times: pingNumber, interval: interval.inSeconds);
    await stream.forEach((event) {
      print(event);
      if(event.seq==5){
       return true;
      }
    });
  }
}