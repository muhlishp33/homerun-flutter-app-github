import 'dart:developer';
import 'package:appid/component/http_service.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiLogger {
  HttpService http = HttpService();
  
  Future<dynamic> fetchLogger({
    required String page,
    required String value,
  }) async {
    dynamic body = {
      'page': page,
      'value': value,
      'device': kIsWeb ? 'web' : TargetPlatform.iOS == defaultTargetPlatform ? 'ios' : 'android',
    };

    // log('body logger ${body}');
    dynamic result = await http.post('logger', body: body);
    // log('result logger ${result}');
    return result;
  }
}