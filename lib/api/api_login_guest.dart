import 'dart:developer';
import 'package:appid/api/api_profile.dart';
import 'package:appid/app_navigator_services.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/http_service.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/main.dart';

String guestUsername = "mhp";
String guestPassword = "0912";

class ApiLoginGuest {
  final LocalStorage storage = LocalStorage('homerunapp');
  HttpService http = HttpService();
  ApiProfile apiProfile = ApiProfile();

  Future<dynamic> fetchLoginGuest() async {
    dynamic bodyLogin = {
      "username": guestUsername,
    };

    // req login
    dynamic resLogin = await http.post('login', body: bodyLogin);

    // log("res login guest = $resLogin");

    bool success = resLogin != null && resLogin['success'];

    if (success == true) {
      // otp confirm
      dynamic res = await fetchOtpGuest('login');
      if (res) {
        return true;
      }

      return false;
    } else {
      return false;
    }
  }

  Future<dynamic> fetchOtpGuest(String endpoint) async {
    dynamic bodyOtp = {
      "username": guestUsername,
      "otp": guestPassword,
      "device_token": "",
    };

    dynamic res = await http.post(endpoint, body: bodyOtp);

    if (res != null && res['success'] == true) {
      await storage.setItem("authKey", res['data']['user_token']);

      // login redirect
      if (endpoint == 'login') {
        await setInstanceString('authKey', res['data']['user_token']); 
        dynamic result = await apiProfile.fetchProfile();
        if (result != null && result['success']) {
          AppNavigatorService.navigatorKey.currentState?.pushReplacementNamed('/mainMenuPage');
          return true;
        }
        
        return false;

        // firebase analytics
        // pushGALogin();

        // logger
        // ApiLogger().fetchLogger(page: 'login', value: jsonEncode(body));
      }

      // register redirect
      if (endpoint == 'register') {
        return true;

        // Timer(
        //   const Duration(
        //     seconds: 3,
        //   ),
        //   () {
        //     Navigator.of(context).pushReplacementNamed("/loginPage");
        //   }
        // );

        // showAppNotification(
        //   context: context,
        //   desc: 'Your account is ready to use. you will be redirected to the Login page.',
        //   onSubmit: () {
        //     Navigator.of(context).pushReplacementNamed("/loginPage");
        //   }
        // );

        // firebase analytics
        // pushGASignUp();

        // logger
        // ApiLogger().fetchLogger(page: 'register', value: jsonEncode(body));
      }
    }
  }
}
