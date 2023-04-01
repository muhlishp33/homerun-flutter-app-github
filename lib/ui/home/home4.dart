import 'dart:convert';
import 'dart:developer';
import 'package:appid/api/api_logger.dart';
import 'package:appid/api/api_profile.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/helper/analytic_by_firebase.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/activity/card_activities.dart';
import 'package:appid/ui/insight/card_insight_list.dart';
import 'package:appid/ui/main_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  final ApiProfile apiProfile = ApiProfile();

  dynamic stateProfile;
  dynamic stateBubble;

  int inboxCount = 0;

  // banner
  List bannerList = [];
  bool bannerLoading = true;

  // menu
  List menuList = [];
  bool menuLoading = true;

  // recent activities
  List recentActivityList = [];
  bool recentActivityLoading = true;

  // recent insight
  List recentInsightList = [];
  bool recentInsightLoading = true;

  // profile
  dynamic profile;
  dynamic datap;
  String photo = '';
  String nama = '';
  String nama2 = '';
  String kata = '';
  int merch = -1;

  // ipl
  dynamic ipl;
  int _current = 0;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    apiProfile.fetchProfile();
    _callGetData();

    // firebase analytics
    pushGALogEvent(
      eventName: 'main-page',
      eventValues: {
        'id': '',
        'title': 'home',
      }
    );

    // logger
    ApiLogger().fetchLogger(page: 'home', value: jsonEncode({
      'id': 'main-page',
      'title': 'home',
    }));
  }

  _callGetData() async {
    dynamic profile = await getInstanceJson('profile');
    dynamic objBubble = await getInstanceJson('bubble');

    setState(() {
      stateProfile = profile;
      stateBubble = stateBubble;
      inboxCount =
          objBubble['notification'] != null && objBubble['notification'] is int
              ? objBubble['notification']
              : objBubble['notification'] is String
                  ? objBubble['notification']
                  : 0;
    });

    // get banner home
    http.post('banner/home').then((res) {
      // log("reshome = $res");

      if (res['success'] == true) {
        // dynamic datagbr = res['msg']['banner_home'];
        setState(() {
          bannerList = res['data'];
          //   photo = res['msg']['photo'];
          //   nama = res['msg']['nama'];
          //   nama2 = res['msg']['nama2'];
          //   kata = res['msg']['kata'];
          //   datap = res['msg'];
          //   merch = res['msg']['merch'];
          //   ipl = res['msg']['ipl'];
        });
        // setInstanceString("homeData", jsonEncode(res['msg']));
      } else {
        // storage.clear();
        // clearInstance();
        // Navigator.pushReplacementNamed(context, '/loginPage');
      }

      setState(() {
        bannerLoading = false;
      });
    }).catchError((err) {
      log('err banner home $err');

      setState(() {
        bannerLoading = false;
      });
    });

    // get menu home
    http.post('menu').then((res) {
      // log("res menu = $res");

      if (res['success'] == true) {
        setState(() {
          menuList = res['data'];
        });
      } else {}

      setState(() {
        menuLoading = false;
      });
    }).catchError((err) {
      log('err menu $err');

      setState(() {
        menuLoading = false;
      });
    });

    // recent activities
    if (!stateProfile['is_guest']) {
      http.post('activity/summary').then((res) {
        // log("res activity/summary = $res");

        if (res['success'] == true) {
          setState(() {
            recentActivityList = res['data'];
          });
        } else {}

        setState(() {
          recentActivityLoading = false;
        });
      }).catchError((err) {
        log('err activity summary $err');

        setState(() {
          recentActivityLoading = false;
        });
      });
    }

    // recent insight
    http.post('article').then((res) {
      // log("res article $res");

      if (res['success'] == true) {
        setState(() {
          recentInsightList = res['data'];
        });
      } else {}

      setState(() {
        recentInsightLoading = false;
      });
    }).catchError((err) {
      log('err article $err');

      setState(() {
        recentInsightLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double paddingBottom = MediaQuery.of(context).padding.bottom + 24.0;
    final double paddingTop = width / 4.0;

    return Scaffold(
      // backgroundColor: Constants.redTheme,
      body: LoadingFallback(
          isLoading: false, // isLoadingDeepLink,
          child: Stack(
            children: [
              // bg stack
              Positioned(
                top: 0,
                child: Container(
                    width: width,
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          "assets/images/home/heading-img.png",
                          fit: BoxFit.cover,
                        ))),
              ),
              SafeArea(
                child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: () async {
                      await Future.delayed(Duration(milliseconds: 1000));
                      _refreshController.refreshCompleted();
                      // _refreshController.refreshFailed();
                    },
                    onLoading: () async {
                      await Future.delayed(Duration(milliseconds: 1000));
                      _refreshController.loadComplete();
                    },
                    child: SingleChildScrollView(
                      // padding: EdgeInsets.only(bottom: paddingBottom),
                      padding: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          // divider
                          // Container(
                          //   width: paddingTop,
                          //   color: Colors.red,
                          //   child: AspectRatio(
                          //     aspectRatio: 16 / 9,
                          //   ),
                          // ),

                          // greetings
                          Container(
                            width: width,
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Expanded(
                                //   child: Wrap(
                                //     crossAxisAlignment: WrapCrossAlignment.start,
                                //     children: [
                                //       const Text(
                                //         'Hello, ',
                                //         style: TextStyle(
                                //             color: Constants.colorWhite,
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.w500),
                                //       ),
                                //       Text(
                                //         stateProfile != null
                                //             ? stateProfile['fullname'] + '!'
                                //             : '',
                                //         style: const TextStyle(
                                //             color: Constants.colorWhite,
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.w700),
                                //         maxLines: 1,
                                //         overflow: TextOverflow.ellipsis,
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset('assets/logo/logo-horizontal.png',
                                        width: width * 0.3),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/inboxPage');
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                        child: Image.asset(
                                          'assets/images/icon/notif-default.png',
                                          height: 24,
                                        ),
                                      ),

                                      // count notif
                                      if (inboxCount > 0)
                                        Positioned(
                                          top: 2,
                                          right: 5,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Constants.colorError,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // content
                          Container(
                            padding: EdgeInsets.only(top: 20.0),
                            margin: EdgeInsets.only(top: 20.0),
                            decoration: new BoxDecoration(
                              color: Constants.colorWhite,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(20.0),
                                topRight: const Radius.circular(20.0),
                              )
                            ),
                            child: Column(
                              children: [
                                // menu header
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Our Services',
                                    style: TextStyle(
                                        color: Constants.colorTitle,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                // menu content
                                Container(
                                  width: width,
                                  padding: EdgeInsets.only(left: 20),
                                  child: Wrap(
                                    children: menuList.map((item) {
                                      return InkWell(
                                        onTap: () {
                                          dynamic args = item;
                                          Navigator.pushNamed(
                                              context, '/servicesPage',
                                              arguments: args);

                                          // firebase analytics
                                          pushGALogEvent(
                                            eventName: 'menu-home',
                                            eventValues: {
                                              'id': args['id'],
                                              'title': item['services_name'],
                                            }
                                          );

                                          // logger
                                          ApiLogger().fetchLogger(
                                            page: item['services_name'],
                                            value: jsonEncode({
                                              'id': args['id'],
                                              'title': item['services_name'],
                                            }));
                                        },
                                        child: Container(
                                          width: (width - 20) / 4,
                                          padding: EdgeInsets.only(right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: (width - 40) / 4,
                                                height: (width - 40) / 4,
                                                child: Image.network(
                                                    item['services_icon']),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                item['services_name'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Constants.colorTitle,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 18,
                                ),

                                // banner header
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Event & Promo',
                                    style: TextStyle(
                                        color: Constants.colorTitle,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                // banner content
                                Container(
                                  margin: EdgeInsets.only(top: 8, bottom: 14),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                        aspectRatio: 12 / 4, // aslinya 12 / 5
                                        viewportFraction: 0.85,
                                        enlargeCenterPage: false,
                                        autoPlay: true,
                                        autoPlayInterval: Duration(seconds: 5),
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        }),
                                    items: (bannerLoading)
                                        ? [
                                            Shimmer.fromColors(
                                              baseColor:
                                                  Constants.colorPlaceholder,
                                              highlightColor:
                                                  Constants.colorPlaceholder,
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Constants.colorPlaceholder,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                width: width,
                                              ),
                                            ),
                                          ]
                                        : bannerList.map((i) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return GestureDetector(
                                                  onTap: () async {},
                                                  child: Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                    child: CachedNetworkImage(
                                                      width: width,
                                                      imageUrl: i['image'],
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                            // boxShadow: const [
                                                            //   BoxShadow(
                                                            //     color: Constants.colorTitle,
                                                            //     offset: Offset(0, 0.5),
                                                            //     blurRadius: 0.5),
                                                            // ],
                                                            image: DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit:
                                                                    BoxFit.cover),
                                                            color: Constants
                                                                .colorPlaceholder,
                                                          ),
                                                          child: Text(""),
                                                        );
                                                      },
                                                      placeholder: (context,
                                                              url) =>
                                                          Image.asset(
                                                              'assets/images/loader.gif'),
                                                      errorWidget:
                                                          (context, url, error) =>
                                                              Icon(Icons.error),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }).toList(),
                                  ),
                                ),

                                // banner indicator
                                Container(
                                  alignment: Alignment.center,
                                  // alignment: Alignment.bottomLeft,
                                  // width: width - 40,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: bannerList.map((url) {
                                        int index = bannerList.indexOf(url);
                                        return Container(
                                          width: 6.0,
                                          height: 6.0,
                                          margin: EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _current == index
                                                  ? Constants.redTheme
                                                  : Constants.redThemeUltraLight),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),

                                // recent activities
                                SizedBox(
                                  height: 21,
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Your Recent Activities',
                                        style: TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MainMenuPage(
                                                        indexTab: 1,
                                                      )));
                                        },
                                        child: Text(
                                          'View all',
                                          style: TextStyle(
                                              color: Constants.redTheme,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                recentActivityList.isNotEmpty
                                    ? Container(
                                        padding:
                                            EdgeInsets.only(left: 20, right: 20),
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          children:
                                              recentActivityList.map((item) {
                                            return CardActivities(item);
                                          }).toList(),
                                        ),
                                      )
                                    : Center(
                                        child: Container(
                                          width: width / 2,
                                          height: width / 2,
                                          child: Image.asset(
                                              'assets/images/state/empty-state-img.png'),
                                        ),
                                      ),

                                // recent insight
                                SizedBox(
                                  height: 2, // figma 18, ditambah 16 dari card activities
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Your Insight',
                                        style: TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed('/insightPage');
                                        },
                                        child: Text(
                                          'View all',
                                          style: TextStyle(
                                              color: Constants.redTheme,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                recentInsightList.isNotEmpty
                                    ? Container(
                                        padding:
                                            EdgeInsets.only(left: 20, right: 20),
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          children:
                                              recentInsightList.map((item) {
                                            return CardInsightList(item);
                                          }).toList(),
                                        ),
                                      )
                                    : Center(
                                        child: Container(
                                          width: width / 2,
                                          height: width / 2,
                                          child: Image.asset(
                                              'assets/images/state/empty-state-img.png'),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          )),
    );
  }
}
