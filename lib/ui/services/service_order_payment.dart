import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:appid/api/api_logger.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ServiceOrderPaymentPage extends StatefulWidget {
  const ServiceOrderPaymentPage(this.data, {super.key});

  final dynamic data;

  @override
  State<ServiceOrderPaymentPage> createState() =>
      _ServiceOrderPaymentPageState();
}

class _ServiceOrderPaymentPageState extends State<ServiceOrderPaymentPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  List listBcaIntructions = [
    'Pilih menu Transaksi lainnya > Transfer > Ke Rek BCA',
    'Masukan nomor rekening BCA 4978 7777 22 (an PT Ritel Modern Indonesia)',
    'Periksa informasi yang tertera pada layar. Pastikan total tagihan sudah benar',
    'Jika sudah benar, pilih YA',
    'Apabila sudah berhasil melakukan transfer, klik button “Send Proof of Payment” pada aplikasi',
    'Anda akan diarahkan ke WhatsApp Admin, lalu upload screenshot bukti pembayaran',
  ];
  dynamic paymentOrder = {
    "id": -1,
    "name": "BCA Transfer",
    "bank_name": "BCA",
    "method": "Transfer",
    "bank_rekening": '74385348753',
    "logo": "https://i.pinimg.com/originals/58/5f/e2/585fe239050c065d22d16b1fc41d197e.png",
    "status": 1,
    "code": "BCATRANSFER",
    "qris_image": "https://www.bca.co.id/-/media/images/bisnis/produk/merchant-bca/menu-laporan-qris.png",
    "description": "",
  };
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
    "expired_date": null,
    "id": -1,
  };
  List listOrders = [];
  bool _isLoading = true;
  Timer? _timer;
  int secondRemain = 0;
  dynamic profile;
  dynamic information;

  @override
  void initState() {
    super.initState();
    _getData(isfromStart: false);
    initInstance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initInstance() async {
    dynamic getProfile = await getInstanceJson('profile');
    dynamic getInformation = await getInstanceJson('information');
    setState(() {
      profile = getProfile;
      information = getInformation;
    });
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

  void _getData({bool isfromStart = false}) {
    http.post('order/detail', body: {
      'id': widget.data['id'],
    }).then((res) {
      // log('res order/detail ${res}');

      if (res['success'] == true && res['data'] != null && res['data']['order'] != null && res['data']['order']['id'] is int) {

        isValidDateTime(res['data']['order']['expired_date']);

        DateTime parseEndDate = DateTime.parse(res['data']['order']['expired_date']);
        DateTime now = DateTime.now();
        int remain = parseEndDate.difference(now).inSeconds;

        setState(() {
          objOrder = res['data']['order'];
          listOrders = res['data']['order_detail'];
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

    // payment
    http.post('order/payment').then((res) {
      // log('res order/payment ${res}');

      if (res['success']) {
        listBcaIntructions[1] = 'Masukan nomor rekening ${_printBankAccountNumber(res['data']['bank_rekening'])} (an ${res['data']['name']})';
  
        setState(() {
      //   _isLoading = false;
        paymentOrder = res['data'];
        listBcaIntructions = listBcaIntructions;
      });
      }
    }).catchError((err) {
      log('err order/payment ${err}');

      // setState(() {
      //   _isLoading = false;
      // });
    });
  }

  void onSubmit() {
    return;
    setState(() {
      _isLoading = true;
    });

    dynamic body = {
      
    };

    http.post('order/create', body: body).then((res) {
      // log('res order/create ${res}');

      if (res['success'] == true) {
        showAppNotification(
            context: context,
            title: 'Order Created',
            desc: 'Your order has been created',
            onSubmit: () {});
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

  void onPressIntructions() {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        
        content: Container(
          color: Colors.transparent,
          width: width - 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/icon/close-circle.png'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                decoration: BoxDecoration(
                  color: Constants.colorWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: const Text(
                        'Payment Instruction',
                        style: TextStyle(
                          color: Constants.colorTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listBcaIntructions.length,
                      itemBuilder: (context, index) {
                        return renderItemIntructions(index+1, listBcaIntructions[index]);
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressShowQR() {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        
        content: Container(
          color: Colors.transparent,
          width: width - 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/icon/close-circle.png'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                decoration: BoxDecoration(
                  color: Constants.colorWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 21),
                      child: const Text(
                        'QRIS',
                        style: TextStyle(
                          color: Constants.colorTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 6),
                      child: Text(
                        paymentOrder['name'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Constants.colorText,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        _printBankAccountNumber(paymentOrder['bank_rekening']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Constants.colorText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        // child: RepaintBoundary(
                        //   child: QrImage(
                        //     data: objOrder['invoices_number'],
                        //     version: QrVersions.auto,
                        //     size: width * 0.5,
                        //     backgroundColor: Colors.white,
                        //     errorStateBuilder: (cxt, err) {
                        //       return Container(
                        //         child: const Center(
                        //           child: Text(
                        //             "Uh oh! Something went wrong...",
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        child: Image.network(
                          paymentOrder['qris_image'],
                          width: width * 0.5,
                          height: width * 0.5,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Constants.redTheme,
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            
                          },
                          child: const Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Save QRIS',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderItemIntructions(int no, String caption) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.065,
            // padding: EdgeInsets.only(right: 12),
            child: Text(
              '$no.',
              style: TextStyle(
                fontSize: 12,
                color: Constants.colorText,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              children: [
                Text(
                  caption,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.colorText,
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
  }

  Widget renderPerCaption(String title, String caption) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
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
                  e['information_name'],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
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
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          Column(
            children: services.map((e) {
              int productAmount = e['product_amount'] is int ? e['product_amount'] : e['product_amount'] is String ? int.parse(e['product_amount']) : 0;
              int productDiscount = e['product_discount'] is int ? e['product_discount'] : e['product_discount'] is String ? int.parse(e['product_discount']) : 0;
              int productQuantity = e['product_quantity'] is int ? e['product_quantity'] : e['product_quantity'] is String ? int.parse(e['product_quantity']) : 0;

              productAmount = productAmount * productQuantity;
              productDiscount = productDiscount * productQuantity;

              // log('eeee $e');

              return Container(
                margin: EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            e['product_name'],
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '(Qty: ${productQuantity} ${e['type_quantity']})',
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
                        if (productDiscount > 0) Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
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
            }).toList(),
          )
        ],
      ),
    );
  }

  String _printDuration(int seconds) {
    if (seconds <= 0) return '00:00:00';
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _printBankAccountNumber(String str) {
    String format = 'xxxx xxxx xxxx xxxx';
    if (str == '') return '';
    var mask = format;
    str.split("").forEach((item) => {mask = mask.replaceFirst('x', item)});
    return mask.replaceAll('x', "");
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

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;

    int finalAmount = objOrder['final_amount'] is int ? objOrder['final_amount'] : objOrder['final_amount'] is String ? int.parse(objOrder['final_amount']) : 0;
    
    bool hasExpiredDate = false;
    DateTime parseEndDate;
    String endDateFormat = '';

    if (objOrder['expired_date'] is String && isValidDateTime(objOrder['expired_date'])) {
      if (objOrder['status'] == 0) {
        hasExpiredDate = true;
      }
      parseEndDate = DateTime.parse(objOrder['expired_date']);
      endDateFormat = DateFormat('dd MMM yyyy | HH:mm').format(parseEndDate);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Container(
                    width: width * 0.5,
                    // height: width * 0.1,
                    margin: EdgeInsets.only(bottom: 20),
                    child:
                        Image.asset('assets/images/state/waiting-payment.png'),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('Complete your payment before ',
                        style: TextStyle(
                            color: Constants.colorTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(endDateFormat,
                        style: TextStyle(
                            color: Constants.colorTitle,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                    decoration: BoxDecoration(
                        color: Constants.colorSecondary,
                        borderRadius: BorderRadius.circular(120)),
                    child: Text('Remaining Time ${_printDuration(secondRemain)}',
                        style: TextStyle(
                            color: Constants.colorTitle,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 18),
              // decoration: BoxDecoration(
              //   border: Border(
              //     bottom: BorderSide(
              //       width: 0.5,
              //       color: Colors.grey.shade300,
              //     ),
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Order',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    'No Order: ${objOrder['invoices_number']}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
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
                  // renderPerProblems('Problems', widget.data['selectedInformation']),
                  // renderPerCaption('Notes', widget.data['selectedNote']),
                  renderPerServices(
                      'Services', listOrders),

                  Container(
                    margin: EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format(finalAmount),
                          style: TextStyle(
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
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
                    margin: EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * 0.15,
                          height: width * 0.15,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                width * 0.15,
                              ),
                              border: Border.all(
                                width: 1,
                                color: Constants.colorCaption,
                              )),
                          child: Image.network(paymentOrder['logo']),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  paymentOrder['bank_name'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Constants.colorTitle),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  paymentOrder['name'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Constants.colorTitle),
                                ),
                              ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: Text(
                                      _printBankAccountNumber(paymentOrder['bank_rekening']),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Constants.colorTitle),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: paymentOrder['bank_rekening']),
                                      );

                                      Helper(context: context).flushbar(
                                        msg: 'Berhasil disalin',
                                        success: true,
                                      );
                                    },
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: Constants.redTheme,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Image.asset(
                                          'assets/images/icon/copy.png'),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  onPressShowQR();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(120),
                                      border: Border.all(
                                        width: 1,
                                        color: Constants.redTheme,
                                      )),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        padding: EdgeInsets.all(4),
                                        child: Image.asset(
                                            'assets/images/icon/primary-qr.png'),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        child: Text(
                                          'Show QR',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Constants.redTheme),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // log('profile $profile');

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _key,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            automaticallyImplyLeading: true,
            backgroundColor: Constants.colorWhite,
            centerTitle: false,
            title: Text('Payment', style: Constants.textAppBar3),
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                size: 36,
                color: Constants.colorTitle,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => MainMenuPage(
                      indexTab: 0,
                    ),
                  ),
                );
              },
            ),
          ),
          body: Container(
            padding: const EdgeInsets.only(top: 5),
            width: width,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Constants.redTheme,
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigator.pushNamed(context, '/serviceOrderResultPage');
                          String phone_send_proof = information != null && information['phone_send_proof'] is String ? information['phone_send_proof'] : '';
                          String textMessage = 'Halo HomeRun.\nsaya sudah pesan dengan nomor Order ${objOrder['invoices_number']}';
                          if (phone_send_proof == '') {
                            return;
                          }
                          String url = 'https://wa.me/$phone_send_proof?text=${Uri.encodeComponent(textMessage)}';
                          // log('url $url');
                          Helper(context: context).launchURL(url);

                          // logger
                          ApiLogger().fetchLogger(
                            page: 'send proof payment',
                            value: jsonEncode({
                              'id': objOrder['id'],
                              'title': objOrder['invoices_number'],
                            })
                          );
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Send Proof of Payment',
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
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onPressIntructions();
                        },
                        child: const Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Payment Instruction',
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
          )),
    );
  }
}
