import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/http/httpRequests.dart';
import 'package:dio/dio.dart';


final HttpRequests = locator<httpRequests>();

class UtilsRequests {

  Future<List<int>> getNetworkImage(String url) async {
    if (url != null) {
      Response respone = await HttpRequests.instance.get<List<int>>(url,
          options: Options(
              responseType: ResponseType.bytes
          )
      );
      return respone.data;
    } else {
      return [];
    }
  }


}