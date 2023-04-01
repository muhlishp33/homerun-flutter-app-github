import 'dart:async';
import 'dart:developer';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/component/widget/rating_bar.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/size_config.dart';

class ServiceOrderReviewPage extends StatefulWidget {
  const ServiceOrderReviewPage(this.data, {super.key});

  final dynamic data;
  @override
  ServiceOrderReviewPageState createState() => ServiceOrderReviewPageState();
}

class ServiceOrderReviewPageState extends State<ServiceOrderReviewPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  int currentPage = 0;
  final PageController _pageBoardController = PageController(initialPage: 0);
  bool _isLoading = false;
  double _initialRating = 5.0;
  TextEditingController notesText = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageBoardController.dispose();
  }

  void onSubmitReview() {
    dynamic body = {
      "star": _initialRating.toInt(),
      "order_id": widget.data['id'], 
      "review": notesText.text,
    };

    // log('body $body');

    setState(() {
      _isLoading = true;
    });

    http.post('order/create-review', body: body).then((res) {
      // log('res order/create-review ${res}');

      if (res['success'] == true) {
        showAppNotification(
          context: context,
          title: 'Feedback Submited!',
          desc: 'Your feedback will be used in our improvement',
        );

        Timer(
          Duration(seconds: 3),
          () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainMenuPage(
              indexTab: 0,
            )));
          }
        );
      } else {
        Helper(context: context).flushbar(msg: res['msg'], success: false);
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err order/create-review ${err}');

      Helper(context: context).flushbar(msg: 'Terjadi kesalahan', success: false);

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: LoadingFallback(
        isLoading: _isLoading,
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
                    'assets/images/services/review-bg-top.png',
                    width: width,
                  ),
                ),
                OnBoardingContent(
                  title: 'Thank you for your order!',
                  image: 'assets/images/services/review-bg-mid.png',
                  subtitle: 'Leave some feedbacks so we can impove our services',
                  rating: _initialRating,
                  noteController: notesText,
                  onChangeValue: (val) {
                    setState(() {
                      _initialRating = val;
                    });
                  }
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Constants.redTheme,
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onSubmitReview();
                          },
                          child: const Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Submit Review',
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
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => MainMenuPage(
                              indexTab: 0,
                            )));
                          },
                          child: const Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Skip for now',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Constants.redTheme,
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
            ),
          )
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
    required this.rating,
    required this.noteController,
    required this.onChangeValue,
  }) : super(key: key);

  final String title, image, subtitle;
  final double rating;
  final TextEditingController noteController;
  final Function onChangeValue;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: width * 0.175),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                              fontSize: 12, color: Constants.colorCaption),
                        ),
                      ),
                      const SizedBox(height: 25),
                      RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        unratedColor: Colors.amber.withAlpha(50),
                        itemCount: 5,
                        itemSize: width * 0.125,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (val) {
                          onChangeValue(val);
                        },
                        updateOnDrag: true,
                      ),
                      // notes
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: CustomTextInput(
                          isHasHint: false,
                          // hintText: "Add Notes",
                          placeholder: "Write notes here (optional)",
                          controllerName: noteController,
                          enabled: true,
                          maxLines: 3,
                          minLines: 3,
                          isRequired: true,
                          onChangeText: () {},
                          onTap: () {},
                          onEditingComplete: () {},
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
