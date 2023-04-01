import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:appid/api/api_logger.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class ServiceOrderConfirmationPage extends StatefulWidget {
  const ServiceOrderConfirmationPage(this.data, {super.key});

  final dynamic data;

  @override
  State<ServiceOrderConfirmationPage> createState() => _ServiceOrderConfirmationPageState();
}

class _ServiceOrderConfirmationPageState extends State<ServiceOrderConfirmationPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  List _listInbox = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData(isfromStart: false);
  }

  void _getData({bool isfromStart = false}) {
    // http.post('order/detail', body: {
    //   'id': widget.data['id'],
    // }).then((res) {
    //   log('res order/detail ${res}');

    //   if (res['success'] == true) {
        
    //   }

    //   setState(() {
    //     _isLoading = false;
    //   });
    // }).catchError((err) {
    //   log('err order/detail ${err}');

      setState(() {
        _isLoading = false;
      });
    // });
  }

  void onSubmit() {
    List servicesInformationId = [];
    widget.data['selectedInformation'].forEach((e) {
      servicesInformationId.add(e['id']);
    });
    List servicesCategory = [];
    widget.data['selectedCategory'].forEach((e) {
      servicesCategory.add({
        'id': e['id'],
        'quantity': e['quantity'],
      });
    });
    
    setState(() {
      _isLoading = true;
    });

    dynamic body = {
      "address_id": widget.data['selectedAddress']['id'],
      "services_id": widget.data['id'],
      "services_information_id": servicesInformationId,
      "services_category": servicesCategory,
      "services_note": widget.data['selectedNote'],
      "date_info": widget.data['dateInfo'],
    };

    http.post('order/create', body: body).then((res) {
      // log('res order/create ${res}');

      if (res['success'] == true && res['data'] != null && res['data']['order'] != null && res['data']['order']['id'] is int) {
        showAppNotification(
          context: context,
          title: 'Order Created',
          desc: 'Your order has been created',
          onSubmit: () {
            dynamic args = { 'id': res['data']['order']['id'], };
            Navigator.pushNamed(context, '/serviceOrderPaymentPage', arguments: args);
          }
        );

        Timer(
          const Duration(seconds: 3),
          () {
            dynamic args = { 'id': res['data']['order']['id'], };
            Navigator.pushNamed(context, '/serviceOrderPaymentPage', arguments: args);
          }
        );
      } else {
        Helper(context: context).flushbar(
          msg: res['msg'],
          success: false,
        );
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err order/create ${err}');

      Helper(context: context).flushbar(
        msg: 'Terjadi kesalahan',
        success: false,
      );

      setState(() {
        _isLoading = false;
      });
    });
  }

  void onPressConfirm() {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        content: Container(
          width: width - 40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure want to order?',
                style: TextStyle(
                  color: Constants.colorTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You will be asked to verify your order',
                style: TextStyle(
                  color: Constants.colorCaption,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onSubmit();

                          // logger
                          ApiLogger().fetchLogger(
                            page: 'order '.toString() + widget.data['services_name'],
                            value: jsonEncode({
                              'id': widget.data['id'],
                              'title': 'confirm order',
                            })
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Constants.redTheme,
                        ),
                        child: const Text(
                          'Order',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                                width: 1.0, color: Constants.redTheme),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Constants.redTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
          SizedBox(height: 14,),
          Text(caption, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
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
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((e) {
              return Container(
                margin: EdgeInsets.only(top: 14),
                child: Text(e['information_name'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget renderPerServices(String title, List services) {
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
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),

          Column(
            children: services.map((e) {
              // log('eee $e');
              int productAmount = e['final_amount'] is int ? e['final_amount'] : e['final_amount'] is String ? int.parse(e['final_amount']) : 0;
              int productDiscount = e['amount'] is int ? e['amount'] : e['amount'] is String ? int.parse(e['amount']) : 0;
              int productQuantity = e['quantity'] is int ? e['quantity'] : e['quantity'] is String ? int.parse(e['quantity']) : 0;

              productDiscount = productDiscount * productQuantity;
              productAmount = productAmount * productQuantity;

              return Container(
                margin: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(e['name'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
                          Text('(Qty: ${productQuantity}${e['type_quantity']})', style: TextStyle(fontSize: 12, color: Constants.colorCaption, fontWeight: FontWeight.w400),),
                        ],
                      ),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (productDiscount > 0) Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0
                          ).format(productDiscount),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Constants.colorCaption, decoration: TextDecoration.lineThrough),),
                        Text(NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0
                          ).format(productAmount),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
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
                        blurRadius: 1
                      ),
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
                              child: Image.network(widget.data['services_image']),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.data['services_name'], style: TextStyle(
                                      color: Constants.colorTitle,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                    )),
                                  ]
                                ),
                              ),
                            ),
                            Text('-', style: TextStyle(
                                      color: Constants.colorCaption,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                    ))
                          ],
                        ),
                      ),

                      renderPerCaption('Address', widget.data['selectedAddress']['address']),
                      renderPerCaption('Service Date & Time', '${widget.data['dateInfo']}'),
                      if (widget.data['selectedInformation'].isNotEmpty) renderPerProblems('Problems', widget.data['selectedInformation']),
                      renderPerCaption('Notes', widget.data['selectedNote']),
                      renderPerServices('Services', widget.data['selectedCategory']),
                      
                      Container(
                        margin: EdgeInsets.only(top: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
                            ),
                            Text(NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0
                            ).format(widget.data['totalPrice']),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Constants.redTheme),),
                          ],
                        ),
                      )
                    ],
                  ),
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
        centerTitle: false,
        title: Text('Confirmation Order', style: Constants.textAppBar3),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Constants.redTheme,
            borderRadius: BorderRadius.circular(120),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onPressConfirm();
              },
              child: const Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Confirm Order',
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
    )
    );
  }
}
