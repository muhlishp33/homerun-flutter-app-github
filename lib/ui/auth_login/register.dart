import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';

class Register2Page extends StatefulWidget {
  const Register2Page(this.data, {super.key});
  final dynamic data;
  @override
  Register2PageState createState() => Register2PageState();
}

class Register2PageState extends State<Register2Page> {
  HttpService http = HttpService();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final LocalStorage storage = LocalStorage('homerunapp');
  final TextEditingController _username = TextEditingController();
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _nohp = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _ipl = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _hobby = TextEditingController();
  
  bool isLoading = false;
  String response = '';
  String currentText = "";
  bool showPass = true;

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

  List listKategori = [
    {"value": 1, "text": "Pria"},
    {"value": 2, "text": "Wanita"},
  ];
  int? _mySelection;

  _callPostApi() {
    bool fullNameContainNumber = _fullname.text.contains(RegExp(r'[0-9]'));

    setState(() {
      isLoading = true;
    });

    var bod = {
      // "username": _username.text,
      "fullname": _fullname.text,
      "email": _email.text,
      "phone": _nohp.text,
    };

    http.post('register', body: bod).then((res) {
      setState(() {
        isLoading = false;
      });

      // log('res register $res');

      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        if (res['success'] == true) {
          dynamic args = {
            "body": bod,
            "endpoint": "register",
            "message": res['msg'],
          };
          Navigator.pushNamed(context, '/otpConfirmPage', arguments: args);
        }
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      log('err regis $err');

      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        // Flushbar(
        //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        //   flushbarPosition: FlushbarPosition.TOP,
        //   borderRadius: 8,
        //   message: 'Terjadi kesalahan, silakan ulangi kembali',
        //   duration: Duration(seconds: 3),
        // )..show(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _bodyPage();
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
                "Already have an account?",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Constants.colorText),
              ),
              InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, '/loginPage');
                  Navigator.pop(context);
                },
                child: const Text(
                  " Sign in",
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

  Widget term() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          const Text(
            "Dengan membuat akun baru, Anda menyetujui",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/syaratKetentuanPage');
            },
            child: const Text(
              " Syarat dan Ketentuan ",
              style: TextStyle(
                fontSize: 14,
                color: Constants.redTheme,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Text(
            " dan ",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/syaratKetentuanPage');
            },
            child: const Text(
              "Kebijakan Privasi",
              style: TextStyle(
                fontSize: 14,
                color: Constants.redTheme,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.black, //change your color here
      ),
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      actions: const <Widget>[],
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
            "Create an account",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Constants.colorTitle,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Text(
              "Please enter your personal information",
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
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Text(
        response,
        style: const TextStyle(
          fontSize: 12.0,
          color: Constants.redTheme,
        ),
      ),
    );
  }

  Widget form() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          // Container(
          //   child: CustomTextInput(
          //     hintText: "Username",
          //     placeholder: "Enter your username here...",
          //     controllerName: _username,
          //     enabled: true,
          //     isRequired: true,
          //     inputColor: Constants.colorFormInput,
          //     onChangeText: () {},
          //     onEditingComplete: () {},
          //     onTap: () {},
          //   ),
          // ),
          Container(
            child: CustomTextInput(
              hintText: "Full Name",
              placeholder: "Enter your name here...",
              controllerName: _fullname,
              enabled: true,
              isRequired: true,
              inputColor: Constants.colorFormInput,
              onChangeText: () {},
              onEditingComplete: () {},
              onTap: () {},
            ),
          ),
          Container(
            child: CustomTextInput(
              hintText: "Email Address",
              placeholder: "Ex: homerun@gmail.com",
              controllerName: _email,
              enabled: true,
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              inputColor: Constants.colorFormInput,
              onChangeText: () {},
              onEditingComplete: () {},
              onTap: () {},
            ),
          ),
          Container(
            child: CustomTextInput(
              hintText: "Phone number",
              placeholder: "8120 0000 0000",
              controllerName: _nohp,
              enabled: true,
              isRequired: true,
              keyboardType: TextInputType.number,
              inputColor: Constants.colorFormInput,
              onChangeText: () {},
              onEditingComplete: () {},
              onTap: () {},
            ),
          ),
          // Container(
          //   child: CustomTextInput(
          //     hintText: "Kata sandi",
          //     placeholder: "Masukan kata sandi",
          //     controllerName: _pass,
          //     enabled: true,
          //     isRequired: true,
          //     isObsecure: showPass,
          //     onChangeText: () {},
          //     onEditingComplete: () {},
          //     onTap: () {},
          //     errorTextWidget: response != "" ? errorText() : Container(),
          //     suffixIcon: InkWell(
          //       onTap: () {
          //         updateObsecure();
          //       },
          //       child: const Icon(Icons.remove_red_eye),
          //     ),
          //   ),
          // )
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
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(120)),
                      color: Constants.redTheme,
                      // boxShadow: [
                      //   new BoxShadow(
                      //       color: Constants.redTheme,
                      //       offset: new Offset(2.0, 2.0),
                      //       blurRadius: 0,
                      //       spreadRadius: 0)
                      // ]
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Constants.redTheme,
                        onTap: () {
                          if (_nohp.text == '' || _fullname.text == '') {
                          } else {
                            _callPostApi();
                          }
                        },
                        child: const Center(
                            child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       InkWell(
          //         onTap: () {
          //           Navigator.pushNamed(context, '/forgotpasswordPage');
          //         },
          //         child: Text(
          //           "Lupa kata sandi",
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: Constants.redTheme,
          //             fontWeight: FontWeight.w700,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _bodyPage() {
    double width = MediaQuery.of(context).size.width;

    return LoadingFallback(
      isLoading: isLoading,
      child: Scaffold(
        // appBar: appBar(),
        key: _key,
        backgroundColor: Constants.redTheme,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
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
                        Center(
                            child: Container(
                          width: width,
                          child: AspectRatio(
                            aspectRatio: 4/3,
                            child: Image.asset(
                                'assets/images/auth/Register-img.png'),
                          ),
                        )),
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                              color: Constants.colorWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              )),
                        ),
                      ],
                    ),
                    Column(
                      children: [
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
      ),
    );
  }
}
