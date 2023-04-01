import 'dart:developer';

import 'package:appid/component/shared_preferences.dart';
import 'package:appid/helper/color.dart';
import 'package:appid/ui/activity/card_activities.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

List listFilterStatus = [
  { 'label': 'All', 'value': '' },
  { 'label': 'Ordered', 'value': 'ORDERED' },
  { 'label': 'On Process', 'value': 'ON PROCESS' },
  { 'label': 'Completed', 'value': 'COMPLETED' },
  { 'label': 'Paid', 'value': 'PAID' },
];

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  List listActivities = [];
  bool _isLoading = true;
  bool _nextLoading = false;
  int _page = 1;
  dynamic selectedFilterStatus = listFilterStatus[0];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    dynamic profile = await getInstanceJson('profile');

    if (profile['is_guest']) {
      setState(() {
        _isLoading = false;
        _nextLoading = false;
      });
      
      return;
    }
    
    if (_page <= 0) {
      setState(() {
        _isLoading = false;
        _nextLoading = false;
      });
      return;
    }

    dynamic body = {
      'search': '',
      'page': _page,
      "filter" : {
        // "date" : "2020-12-31",
        // "type" : "GAS", // GAS, GALON, AC, CLEANING, SUMMARY
        "status" : selectedFilterStatus['value'],
      },
    };

    // log('body $body');

    http.post('activity', body: body).then((res) {
      // log('res activity ${res}');

      int resLength = 0;

      if (res['success'] == true) {
        if (res['data'] is List) {
          resLength = res['data'].length;
          // log('resLength $resLength');
        }
      }

      setState(() {
        listActivities.addAll(res['data']);
        _isLoading = false;
        _nextLoading = false;

        if (resLength <= 0) {
          _page = -1;
        } else {
          _page = _page + 1;
        }
      });
    }).catchError((err) {
      log('err activity $err');

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

  void _getFilterStatusData(dynamic filterStatus) {
    setState(() {
      _isLoading = true;
      selectedFilterStatus = filterStatus;
      listActivities = [];
      _page = 1;
    });

    _getData();
  }

  void onTapFilter() {
    final double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // toggle
                  Container(
                    width: width * 0.1,
                    height: 4,
                    margin: EdgeInsets.only(top: 10, bottom: 30),
                    decoration: BoxDecoration(
                      color: Constants.colorCaption,
                    ),
                  ),
                  // title
                  Text('Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  
                  Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        margin: EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Constants.colorWhite,
                          borderRadius: BorderRadius.circular(10),
                          // boxShadow: const [
                          //   BoxShadow(
                          //       color: Constants.colorPlaceholder,
                          //       offset: Offset(0, 1),
                          //       blurRadius: 1),
                          // ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(0.0),
                          itemCount: listFilterStatus.length,
                          itemBuilder: ((context, index) {
                            dynamic item = listFilterStatus[index];
                            bool isLast = index == (listFilterStatus.length - 1);
                            bool isSelected = item['value'] == selectedFilterStatus['value'];
                            
                            return InkWell(
                              onTap: () {
                                setStateModal(() {
                                  selectedFilterStatus = item;
                                });

                                _getFilterStatusData(item);

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                // decoration: BoxDecoration(
                                //   border: Border(
                                //     bottom: BorderSide(
                                //       width: 0.5,
                                //       color: isLast ? Colors.transparent : Colors.grey.shade300,
                                //     ),
                                //   ),
                                // ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        // padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Text(item['label'],
                                                      style: TextStyle(
                                                          color: isSelected ? Constants.redTheme : Constants.colorTitle,
                                                          fontSize: 15,
                                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                        )
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: listActivities.length,
      //physics: ClampingScrollPhysics(),
      // controller: type == 1 ? _controller : null,
      itemBuilder: (BuildContext context, int index) {
        dynamic item = listActivities[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CardActivities(item),
              (index + 1 == listActivities.length && _nextLoading)
                  ? Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 28,
                      margin: const EdgeInsets.only(top: 2, bottom: 2),
                      child: const CircularProgressIndicator(strokeWidth: 5.0))
                  : const Center(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom + 24.0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
          backgroundColor: Constants.colorWhite,
          centerTitle: false,
          title: Container(
              padding: EdgeInsets.only(left: 20),
              child: Text('Activity', style: Constants.textAppBar3)),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 5),
          width: MediaQuery.of(context).size.width,
          child: LoadingFallback(
            isLoading: _isLoading,
            child: LazyLoadScrollView(
              onEndOfPage: _getNextData,
              isLoading: _nextLoading,
              child: listActivities.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width * 0.35,
                        margin: EdgeInsets.only(left: 20, bottom: 18),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                          border: Border.all(
                            width: 1,
                            color: Constants.redTheme,
                          )
                        ),
                        child: InkWell(
                          onTap: () {
                            onTapFilter();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedFilterStatus['label'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Constants.redTheme,
                                  ),
                                ),
                                Icon(
                                  Icons.expand_more,
                                  color: Constants.redTheme,
                                ),
                              ],
                            )),
                        )
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: paddingBottom),
                          child: _list(),
                        )
                      )
                    ],
                  )
                  : Center(
                      child: Container(
                        width: width / 2,
                        height: width / 2,
                        child: Image.asset(
                            'assets/images/state/empty-state-img.png'),
                      ),
                    ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
