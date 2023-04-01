import 'dart:async';
import 'dart:developer';

import 'package:appid/component/widget/index.dart';
import 'package:appid/component/widget/rating_bar.dart';
import 'package:appid/helper/color.dart';
import 'package:appid/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class ServiceOrderDetailPage extends StatefulWidget {
  const ServiceOrderDetailPage(this.data, {super.key});

  final dynamic data;

  @override
  State<ServiceOrderDetailPage> createState() => _ServiceOrderDetailPageState();
}

class _ServiceOrderDetailPageState extends State<ServiceOrderDetailPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  dynamic objOrder = {
    "invoices_number": "",
    "amount": 0,
    "order_type": "",
    "discount": 0,
    "final_amount": 0,
    "status": -1,
    "customer_id": -1,
    "fullname": "",
    "address": "",
    "phone": 0,
    "customer_note": "",
    "longitude": null,
    "latitude": null,
    "address_name": null,
    "expired_date": "",
    "id": -1,
    "date_info": ""
  };
  List listOrders = [];
  List listOrderInformation = [];
  List listOrderReview = [];
  bool _isLoading = true;
  Timer? _timer;
  int secondRemain = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // const oneSec = Duration(seconds: 1);
    // _timer = Timer.periodic(
    //   oneSec,
    //   (Timer timer) {
    //     if (secondRemain == 0) {
    //       setState(() {
    //         timer.cancel();
    //       });
    //     } else {
    //       setState(() {
    //         secondRemain--;
    //       });
    //     }
    //   },
    // );
  }

  void _getData() {
    http.post('order/detail', body: {
      'id': widget.data['id'],
    }).then((res) {
      // log('res order/detail ${res}');

      if (res['success'] == true &&
          res['data'] != null &&
          res['data']['order'] != null &&
          res['data']['order']['id'] is int
      ) {
          
        bool validExpiredDate = isValidDateTime(res['data']['order']['expired_date']);

        DateTime parseEndDate = validExpiredDate ?
          DateTime.parse(res['data']['order']['expired_date'])
        :
          DateTime.now();

        DateTime now = DateTime.now();
        int remain = parseEndDate.difference(now).inSeconds;

        setState(() {
          objOrder = res['data']['order'];
          listOrders = res['data']['order_detail'];
          listOrderInformation = res['data']['order_information'];
          listOrderReview = res['data']['order_review'];
          secondRemain = remain;
        });

        startTimer();
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err order/detail ${err}');

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

  void onSubmitPayment() {
    dynamic args = {
      "id": objOrder['id'],
    };
    Navigator.pushNamed(context, '/serviceOrderPaymentPage', arguments: args);
  }

  void onSubmitReview() {
    dynamic args = {
      "id": objOrder['id'],
    };
    Navigator.pushNamed(context, '/serviceOrderReviewPage', arguments: args);
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listOrders.length,
            itemBuilder: ((context, index) {
              dynamic e = listOrders[index];

              String productName = e['product_name'] is String ? e['product_name'] : '';

              int productAmount = e['product_amount'] is int
                  ? e['product_amount']
                  : e['product_amount'] is String
                      ? int.parse(e['product_amount'])
                      : 0;
              int productDiscount = e['product_discount'] is int
                  ? e['product_discount']
                  : e['product_discount'] is String
                      ? int.parse(e['product_discount'])
                      : 0;
              int productQuantity = e['product_quantity'] is int
                  ? e['product_quantity']
                  : e['product_quantity'] is String
                      ? int.parse(e['product_quantity'])
                      : 0;

              productAmount = productAmount * productQuantity;
              productQuantity = productQuantity * productQuantity;

              return Container(
                margin: EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            productName,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '(Qty: ${productQuantity}${e['type_quantity']})',
                            style: TextStyle(
                                fontSize: 12,
                                color: Constants.colorCaption,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (productDiscount > 0)
                          Text(
                            NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format(productDiscount),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Constants.colorCaption,
                                decoration: TextDecoration.lineThrough),
                          ),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format(productAmount),
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              );
            })
          ),

          // Column(
          //   children: listOrders.map((e) {
              


          //   }).toList(),
          // )
        ],
      ),
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;
    int finalAmount = objOrder['final_amount'] is int
        ? objOrder['final_amount']
        : objOrder['final_amount'] is String
            ? int.parse(objOrder['final_amount'])
            : 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Constants.colorWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Constants.colorPlaceholder,
                      offset: Offset(0, 1),
                      blurRadius: 1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: width * 0.1,
                          height: width * 0.1,
                          child: Image.asset(objOrder['order_type'] == 'GAS'
                              ? 'assets/images/activities/gas-circle.png'
                              : objOrder['order_type'] == 'AC'
                                  ? 'assets/images/activities/ac-services-circle.png'
                                  : objOrder['order_type'] == 'GALON'
                                      ? 'assets/images/activities/water-gallon-circle.png'
                                      : 'assets/images/activities/cleaning-services-circle.png'),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(objOrder['order_name'] ?? 'Unavailable',
                                      style: TextStyle(
                                          color: Constants.colorTitle,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: colorFromHex(
                                            objOrder['status_bg_color'] ??
                                                '#EEE6FD'),
                                        borderRadius: BorderRadius.circular(120)),
                                    child: Text(
                                      objOrder['status_label'] ?? 'not available',
                                      style: TextStyle(
                                          color: colorFromHex(
                                              objOrder['status_color'] ??
                                                  '#000000'),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                        Expanded(
                          child: Text(objOrder['invoices_number'] ?? '',
                              style: TextStyle(
                                  color: Constants.colorCaption,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  ),
                  renderPerCaption('Address', objOrder['address'] ?? ''),
                  renderPerCaption(
                      'Service Date & Time', '${objOrder['date_info'] ?? ''}'),
                  if (listOrderInformation.isNotEmpty)
                    renderPerProblems('Problems', listOrderInformation),
                  renderPerCaption('Notes', objOrder['customer_note'] ?? ''),
                  if (listOrders.isNotEmpty)
                    renderPerServices('Services'),

                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format(finalAmount),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Constants.redTheme),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // listOrderReview
            if (listOrderReview.isNotEmpty) Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
              margin: EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Constants.colorWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Constants.colorPlaceholder,
                    offset: Offset(0, 1),
                    blurRadius: 1
                  ),
                ],
              ),
              child: Column(
                children: listOrderReview.map((e) {
                  DateTime parseEndDate;
                  String endDateFormat = '';

                  if (isValidDateTime(e['created_date'])) {
                    parseEndDate = DateTime.parse(e['created_date']);
                    endDateFormat = DateFormat('dd MMM yyyy | HH:mm').format(parseEndDate);
                  }

                  return Container(
                    margin: EdgeInsets.only(top: 12),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: width * 0.04,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     width: 0.5
                              //   )
                              // ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                scrollDirection: Axis.horizontal,
                                itemCount: e['star'],
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: width * 0.04,
                                )
                              ),
                            ),
                            Text(endDateFormat, style: TextStyle(fontSize: 10, color: Constants.colorCaption),),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(e['fullname']??'', style: TextStyle(fontSize: 12),),
                        ),
                        Text('By: ${e['review']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // log('listOrderInformation $listOrderInformation');
    // log('listOrders $listOrders');
    // log('objOrder $objOrder');

    return Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          backgroundColor: Constants.colorWhite,
          centerTitle: false,
          title: Text('Order Detail', style: Constants.textAppBar3),
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
        bottomNavigationBar: BottomAppBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (objOrder['status'] == 0)
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
                          onSubmitPayment();
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Continue Payment',
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
              if (objOrder['status'] == 3) Container(
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
                        onSubmitReview();
                      },
                      child: const Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Review',
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
        ));
  }
}
