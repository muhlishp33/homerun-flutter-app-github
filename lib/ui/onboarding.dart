import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:appid/api/api_login_guest.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

// import 'package:appid/component/HttpService.dart';
// import 'package:appid/component/size_config.dart';
// import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/size_config.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  OnBoardingState createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  // final HttpService http = HttpService();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool statusClose = false;
  bool isLoading = false;

  @override
  void initState() {
    _getBoardData();
    super.initState();

    if (TargetPlatform.iOS == defaultTargetPlatform) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageBoardController.dispose();
  }

  void close() {
    var duration = const Duration(seconds: 2);
    Timer(duration, () {
      statusClose = false;
    });
  }

  int currentPage = 0;
  final PageController _pageBoardController = PageController(initialPage: 0);

  List<dynamic> boardData = [
    {
      "img": "assets/images/onboarding/On-boarding-01.png",
      "title": "Welcome to Homerun!",
      "description": "Why settle for less when you can hire the best?"
    },
    {
      "img": "assets/images/onboarding/On-boarding-02.png",
      "title": "Easy Booking With Homerun",
      "description": "You can choose and book our services easily"
    },
    {
      "img": "assets/images/onboarding/On-boarding-03.png",
      "title": "Run With Us",
      "description": "Register now and score all the possibilities right away!"
    },
    {
      "img": "assets/images/onboarding/On-boarding-04.png",
      "title": "Welcome to Homerun!",
      "description": "Bebas drama urusan rumah!"
    },
  ];

  _getBoardData() async {
    // Uri url =
    //     Uri.parse('https://api.onesmile.digital/api-v2/onboarding-screen/page');

    // try {
    //   var response = await http.get(url);
    //   var res = jsonDecode(response.body);

    //   if (response.statusCode == 200) {
    //     if (res['success'] == true) {
    //       setState(() {
    //         boardData = res['data'];
    //       });
    //     }
    //     log('response.statusCode == 200 === $res');
    //   } else {
    //     //       Navigator.of(context).pushReplacementNamed('/loginPage');

    //     log('response.statusCode != 200');
    //     throw Exception('Terjadi kesalahan harap mencoba lagi');
    //   }

    //   setState(() {
    //     isLoading = false;
    //   });
    // } catch (error) {
    //   //       Navigator.of(context).pushReplacementNamed('/loginPage');
    //   log('On Boarding error === $error');

    setState(() {
      isLoading = false;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    bool isFinish = currentPage == boardData.length - 1;

    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingFallback(
        isLoading: isLoading,
        child: Scaffold(
          key: _key,
          backgroundColor: isFinish ? Constants.redTheme : Constants.colorWhite,
          bottomNavigationBar:
              isLoading == false && boardData.isNotEmpty && !isFinish
                  ? _buildBottomAppBar()
                  : const SizedBox(),
          body: SafeArea(
            child: isLoading == false && boardData.isNotEmpty
                ? PageView.builder(
                    controller: _pageBoardController,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });

                      bool isHasFinish = value == boardData.length - 1;

                      if (isHasFinish) {
                        if (TargetPlatform.iOS == defaultTargetPlatform) {
                          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
                        } else {
                          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                            statusBarColor: Colors.transparent,
                            statusBarIconBrightness: Brightness.light,
                          ));
                        }
                      } else {
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
                    },
                    itemCount: boardData.length,
                    itemBuilder: (context, index) => OnBoardingContent(
                      title: boardData[index]["title"],
                      image: boardData[index]["img"],
                      subtitle: boardData[index]["description"],
                      isFinish: isFinish,
                      onChangeLoading: (value) {
                        setState(() {
                          isLoading = value;
                        });
                      }
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      elevation: 0,
      color: Constants.colorWhite,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    boardData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 5),
                      height: 10,
                      width: currentPage == index ? 10 : 10,
                      decoration: BoxDecoration(
                          color: currentPage == index
                              ? Constants.redTheme
                              : Constants.redThemeUltraLight,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 32),
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Constants.redTheme,
                  borderRadius: BorderRadius.circular(120),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // _pageBoardController.nextPage(
                      //   duration: const Duration(milliseconds: 200),
                      //   curve: Curves.ease,
                      // );

                      if (defaultTargetPlatform == TargetPlatform.iOS) {

                      }
                      
                      _pageBoardController.jumpToPage(boardData.length - 1);
                    },
                    child: const Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Constants.colorWhite,
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
    );
  }
}

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent({
    Key? key,
    required this.title,
    required this.image,
    required this.subtitle,
    required this.isFinish,
    required this.onChangeLoading,
  }) : super(key: key);

  final String title, image, subtitle;
  final bool isFinish;
  final Function onChangeLoading;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (isFinish) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              image,
              height: MediaQuery.of(context).size.width * 0.6,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            
            Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Constants.colorWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: Constants.colorWhite),
                )
              ],
            ),

            // balancing
            SizedBox(),
            
            Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.redTheme,
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                            color: Constants.colorWhite, width: 1.5)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/loginPage');
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.colorWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.colorWhite,
                        borderRadius: BorderRadius.circular(120),
                        border:
                            Border.all(color: Constants.redTheme, width: 1.5)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/register2Page');
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Daftar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.redTheme,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (defaultTargetPlatform == TargetPlatform.iOS) Container(
                  // padding: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border:
                            Border.all(color: Constants.redTheme, width: 1.5)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          onChangeLoading(true);
                          ApiLoginGuest fetchLoginGues = ApiLoginGuest();
                          await fetchLoginGues.fetchLoginGuest();
                          onChangeLoading(false);
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Masuk sebagai Mode Tamu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.colorWhite,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // balancing
            SizedBox(),
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              image,
              height: width,
              width: width,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: <Widget>[
                
                  Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Constants.colorTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, color: Constants.colorCaption),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
