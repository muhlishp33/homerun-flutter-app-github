import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:appid/api/api_profile.dart';
import 'package:appid/component/widget/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/helper/analytics.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<ProfilPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final HttpService http = HttpService();
  final ApiProfile apiProfile = ApiProfile();
  final LocalStorage storage = LocalStorage('homerunapp');

  bool statusClose = false;
  dynamic dataprofil;
  dynamic information;
  dynamic objProfile = {
    'fullname': '',
    'email': '',
    'phone': '',
    'is_guest': true,
  };
  String photo = '';

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    // handle by navigator main_menu.dart
    // apiProfile.fetchProfile();
    
    if (!kIsWeb) {
      _initPackageInfo();
    }

    _initProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _initProfile() async {
    dynamic profile = await getInstanceJson('profile');
    dynamic getInformation = await getInstanceJson('information');

    // log('_profile $profile');

    setState(() {
      information = getInformation;
      objProfile = {
        'fullname': profile != null ? profile['fullname'] : '',
        'email': profile != null ? profile['email'] : '',
        'phone': profile != null ? profile['phone'] : '',
        'is_guest': profile != null ? profile['is_guest'] : true,
      };
    });
  }

  void close() {
    var duration = const Duration(seconds: 2);
    Timer(duration, () {
      statusClose = false;
    });
  }

  void _onRefresh() async {
    dynamic profile = await apiProfile.fetchProfile();

    _initProfile();

    if (profile['success']) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  handleLogout() {
    storage.clear();
    clearInstance();

    Navigator.pushReplacementNamed(context, '/loginPage');
  }

  void onDeactivate() {
    Navigator.of(context).pop();

    http.post('account/disactive').then((res) {
      // log('res account/disactive $res');

      if (res['success']) {
        Timer(
          const Duration(
            seconds: 3
          ),
          () {
            handleLogout();
          }
        );

        showAppNotification(
          context: context,
          title: 'Success',
          desc: res['msg'],
          onSubmit: () {
            handleLogout();
          }
        );
      } else {
        Helper(context: context).flushbar(msg: res['msg'], success: false);
      }
    })
    .catchError((err) {
      log('err account/disactive $err');

      Helper(context: context).flushbar(msg: 'Terjadi kesalahan', success: false);
    });
  }

  void onLogout() {
    http.post('logout').then((res) {
      // log('res logout $res');

      // if (res['success']) {
        handleLogout();
      // } else {
      //   Helper(context: context).flushbar(msg: res['msg'], success: false);
      // }
    })
    .catchError((err) {
      log('err logout $err');

      handleLogout();

      // Helper(context: context).flushbar(msg: 'Terjadi kesalahan', success: false);
    });
  }

  void onPressDeactivate() {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        content: Container(
          width: width - 40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure want to disactivate account?',
                style: TextStyle(
                  color: Constants.colorTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Your account will be disactivate and will be not able to sign in.',
                style: TextStyle(
                  color: Constants.colorCaption,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          onDeactivate();
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Constants.redTheme,
                        ),
                        child: const Text(
                          'Deactivate',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                                width: 1.0, color: Constants.redTheme),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Constants.redTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressLogout() {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        content: Container(
          width: width - 40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure want to sign out?',
                style: TextStyle(
                  color: Constants.colorTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'You will be asked to verify your identity the next time you sign in.',
                style: TextStyle(
                  color: Constants.colorCaption,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          onLogout();
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Constants.redTheme,
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                                width: 1.0, color: Constants.redTheme),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Constants.redTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double paddingBottom = MediaQuery.of(context).padding.bottom + 24.0;
    
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
                color: Colors.black26, borderRadius: BorderRadius.circular(4)),
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
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            automaticallyImplyLeading: false,
            backgroundColor: Constants.colorWhite,
            centerTitle: false,
            title: Container(
              padding: EdgeInsets.only(left: 20),
              child: Text('Profile', style: Constants.textAppBar3)
            ),
          ),
          body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: ListView(
                        padding: const EdgeInsets.all(0),
                        children: <Widget>[
                          Container(
                            // margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: const Alignment(-1, 1),
                                  end: Alignment(1, -1),
                                  colors: <Color>[
                                    Color(0xFF9D59FF),
                                    Constants.redTheme,
                                  ],
                                  tileMode: TileMode.clamp,
                                ),
                              ),
                              child: GestureDetector(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // avatar
                                    // Container(
                                    //   margin: const EdgeInsets.only(bottom: 20),
                                    //   child: Center(
                                    //     child: photo != ''
                                    //         ? CircleAvatar(
                                    //             backgroundImage:
                                    //                 NetworkImage(photo),
                                    //             radius: 50,
                                    //             child: const Text('',
                                    //                 style: TextStyle(
                                    //                   color: Colors.white,
                                    //                   fontSize: 20,
                                    //                 ),
                                    //                 textAlign: TextAlign.center),
                                    //           )
                                    //         : CircleAvatar(
                                    //             backgroundColor: Colors.grey[200],
                                    //             radius: 50,
                                    //             child: const FaIcon(
                                    //                 FontAwesomeIcons.userLarge,
                                    //                 color: Constants.redTheme),
                                    //           ),
                                    //   ),
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            objProfile['fullname'],
                                            style: const TextStyle(
                                              color: Constants.colorWhite,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (!objProfile['is_guest']) InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/editProfilPage')
                                                .then(
                                              (value) async {
                                                await ApiProfile().fetchProfile();
                                                _initProfile();
                                              },
                                            );
                                          },
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Image.asset(
                                              'assets/images/icon/pen-edit.png',
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    if (!objProfile['is_guest']) Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 8),
                                            child: Image.asset(
                                              'assets/images/icon/sms.png',
                                              width: 12,
                                              height: 12,
                                            ),
                                          ),
                                          Text(
                                            (objProfile != null && 
                                                    objProfile["email"] != null)
                                                ? objProfile["email"]
                                                : '',
                                            style: const TextStyle(
                                              color: Constants.colorWhite,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!objProfile['is_guest']) Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 8),
                                            child: Image.asset(
                                              'assets/images/icon/call.png',
                                              width: 12,
                                              height: 12,
                                            ),
                                          ),
                                          Text(
                                            (objProfile != null &&
                                                    objProfile["phone"] != null)
                                                ? objProfile["phone"]
                                                : '',
                                            style: const TextStyle(
                                              color: Constants.colorWhite,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Constants.colorWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Constants.colorPlaceholder,
                                        offset: Offset(0, 1),
                                        blurRadius: 1),
                                  ]),
                              child: Column(
                                children: [
                                  // user info
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     border: Border(
                                  //       top: BorderSide(
                                  //         width: 0.5,
                                  //         color: Colors.grey.shade300,
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: InkWell(
                                  //     onTap: () async {
                                  //       dynamic data = {
                                  //         "dataprofil": dataprofil,
                                  //         "data": objProfile,
                                  //         "photo": photo
                                  //       };

                                  //       var result = await Navigator.pushNamed(
                                  //           context, '/infoProfilPage',
                                  //           arguments: data);
                                  //     },
                                  //     child: Container(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           horizontal: 30, vertical: 20),
                                  //       child: Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.spaceBetween,
                                  //         children: [
                                  //           const Text(
                                  //             "Informasi Pengguna",
                                  //             style: TextStyle(
                                  //               fontSize: 14,
                                  //               fontWeight: FontWeight.w600,
                                  //             ),
                                  //           ),
                                  //           Container(
                                  //             alignment: Alignment.centerRight,
                                  //             child: const FaIcon(
                                  //                 FontAwesomeIcons.chevronRight,
                                  //                 size: 15,
                                  //                 color: Colors.black),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  // my address
                                  if (!objProfile['is_guest']) Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final res = await Navigator.of(context)
                                            .pushNamed('/daftarAlamatPage');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/my-address.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "My Address",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // change password
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     border: Border(
                                  //       bottom: BorderSide(
                                  //         width: 0.5,
                                  //         color: Colors.grey.shade300,
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   child: InkWell(
                                  //     onTap: () async {
                                  //       dynamic data = {
                                  //         "dataprofil": dataprofil,
                                  //         "data": objProfile
                                  //       };
                                  //       Navigator.pushNamed(
                                  //           context, '/changePasswordPage',
                                  //           arguments: data);
                                  //     },
                                  //     child: Container(
                                  //       padding: const EdgeInsets.symmetric(vertical: 18),
                                  //       child: Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.spaceBetween,
                                  //         children: [
                                  //           const Text(
                                  //             "Ubah Kata Sandi",
                                  //             style: TextStyle(
                                  //               fontSize: 14,
                                  //               fontWeight: FontWeight.w500,
                                  //             ),
                                  //           ),
                                  //           Container(
                                  //             alignment: Alignment.centerRight,
                                  //             child: const FaIcon(
                                  //               FontAwesomeIcons.chevronRight,
                                  //               size: 15,
                                  //               color: Colors.black,
                                  //             ),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  // term conditions
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.pushNamed(
                                            context, '/syaratKetentuanPage');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/term-conditions.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "Term and Conditions",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // faq
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.pushNamed(
                                            context, '/faqPage');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/faq.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "FAQ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // cs
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        String phone_send_proof = information != null && information['phone_send_proof'] is String ? information['phone_send_proof'] : '';
                                        if (phone_send_proof == '') {
                                          return;
                                        }
                                        String url = 'https://wa.me/$phone_send_proof?text=Halo%20Customer%20Care';
                                        // log('url $url');
                                        Helper(context: context).launchURL(url);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/help.png',
                                                      width: 40,
                                                      height: 40,
                                                      ),
                                                ),
                                                const Text(
                                                  "Customer Service",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // disactivate
                                  if (!objProfile['is_guest']) Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        onPressDeactivate();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/disactivate.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "Disactivate Account",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // signout
                                  if (!objProfile['is_guest']) Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        onPressLogout();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/sign-out.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "SIgn Out",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (objProfile['is_guest']) Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        onLogout();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 12.0),
                                                  child: Image.asset(
                                                      'assets/images/profile/sign-out.png',
                                                      width: 40,
                                                      height: 40),
                                                ),
                                                const Text(
                                                  "SIgn In",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: const FaIcon(
                                                FontAwesomeIcons.chevronRight,
                                                size: 15,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 24, bottom: 12),
                                    child: Center(
                                      child: Text(
                                        "Versi ${_packageInfo.version}",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: paddingBottom),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
