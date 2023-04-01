import 'dart:async';
import 'dart:developer';

import 'package:appid/component/widget/index.dart';
import 'package:appid/component/widget/rating_bar.dart';
import 'package:appid/helper/color.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/insight/card_insight_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:shimmer/shimmer.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({super.key});

  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  // recent insight
  List recentInsightList = [];
  bool recentInsightLoading = true;

  // banner
  List bannerList = [];
  bool bannerLoading = true;
  int _current = 0;

  //category
  List categoryList = [];
  bool categoryLoading = true;

  // other
  ScrollController scrollController = ScrollController();
  TabController? _tabController;
  int currentIndexTab = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _getData() {
    // featured
    http.post('article', body: {
      'is_featured': true,
    }).then((res) {
      // log('res article featured ${res}');

      if (res['success'] == true && res['data'] != null) {
        setState(() {
          bannerList = res['data'];
        });
      }

      setState(() {
        bannerLoading = false;
      });
    }).catchError((err) {
      log('err article featured ${err}');

      setState(() {
        bannerLoading = false;
      });
    });

    // category
    http.post('article/category').then((res) {
      // log('res article/category ${res}');

      if (res['success'] == true && res['data'] is List && res['data'].length > 0) {
        setState(() {
          categoryList = res['data'];
          _tabController = TabController(length: res['data'].length, vsync: this);
        });
        
        int categoryId = res['data'][0]['id'];
        getFetchArticle(categoryId: categoryId, index: 0);
      }

      setState(() {
        categoryLoading = false;
      });
    }).catchError((err) {
      log('err article/category ${err}');

      setState(() {
        categoryLoading = false;
      });
    });
  }

  void getFetchArticle({
    required int categoryId,
    required int index,
  }) {
    http.post('article', body: {
      'is_featured': false,
      'category_id': categoryId,
    }).then((res) {
      // log('res article non ${res}');

      if (res['success'] == true && res['data'] != null) {
        setState(() {
          recentInsightList = res['data'];
        });
      }

      setState(() {
        recentInsightLoading = false;
      });
    }).catchError((err) {
      log('err article non ${err}');

      setState(() {
        recentInsightLoading = false;
      });
    });
  }

  bool isValidDateTime(str) {
    if (str is! String) return false;
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget renderTabHeader(item, index) {
    bool isActive = index == currentIndexTab;

    return Tab(
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Constants.redTheme : Constants.colorWhite,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            width: 1.5,
            color: Constants.redTheme,
          )
        ),
        child: Center(
          child: Text(
            item['name'],
            style: TextStyle(
              color: isActive ? Constants.colorWhite : Constants.redTheme,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        )
      ),
    );

    // return Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 16),
    //     decoration: BoxDecoration(
    //       color: isActive ? Constants.redTheme : Constants.colorWhite,
    //       borderRadius: BorderRadius.circular(20.0),
    //       border: Border.all(
    //         width: 1.5,
    //         color: Constants.redTheme,
    //       )
    //     ),
    //     child: Tab(text: item['name'])
    // );
  }

  Widget renderTabContent() {
    final double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          recentInsightLoading ?
            Center(
              child: Container(
                width: width / 2,
                height: width / 2,
                child: Center(
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Constants.redTheme),
              ),
                  ),
                )
              )
            )
          : recentInsightList.isNotEmpty
              ? Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: recentInsightList.map((item) {
                      return CardInsightList(item);
                    }).toList(),
                  ),
                )
              : Center(
                  child: Container(
                    width: width / 2,
                    height: width / 2,
                    child: Image.asset('assets/images/state/empty-state-img.png'),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;

    return NestedScrollView(
      controller: scrollController,
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              // banner header
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Featured Insights',
                      style: TextStyle(
                          color: Constants.colorTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15 - 8,
              ),
              // banner content
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 14),
                child: CarouselSlider(
                  options: CarouselOptions(
                      aspectRatio: 9 / 5.6,
                      viewportFraction: 1,
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
                            baseColor: Constants.colorPlaceholder,
                            highlightColor: Constants.colorPlaceholder,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Constants.colorPlaceholder,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: width,
                            ),
                          ),
                        ]
                      : bannerList.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              DateTime parseDate;
                              String dateFormat = '';

                              if (i['created_date'] is String &&
                                  isValidDateTime(i['created_date'])) {
                                parseDate = DateTime.parse(i['created_date']);
                                dateFormat =
                                    DateFormat('dd MMM yyyy').format(parseDate);
                              }
                              return GestureDetector(
                                onTap: () {
                                  dynamic args = {
                                    "id": i['id'],
                                  };
                                  Navigator.pushNamed(
                                      context, '/insightDetailPage',
                                      arguments: args);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1),
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: Constants.colorWhite,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Constants.colorPlaceholder,
                                              offset: Offset(0, 1),
                                              blurRadius: 1),
                                        ]),
                                    child: Column(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 12 / 5,
                                          child: CachedNetworkImage(
                                            width: width,
                                            imageUrl: i['image'],
                                            imageBuilder:
                                                (context, imageProvider) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                  // boxShadow: const [
                                                  //   BoxShadow(
                                                  //     color: Constants.colorTitle,
                                                  //     offset: Offset(0, 0.5),
                                                  //     blurRadius: 0.5),
                                                  // ],
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                  color: Constants
                                                      .colorPlaceholder,
                                                ),
                                                child: Text(""),
                                              );
                                            },
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                    'assets/images/loader.gif'),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 10.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(i['article_category_name'],
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .redTheme,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          i['title'],
                                                          style: TextStyle(
                                                            color: Constants
                                                                .colorTitle,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ]),
                                                  Text(dateFormat,
                                                      style: TextStyle(
                                                          color: Constants
                                                              .colorCaption,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
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

              // recent insight
              SizedBox(height: 18),
            ]),
          ),
        ];
      },
      body: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Articles',
                    style: TextStyle(
                        color: Constants.colorTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12,),
            
            if (!categoryLoading) Container(
              height: 34,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0 - 5.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: const BoxDecoration(),
                labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                onTap: (int index) {
                  setState(() {
                    recentInsightLoading = true;
                    recentInsightList = [];
                    currentIndexTab = index;
                  });
                  int categoryId = categoryList[index]['id'];
                  getFetchArticle(categoryId: categoryId, index: index);
                },
                tabs: [
                  for(int i = 0; i < categoryList.length; i++) renderTabHeader(categoryList[i], i)
                ],
              ),
            ),
            // tab bar view here
            if (!categoryLoading) Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categoryList.map((e) {
                  return renderTabContent();
                }).toList()
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _key,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: true,
        backgroundColor: Constants.colorWhite,
        centerTitle: true,
        title: Text('Our Insight', style: Constants.textAppBar3),
        titleSpacing: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 5),
        width: MediaQuery.of(context).size.width,
        child: LoadingFallback(
          isLoading: categoryLoading,
          child: _list(),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
