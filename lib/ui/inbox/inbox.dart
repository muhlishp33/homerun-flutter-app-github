import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  List _listInbox = [];
  bool _isLoading = true;
  bool _nextLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    if (_page <= 0) {
      setState(() {
        _isLoading = false;
        _nextLoading = false;
      });
      return;
    }

    // log('_page $_page');

    http.post('inbox', body: {
      'page': _page,
    }).then((res) {
      // log('res inbox ${res}');

      int resLength = 0;

      if (res['success'] == true) {
        if (res['data'] is List) {
          resLength = res['data'].length;
        }
      }

      setState(() {
        _listInbox.addAll(res['data']);
        _isLoading = false;
        _nextLoading = false;

        if (resLength <= 0) {
          _page = -1;
        } else {
          _page = _page + 1;
        }
      });
    }).catchError((err) {
      log('err inbox ${err}');

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

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _listInbox.length,
      //physics: ClampingScrollPhysics(),
      // controller: type == 1 ? _controller : null,
      itemBuilder: (BuildContext context, int index) {
        dynamic data = _listInbox[index];
        DateTime now = DateTime.now();
        DateTime parseEndDate = DateTime.parse(data['push_notification_date']);
        String endDateFormat = DateFormat('dd MMM | HH:mm').format(parseEndDate);
        if (parseEndDate.isAtSameMomentAs(now)) {
          endDateFormat = DateFormat('Today | HH:mm').format(parseEndDate);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // if (data['type'].toString() == '2') {
                //   Navigator.of(context)
                //       .pushNamed('/detailInboxTagihanPage', arguments: data);
                // } else {
                //   Navigator.of(context)
                //       .pushNamed('/detailInboxPage', arguments: data)
                //       .then(
                //     (value) {
                //       setState(() {
                //         data['is_read'] = true;
                //       });
                //     },
                //   );
                // }
              },
              child: Card(
                  elevation: 0.5,
                  color: Constants.colorWhite, // data['is_read'] ? Colors.white : Color(0xFFF9F5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/activities/cleaning-services-circle.png',
                            width: width * 0.1,
                            height: width * 0.1,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['push_notification_title'] is String ? data['push_notification_title'] : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Constants.colorTitle,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      endDateFormat,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Constants.colorCaption,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['push_notification_text'] is String ? data['push_notification_text'] : '',
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Constants.colorCaption,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            (index + 1 == _listInbox.length && _nextLoading)
                ? Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    height: 28,
                    margin: const EdgeInsets.only(top: 2, bottom: 2),
                    child: const CircularProgressIndicator(strokeWidth: 5.0))
                : const Center(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _key,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        // automaticallyImplyLeading: false,
        backgroundColor: Constants.colorWhite,
        centerTitle: false,
        title: Container(
          // padding: EdgeInsets.only(left: 20),
          child: Text('Inbox', style: Constants.textAppBar3)
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 5),
        width: MediaQuery.of(context).size.width,
        child: LoadingFallback(
          isLoading: _isLoading,
          child: LazyLoadScrollView(
            onEndOfPage: _getNextData,
            isLoading: _nextLoading,
            child: _listInbox.isNotEmpty ?
              _list()
            :
              Center(
                child: Container(
                  width: width / 2,
                  height: width / 2,
                  child: Image.asset('assets/images/state/empty-state-img.png'),
                ),
              ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
