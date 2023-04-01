import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:appid/helper/helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:appid/component/http_service.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/constants.dart';

class LoginOtpPage extends StatefulWidget {
  const LoginOtpPage({super.key});

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _email = TextEditingController();
  final LocalStorage storage = LocalStorage('homerunapp');
  
  HttpService httpService = HttpService();
  DateTime currentBackPressTime = DateTime.now();
  bool callApi = false;
  bool showPass = true;
  String response = '';
  bool statusClose = false;

  @override
  void initState() {
    super.initState();

    if (TargetPlatform.iOS == defaultTargetPlatform) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _callPostApi() async {
    if (_email.text == '') {
      Helper(context: context).flushbar(success: false, msg: 'Silakan isi Alamat Email');
      return;
    }

    setState(() {
      callApi = true;
    });

    dynamic bod = {
      "username": _email.text,
    };

    httpService.post('login', body: bod).then((res) {
      // log("res= $res");

      bool success = res['success'];

      if (success == true) {
        dynamic args = {
          "body": bod,
          "endpoint": "login",
          "message": res['msg'],
        };
        
        Navigator.pushNamed(context, '/otpConfirmPage', arguments: args);
      } else {
        setState(() {
          response = res['msg'];
        });
      }
      
      setState(() {
        callApi = false;
      });
    }, onError: (error) {
      log("error = $error");

      setState(() {
        callApi = false;
        response = error.toString();
      });
    });
  }

  void close() {
    var duration = const Duration(seconds: 2);
    Timer(duration, () {
      statusClose = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (statusClose == true) {
            exit(0);
          }
          var snackBar = SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.25,
                  vertical: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                "Tekan sekali lagi untuk keluar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          statusClose = true;
          close();
          return Future.value(false);
        },
        child: _bodyPage());
  }

  Widget footer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: Column(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              const Text(
                "Don’t have an account?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Constants.colorText
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/register2Page');
                },
                child: const Text(
                  " Sign up",
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.redTheme,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Constants.colorTitle,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Text(
              "Please enter your email address",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Constants.colorCaption,
              ),
            ),
          ),
        ],
      ),
    );
  }

  updateObsecure() {
    setState(() {
      showPass = !showPass;
    });
  }

  Widget errorText() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Container(
          //   margin: const EdgeInsets.only(right: 5),
          //   child: Image.asset(
          //     'assets/images/warning-2.png',
          //     scale: 1.7,
          //     color: Colors.white,
          //   ),
          // ),
          Expanded(
            child: Text(
              response,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: CustomTextInput(
              hintText: "Email Address",
              placeholder: "Minghojerry@gmail.com",
              controllerName: _email,
              errorTextWidget: response != "" ? errorText() : Container(),
              enabled: true,
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              inputColor: Constants.colorFormInput,
              onChangeText: () {
                setState(() {
                  response = "";
                });
              },
              onTap: () {},
              onEditingComplete: () {
                if (callApi == false) {
                  _callPostApi();
                }
              },
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 20),
          //   alignment: Alignment.topRight,
          //   child: InkWell(
          //     onTap: () {
          //       Navigator.pushNamed(context, '/loginPassPage');
          //     },
          //     child: const Text(
          //       "Masuk dengan kata sandi",
          //       style: TextStyle(
          //         color: Constants.redTheme,
          //         fontSize: 14,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget action() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.02,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(120)),
                      color: Constants.redTheme,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Constants.redTheme,
                        onTap: () {
                          if (callApi == false) {
                            _callPostApi();
                          }
                        },
                        child: Center(
                          child: (callApi == false)
                              ? const Text(
                                  "Sign in",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Constants.colorWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const CircularProgressIndicator(
                                  backgroundColor: Constants.redTheme,
                                  color: Constants.redThemeUltraLight,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyPage() {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _key,
      backgroundColor: Constants.redTheme,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Image.asset('assets/logo/logo-horizontal.png',
                            width: width * 0.3),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: width,
                            child: AspectRatio(
                              aspectRatio: 5/6,
                              child: Image(
                                image: const AssetImage(
                                  'assets/images/auth/Login-img.png'),
                          ),
                            )),
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Constants.colorWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              )
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Constants.colorWhite,
                        child: Column(
                          children: [
                            header(),
                            form(),
                            action(),
                            footer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
