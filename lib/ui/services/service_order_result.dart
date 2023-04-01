import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:appid/ui/main_menu.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
// import 'package:appid/component/HttpService.dart';
// import 'package:appid/component/size_config.dart';
// import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:http/http.dart' as http;
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/size_config.dart';

class ServiceOrderResultPage extends StatefulWidget {
  const ServiceOrderResultPage({super.key});

  @override
  ServiceOrderResultPageState createState() => ServiceOrderResultPageState();
}

class ServiceOrderResultPageState extends State<ServiceOrderResultPage> {
  // final HttpService http = HttpService();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool statusClose = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingFallback(
        isLoading: isLoading,
        child: Scaffold(
          key: _key,
          backgroundColor: Constants.colorWhite,
          body: SafeArea(
              child: OnBoardingContent(
            title: 'Order Successfull',
            image: 'assets/images/state/success-payment.png',
            subtitle:
                'Your order has been successfully added, please view in activity',
          )),
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
  }) : super(key: key);

  final String title, image, subtitle;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              image,
              height: width / 3,
              width: width / 3,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Constants.colorTitle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: Constants.colorText),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 32),
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
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => MainMenuPage(
                                indexTab: 1,
                              )));
                            },
                            child: const Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Activity',
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
