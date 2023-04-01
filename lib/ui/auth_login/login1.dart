import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _ipl = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final LocalStorage storage = LocalStorage('homerunapp');
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  HttpService httpService = HttpService();
  DateTime? currentBackPressTime;
  bool callApi = false;
  bool showPass = true;
  String response = '';
  String tokenFcm = '';
  bool statusClose = false;

  @override
  void initState() {
    super.initState();
    
    initFirebase();

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

  void initFirebase() async {
    bool isSupported = await FirebaseMessaging.instance.isSupported();
    if (isSupported) {
      _fcm.getToken().then((token) {
        setState(() {
          tokenFcm = token ?? '';
        });
      });
    }
  }

  void _callPostApi() async {
    httpService.post('applogin', body: {
      'ipl': _ipl.text != '' ? _ipl.text : " ",
      'username': _userName.text != '' ? _userName.text : ' ',
      'password': _password.text != '' ? _password.text : ' ',
      'token': tokenFcm,
      //'referrer': storage.getItem("referrer")
    }).then((res) {
      bool success = res['success'];
      String msg = res['msg'];
      dynamic member = res['member'];

      if (success == true) {
        setState(() {
          callApi = false;
        });

        setState(() {
          storage.setItem("authKey", msg);
          storage.setItem('email', member['member_email']);
          storage.setItem("username", member['member_username']);
          storage.setItem("nama", member['member_nm']);
          storage.setItem("phone", member['member_phone']);
          storage.setItem("status", member['member_status']);
          storage.setItem("type", member['member_type']);
        });

        setDataInstance(msg, member);

        Navigator.of(context).pushReplacementNamed("/mainMenuPage");
      } else {
        setState(() {
          callApi = false;
          response = msg;
        });
      }
    }, onError: (error) {
      setState(() {
        callApi = false;
        response = error.toString();
      });
    });
  }

  setDataInstance(msg, member) async {
    await setInstanceString('authKey', msg);
    await setInstanceString('email', member['member_email']);
    await setInstanceString("username", member['member_username']);
    await setInstanceString("nama", member['member_nm']);
    await setInstanceString("phone", member['member_phone']);
    await setInstanceInt("status", member['member_status']);
    await setInstanceInt("type", member['member_type']);
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
                  borderRadius: BorderRadius.circular(4)),
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
                "Belum punya akun?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/register2Page');
                },
                child: const Text(
                  " Daftar Sekarang",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          // Container(
          //   margin: EdgeInsets.only(top: 5),
          //   child: InkWell(
          //     onTap: () {
          //       Navigator.pushNamed(context, '/loginPage');
          //     },
          //     child: Container(
          //       child: Text(
          //         "Login dengan OTP ?",
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w400,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Selamat datang di!",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: const Text(
              "OneSmile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: Image.asset(
              'assets/images/warning-2.png',
              scale: 1.7,
              color: Colors.white,
            ),
          ),
          Text(
            response,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          child: CustomTextInput(
            hintText: "Nomor telepon",
            placeholder: "Masukan nomor telepon Anda",
            controllerName: _userName,
            enabled: true,
            isRequired: true,
            keyboardType: TextInputType.number,
            inputColor: const Color(0xFFBE4D44),
            textColor: Colors.white,
            onChangeText: () {},
            onEditingComplete: () {},
            onTap: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          child: CustomTextInput(
            hintText: "Kata sandi",
            placeholder: "Masukan kata sandi Anda",
            controllerName: _password,
            enabled: true,
            isRequired: true,
            isObsecure: showPass,
            errorTextWidget: response != "" ? errorText() : Container(),
            inputColor: const Color(0xFFBE4D44),
            textColor: Colors.white,
            suffixIcon: InkWell(
              onTap: () {
                updateObsecure();
              },
              child: const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
              ),
            ),
            onTap: () {},
            onChangeText: () {},
            onEditingComplete: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/forgotpasswordPage');
            },
            child: const Text(
              "Lupa kata sandi?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget actionForm() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.02,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      // boxShadow: [
                      //   new BoxShadow(
                      //       color: Colors.white,
                      //       offset: new Offset(2.0, 2.0),
                      //       blurRadius: 0,
                      //       spreadRadius: 0)
                      // ]
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Constants.redTheme,
                        onTap: (callApi == false)
                            ? () {
                                setState(() {
                                  callApi = true;
                                });
                                _callPostApi();
                              }
                            : () {},
                        child: Center(
                          child: (callApi == false)
                              ? const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Constants.redTheme,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const CircularProgressIndicator(
                                  backgroundColor: Constants.redTheme),
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
    return Scaffold(
      key: _key,
      backgroundColor: Constants.redTheme,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        leading: IconButton(
            tooltip: "Back",
            icon:
                Icon(TargetPlatform.iOS == defaultTargetPlatform ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          header(),
                        ],
                      ),
                      Center(
                        child: Image(
                            image: const AssetImage('assets/images/login.png'),
                            width: MediaQuery.of(context).size.width * 0.65),
                      ),
                      Column(
                        children: [
                          form(),
                          actionForm(),
                          footer(),
                        ],
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
