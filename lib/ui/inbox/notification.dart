import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/analytics.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);
  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  List _listNotif = [];
  bool _isLoading = true;
  bool _nextLoading = false;
  int _offset = 0;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getData() {
    if (_offset < 0) return;

    http.post('getnotif', body: {
      "sf": _offset,
      "search": '',
      'type': 'notification', //inbox
    }).then((res) {
      if (res['success'] == true) {
        List newData = _listNotif;
        newData.addAll(res['msg']);
        // log('offseeeett SIUUUU ${res['msg']}');
        setState(() {
          _listNotif = newData;
          _offset =
              res['msg'].length <= 0 ? -1 : _offset + res['msg'].length as int;
        });
      }

      setState(() {
        _isLoading = false;
        _nextLoading = false;
      });
    }).catchError((err) {
      setState(() {
        _isLoading = false;
        _nextLoading = false;
      });
    });
  }

  void _getNextData() {
    setState(() {
      _nextLoading = true;
    });
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _key,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Text('Notifikasi', style: Constants.textAppBar3),
      ),
      body: LoadingFallback(
        isLoading: _isLoading,
        child: LazyLoadScrollView(
          isLoading: _nextLoading,
          onEndOfPage: () {
            _getNextData();
          },
          child: SizedBox(
            width: width,
            child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _listNotif.length,
                itemBuilder: (BuildContext context, int index) {
                  dynamic item = _listNotif[index];

                  // (item);

                  return InkWell(
                    onTap: () {
                      // const String eventName = "notification-view";
                      // final Map<String, dynamic> eventValues = {
                      //   "af_content_id": "21",
                      //   "af_currency": "IDR",
                      //   "af_revenue": "0",
                      // };

                      Navigator.of(context).pushNamed('/notificationDetailPage',
                          arguments: item);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.5,
                        color: Colors.grey,
                      ))),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/home/icon_notif.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['judul'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  item['tgl'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
