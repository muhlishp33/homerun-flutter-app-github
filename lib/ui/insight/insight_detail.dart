import 'dart:async';
import 'dart:developer';

import 'package:appid/component/widget/index.dart';
import 'package:appid/component/widget/rating_bar.dart';
import 'package:appid/helper/color.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/main_menu_old.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class InsightDetailPage extends StatefulWidget {
  const InsightDetailPage(this.data, {super.key});

  final dynamic data;

  @override
  State<InsightDetailPage> createState() => _InsightDetailPageState();
}

class _InsightDetailPageState extends State<InsightDetailPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  dynamic objOrder = {
    "image": "",
    "created_date": "",
    "id": -1,
    "image": "",
    "title": "",
    "description": "",
    "article_category_name": "All",
    "link": null,
    "link_caption": "",
  };
  List listOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getData() {
    http.post('article/detail', body: {
      'article_id': widget.data['id'],
    }).then((res) {
      // log('res article/detail ${res}');

      if (res['success'] == true &&
          res['data'] != null
      ) {
        setState(() {
          objOrder = res['data'];
        });
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err article/detail ${err}');

      setState(() {
        _isLoading = false;
      });
    });
  }

  bool isValidDateTime(str) {
    if (str is !String) return false;
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void onSubmitDeepLink() {
    String link = objOrder['link'];

    if (link.startsWith('http') || link.startsWith('https')) {
      Helper(context: context).launchURL(link);
    } else {
      http.post('menu').then((res) {
        // log("res menu = $res");

        if (res['success'] == true) {
          List menuList = res['data'];
          dynamic item = menuList.firstWhere((e) => e['services_type'] == link, orElse: () {});
          if (item != null) {
            dynamic args = item;
            Navigator.pushNamed(context, '/servicesPage', arguments: args);
          }
        }
      }).catchError((err) {
        log('err menu $err');
      });
    }
    
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (context) =>
    //       MainMenuPage(
    //         indexTab: 0,
    //       ))
    // );

  }

  Widget renderPerCaption(String title, String caption) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16, bottom: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            caption,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget renderPerProblems(String title, List list) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((e) {
              return Container(
                margin: EdgeInsets.only(top: 14),
                child: Text(
                  e['information_name'] ?? 'No Info',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget renderPerServices(String title) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;

    DateTime parseDate;
    String dateFormat = '';

    if (objOrder['created_date'] is String && isValidDateTime(objOrder['created_date'])) {
      parseDate = DateTime.parse(objOrder['created_date']);
      dateFormat = DateFormat('dd MMM yyyy').format(parseDate);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16/9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    objOrder['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            Text(objOrder['article_category_name'],
                style: TextStyle(
                    color: Constants
                        .redTheme,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w400)),
            SizedBox(height: 2,),
            Text(objOrder['title'],
                style: TextStyle(
                    color: Constants.colorTitle,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                )),
            SizedBox(height: 8,),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(dateFormat,
                    style: TextStyle(
                        color: Constants
                            .colorCaption,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w400)),
              ],
            ),
            SizedBox(height: 18),

            Divider(
              height: 0.75,
            ),

            Container(
              margin: EdgeInsets.only(top: 12, bottom: 16),
              child: Text(objOrder['description'],
                style: TextStyle(
                    color: Constants.colorTitle,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w400,
                )
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // log('objOrder $objOrder');

    return Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          backgroundColor: Constants.colorWhite,
          centerTitle: true,
          title: Text('Details', style: Constants.textAppBar3),
          titleSpacing: 0,
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 5),
          width: MediaQuery.of(context).size.width,
          child: LoadingFallback(
            isLoading: _isLoading,
            child: _list(),
          ),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: objOrder['link'] is String ? BottomAppBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.redTheme,
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onSubmitDeepLink();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          objOrder['link_caption'],
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
        ) : null,
    );
  }
}
