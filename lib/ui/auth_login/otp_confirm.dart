import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:appid/api/api_logger.dart';
import 'package:appid/api/api_profile.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/helper/analytic_by_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:pinput/pinput.dart';

class OtpConfirmPage extends StatefulWidget {
  const OtpConfirmPage(this.data, {super.key});

  final dynamic data;
  @override
  _OtpConfirmPageState createState() => _OtpConfirmPageState();
}

class _OtpConfirmPageState extends State<OtpConfirmPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  ApiProfile apiProfile = ApiProfile();
  final LocalStorage storage = LocalStorage('onesmile');
  TextEditingController textEditingController = TextEditingController();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final formKey = GlobalKey<FormState>();

  bool hasError = false;
  String currentText = "";
  bool isProses = false;
  String tokenFcm = '';
  bool isLoading = false;

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  Timer? _timer;
  int _start = 120;

  String responseOtp = '';

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // const oneSec = Duration(seconds: 1);
    // _timer = Timer.periodic(
    //   oneSec,
    //   (Timer timer) {
    //     if (_start == 0) {
    //       setState(() {
    //         timer.cancel();
    //       });
    //     } else {
    //       setState(() {
    //         _start--;
    //       });
    //     }
    //   },
    // );
  }

  String _printDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<dynamic> setDataInstance(dynamic data) async {
    await setInstanceString('authKey', data['user_token']);
    // log('here');
    dynamic result = await apiProfile.fetchProfile();
    // log('result profile $result');

    if (result != null && result['success']) {
      Timer(
        const Duration(
          seconds: 3,
        ),
        () {
          Navigator.of(context).pushReplacementNamed("/mainMenuPage");
        }
      );

      showAppNotification(
        context: context,
        desc: 'Your account is ready to use. you will be redirected to the Home page.',
        onSubmit: () {
          Navigator.of(context).pushReplacementNamed("/mainMenuPage");
        }
      );
    } else {
      // ignore: use_build_context_synchronously
      Flushbar(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(8.0),
        message: 'Terjadi kesalahan',
        duration: const Duration(seconds: 3),
      ).show(context);

      Timer(
        const Duration(
          seconds: 3,
        ),
        () {
          Navigator.of(context).pop();
        }
      );
    }
  }

  @override
  void initState() {
    super.initState();

    initFirebase();
    startTimer();

    if (TargetPlatform.iOS == defaultTargetPlatform) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
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

  void _callPostApi() {
    setState(() {
      isLoading = true;
    });
    
    String url = widget.data['endpoint'];

    dynamic body = {
      ...widget.data['body'],
      "otp": pinController.text,
    };

    if (widget.data['endpoint'] == 'login') {
      body['device_token'] = tokenFcm;
    }

    // log("url = $url body = $body");

    http.post(url, body: body).then((res) {
      setState(() {
        isLoading = false;
        responseOtp = res['success'] == true ? '' : res['msg'];
      });

      Future.delayed(Duration(milliseconds: 500)).then((value) {
        // log('res success $res');

        if (res['success'] == true) {
          setState(() {
            storage.setItem("authKey", res['data']['user_token']);
          });
          
          // login redirect
          if (widget.data['endpoint'] == 'login') {
            setDataInstance(res['data']);

            // firebase analytics
            pushGALogin();

            // logger
            ApiLogger().fetchLogger(page: 'login', value: jsonEncode(body));
          }

          // register redirect
          if (widget.data['endpoint'] == 'register') {
            Timer(
              const Duration(
                seconds: 3,
              ),
              () {
                Navigator.of(context).pushReplacementNamed("/loginPage");
              }
            );

            showAppNotification(
              context: context,
              desc: 'Your account is ready to use. you will be redirected to the Login page.',
              onSubmit: () {
                Navigator.of(context).pushReplacementNamed("/loginPage");
              }
            );

            // firebase analytics
            pushGASignUp();

            // logger
            ApiLogger().fetchLogger(page: 'register', value: jsonEncode(body));
          }
        } else {
          // Flushbar(
          //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          //   flushbarPosition: FlushbarPosition.TOP,
          //   borderRadius: BorderRadius.circular(8.0),
          //   message: res['msg'],
          //   duration: Duration(seconds: 3),
          // )..show(context);
        }
      }).catchError((onError) {
        setState(() {
          isLoading = false;
          responseOtp = 'Terjadi kesalahan';
        });

        log('err $onError');

        Flushbar(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          flushbarPosition: FlushbarPosition.TOP,
          borderRadius: BorderRadius.circular(8.0),
          message: 'Terjadi kesalahan',
          duration: Duration(seconds: 3),
        )..show(context);
      });
    });
  }

  void _callResendCode() {
    isProses = true;
    setState(() {
      isLoading = true;
    });
    String url = 'gettoken';
    dynamic body = {
      "kode_referral": widget.data["kode_referral"],
      "fullname": widget.data["fullname"],
      "nohp": widget.data["nohp"],
      "gender": widget.data["gender"],
      "dob": widget.data["dob"],
      "hobby": widget.data["hobby"],
      "pass": widget.data["pass"],
      "email": widget.data["email"],
      "noipl": widget.data["noipl"],
      "resend": 1
    };
    
    // log("url = $url body = $body");
    http.post(url, body: body).then((res) {
      // log("res = $res");

      setState(() {
        isLoading = false;
        responseOtp = res['success'] == true ? '' : res['msg'];
      });

      Future.delayed(Duration(milliseconds: 500)).then((value) {
        if (res['success'] == false) {
          isProses = false;

          // Flushbar(
          //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          //   flushbarPosition: FlushbarPosition.TOP,
          //   borderRadius: BorderRadius.circular(8.0),
          //   message: res['msg'],
          //   duration: Duration(seconds: 3),
          // )..show(context);
        } else {
          isProses = false;
          // if (res['msg']['msg'].toString() != "null") {
          //   Flushbar(
          //     margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          //     flushbarPosition: FlushbarPosition.TOP,
          //     borderRadius: BorderRadius.circular(8.0),
          //     message: res['msg']['msg'],
          //     duration: Duration(seconds: 3),
          //   )..show(context);
          // }
        }
      });
    }).catchError((onError) {
      setState(() {
        isLoading = false;
        responseOtp = 'Terjadi Kesalahan';
      });
    });
  }

  final defaultPinTheme = PinTheme(
      width: 65,
      height: 65,
      textStyle: const TextStyle(
        fontSize: 32,
        color: Constants.redTheme,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.colorFormInput,
      ),
  );

  Widget errorText() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
              responseOtp,
              textAlign: TextAlign.center,
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
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Directionality(
              // Specify direction if desired
              textDirection: TextDirection.ltr,
              child: Pinput(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                controller: pinController,
                focusNode: focusNode,
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsUserConsentApi,
                listenForMultipleSmsOnAndroid: true,
                defaultPinTheme: defaultPinTheme,
                keyboardType: TextInputType.text,
                // validator: (value) {
                //   if (responseOtp == '') {
                //     return '';
                //   }
                  
                //   return responseOtp;
                // },
                // onClipboardFound: (value) {
                //   log('onClipboardFound: $value');
                //   pinController.setText(value);
                // },
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) {
                  // log('onCompleted: $pin');
                },
                onChanged: (value) {
                  // log('onChanged: $value');
                  if (responseOtp != '') {
                    setState(() {
                      responseOtp = '';
                    });
                  }
                },
                // cursor: Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Container(
                //       margin: const EdgeInsets.only(bottom: 9),
                //       width: 22,
                //       height: 1,
                //       color: Constants.redTheme,
                //     ),
                //   ],
                // ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Constants.redTheme),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: Color(0xFFEEE6FD),
                    border: Border.all(color: responseOtp != '' ? Colors.redAccent : Colors.transparent),
                  ),
                ),
                // errorPinTheme: defaultPinTheme.copyBorderWith(
                //   border: Border.all(color: Colors.redAccent),
                // ),
              ),
            ),

            if (responseOtp != '') errorText(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyPage();
  }

  AppBar appBar() {
    return AppBar(
      iconTheme: IconThemeData(
        color: Constants.redTheme, //change your color here
      ),
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      actions: <Widget>[],
    );
  }

  Widget header() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Flexible(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.start,
                  children: [
                    Text(
                      widget.data['message']??'',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Constants.colorText
                      ),
                    ),
                    // Text(
                    //   "homerun@gmail.com",
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Constants.redTheme,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget action() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              children: [
                Expanded(
                  child: new Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.02,
                    decoration: BoxDecoration(
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
                          _callPostApi();
                        },
                        child: Center(
                          child: Text(
                            "Verify Now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (_start <= 0) {
                      _callResendCode();
                    }
                  },
                  child: Text(
                    _start <= 0 ? "Resend Code " : "Resend Code in ",
                    style: TextStyle(
                      fontSize: 12,
                      color: _start <= 0 ? Constants.redTheme : Constants.colorCaption,
                      fontWeight: _start <= 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),

                if (_start > 0) Text(_printDuration(_start),
                  style: TextStyle(
                      fontSize: 12,
                      color: Constants.redTheme,
                      fontWeight: FontWeight.w500,
                    )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyPage() {
    return LoadingFallback(
      isLoading: isLoading,
      child: Scaffold(
        appBar: appBar(),
        key: _key,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                child: Expanded(
                  child: ListView(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.81,
                              child: Column(
                                children: [
                                  header(),
                                  SizedBox(height: 60),
                                  SizedBox(height: 60),
                                  form(),
                                  SizedBox(height: 60),
                                  action(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
