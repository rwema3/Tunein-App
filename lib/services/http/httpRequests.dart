import 'package:dio/dio.dart';
import 'package:Tunein/services/locator.dart';
import 'package:Tunein/services/settingService.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/material.dart';

class httpRequests{

  Dio instance = new Dio();


  httpRequests(){
   instance.transformer = FlutterTransformer();
  }

  Future<Response> get({@required String url, Map<String, dynamic>data, Map<String, dynamic> headers, int timeout}) async{
    try {
      Response response = await Dio().get(url,
          options: Options(
            headers: headers,
            sendTimeout: timeout
          ),
        queryParameters: data
      );
      print(response);
      return response;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Response> post({@required String url, Map<String, dynamic>data, Map<String, dynamic> headers, int timeout}) async{
    try {
      Response response = await Dio().post(url,
          options: Options(
            headers: headers,
            sendTimeout: timeout
          ),
          data: data,
      );
      print(response);
      return response;
    } catch (e) {
      print(e);
      throw e;
    }
  }

}