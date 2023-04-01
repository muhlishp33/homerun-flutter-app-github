import 'dart:developer';
import 'package:appid/app_navigator_services.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/main.dart';

class ApiProfile {
  final LocalStorage storage = LocalStorage('homerunapp');
  HttpService http = HttpService();
  
  Future<dynamic> fetchProfile() async {
    dynamic result = await http.post('profile');
    // log('result profile $result');
    if (result != null && result['success'] == true && result['data'] != null) {
      dynamic dataProfile = {
        "is_guest": Constants.listGuestUsername.contains(result['data']['username']),
        ...result['data'],
      };
      // log('dataProfile $dataProfile');
      await setInstanceJson('profile', dataProfile);
      await setInstanceJson('bubble', result['bubble']);
      await setInstanceJson('information', result['information']);
    } else {
      storage.clear();
      clearInstance();
      AppNavigatorService.navigatorKey.currentState?.pushReplacementNamed('/loginPage');
    }
    return result;
  }
}