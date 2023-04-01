import 'dart:async';
import 'package:flutter/material.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/size_config.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  SubscriptionPageState createState() => SubscriptionPageState();
}

class SubscriptionPageState extends State<SubscriptionPage> {
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingFallback(
        isLoading: isLoading,
        child: Scaffold(
          key: _key,
          backgroundColor: Constants.colorWhite,
          body: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Image.asset(
                    'assets/images/subscription/subs-top-bg.png',
                    width: width,
                  ),
                ),
                Positioned(
                  bottom: -(width * 0.2),
                  child: Image.asset(
                    'assets/images/subscription/subs-bottom-bg.png',
                    width: width * 0.75,
                  ),
                ),
                const OnBoardingContent(
                  title: 'We’re launching soon',
                  image: 'assets/images/subscription/subs-illustration.png',
                  subtitle: 'We are going to launch our service very soon.\nStay tune!',
                ),
                Column(
                  children: [
                    SizedBox(
                      width: width / 4,
                      // color: Colors.red,
                      child: const AspectRatio(
                        aspectRatio: 16 / 9,
                      ),
                    ),

                    // greetings
                    Container(
                      width: width,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: const [
                                Text(
                                  'Subscription',
                                  style: TextStyle(
                                      color: Constants.colorWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: width * 0.2),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: width,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Constants.colorTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, color: Constants.colorCaption),
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
