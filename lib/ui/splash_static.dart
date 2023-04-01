import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:package_info/package_info.dart';

class SplashStatic extends StatefulWidget {
  const SplashStatic({super.key});

  @override
  SplashStaticState createState() => SplashStaticState();
}

class SplashStaticState extends State<SplashStatic> {
  final LocalStorage storage = LocalStorage('homerunapp');

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    startSplashStatic();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  startSplashStatic() async {
    int? appLaunchNumber = await getInstanceInt('appLaunchNumber');
    var authKey = await getInstanceString('authKey');
    var email = await getInstanceString('email');
    var username = await getInstanceString('username');
    var nama = await getInstanceString('nama');
    var phone = await getInstanceString('phone');
    var status = await getInstanceInt('status');
    var type = await getInstanceInt('type');

    if (authKey != null && authKey != '') {
      storage.setItem("authKey", authKey);
      storage.setItem('email', email);
      storage.setItem("username", username);
      storage.setItem("nama", nama);
      storage.setItem("phone", phone);
      storage.setItem("status", status);
      storage.setItem("type", type);
    }
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      if (authKey != null && authKey is String && authKey != '') {
        Navigator.of(context).pushReplacementNamed("/mainMenuPage");
      } else {
        if (appLaunchNumber != null && appLaunchNumber > 0) {
          Navigator.of(context).pushReplacementNamed('/loginPage');
        } else {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [
        // ================ bg ================
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, -1),
              end: Alignment(0, 1),
              colors: <Color>[
                Color(0xFF964DFF),
                Constants.redTheme,
              ],
              tileMode: TileMode.clamp,
            ),
          ),
        ),

        // ================ logo ================
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
              ),
              Image.asset(
                'assets/logo/label.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    "Versi 1.1.7",
                    style: TextStyle(
                      color: Constants.colorWhite.withOpacity(0.75),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
