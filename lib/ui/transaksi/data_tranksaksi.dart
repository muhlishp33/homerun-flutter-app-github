import 'dart:async';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:flutter/src/rendering/box.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
//import 'package:thisable/component/Constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DataTransaksiPage extends StatefulWidget {
  const DataTransaksiPage({super.key});

  @override
  State<DataTransaksiPage> createState() => _DataTransaksiPageState();
}

class _DataTransaksiPageState extends State<DataTransaksiPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  bool statusClose = false;
  bool isReadyIpl = false;
  bool isReadyMarket = false;
  dynamic datahis;
  dynamic datap;
  List<dynamic> _dataIPL = [];
  List<dynamic> _dataMarket = [];
  String searchText = "";
  String photo = '';
  String nama = '';
  int merch = 1;
  bool isIpl = true;

  @override
  void initState() {
    super.initState();
    _getAllData();
  }

  void _getAllData() async {
    _getDataIPL();
    _getDatamarket();
  }

  void _getDataIPL() async {
    http.post('ipl-transaction', body: {}).then((res) {
      if (res['success']) {
        if (mounted) {
          setState(() {
            _dataIPL = res['msg'];
          });
        }
      }
      if (mounted) {
        setState(() {
          isReadyIpl = true;
        });
      }
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          isReadyIpl = true;
        });
      }
    });
  }

  void _getDatamarket() async {
    http.post('market-transaction-finish', body: {"sf": 0, "search": ""}).then(
        (res) {
      if (res['success']) {
        if (mounted) {
          setState(() {
            _dataMarket = res['msg'];
          });
        }
      }
      if (mounted) {
        setState(() {
          isReadyMarket = true;
        });
      }
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          isReadyMarket = true;
        });
      }
    });
  }

  void close() {
    var duration = const Duration(seconds: 2);
    Timer(duration, () {
      statusClose = false;
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _getAllData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var fontFamily = 'Poppins';
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          // leading: new IconButton(
          //   icon: new Icon(Icons.arrow_back, color: Colors.black),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // centerTitle: true,
          title: Text('Transactions', style: Constants.textAppBar3),
          elevation: 1,
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        isIpl = false;
                                      });
                                    }
                                    // log("isIpl = $isIpl");
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      color: !isIpl
                                          ? const Color(0xFFFE0000)
                                          : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey.shade200,
                                            offset: const Offset(2.0, 2.0),
                                            blurRadius: 0,
                                            spreadRadius: 0)
                                      ],
                                    ),
                                    child: Center(
                                      child: Text("Market",
                                          style: TextStyle(
                                            color: isIpl
                                                ? const Color(0xFF464646)
                                                : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (!isIpl) {
                                      if (mounted) {
                                        setState(() {
                                          isIpl = true;
                                        });
                                      }
                                    }
                                    // log("isIpl = $isIpl");
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                      color: isIpl
                                          ? const Color(0xFFFE0000)
                                          : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.blueGrey.shade200,
                                            offset: const Offset(2.0, 2.0),
                                            blurRadius: 0,
                                            spreadRadius: 0)
                                      ],
                                    ),
                                    child: Center(
                                      child: Text("IPL",
                                          style: TextStyle(
                                            color: !isIpl
                                                ? const Color(0xFF464646)
                                                : Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // _loadIpl(context, isReadyIpl, _dataIPL),
                    isIpl
                        ? _loadIpl(context, isReadyIpl, _dataIPL)
                        : _loadMarket(
                            context, isReadyMarket, _dataMarket, searchText),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

Widget _loadIpl(BuildContext context, isReadyIpl, dataIPL) {
  if (!isReadyIpl) {
    return _isLoading(context);
  }
  if (dataIPL.length > 0) {
    return _iplList(context, dataIPL);
  }
  return _noData(context);
}

Widget _loadMarket(
    BuildContext context, isReadyMarket, dataMarket, searchText) {
  if (!isReadyMarket) {
    return _isLoading(context);
  }
  if (dataMarket.length > 0) {
    return _marketList(context, dataMarket, searchText);
  }
  return _noData(context);
}

Widget _marketList(BuildContext context, dataMarket, searchText) {
  // return Container(
  //   height: MediaQuery.of(context).size.height * 0.75,
  //   child: Center(child: Text('Market List')),
  // );
  var fontFamily = 'Poppins';
  // log(dataMarket[0].toString());
  return Column(
    children: [
      for (var i = 0; i < dataMarket.length; i++)
        Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
            // Container(
            //     padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            //     alignment: Alignment.bottomLeft,
            //     child: Column(
            //       children: [
            //         Text(
            //           _dataMarket[i]['date'],
            //           style: TextStyle(
            //               color: Color(0xFF040404),
            //               fontSize: 20,
            //               fontWeight: FontWeight.bold,
            //               fontFamily: fontFamily),
            //         ),
            //       ],
            //     )),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: GestureDetector(
                onTap: () {
                  // log(i.toString());
                  dynamic data = {
                    "isIpl": false,
                    "data": dataMarket[i],
                  };
                  Navigator.pushNamed(context, '/detailTransactionPage',
                      arguments: data);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white10, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: Colors.grey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Nama",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Status",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dataMarket[i]['namaproduk'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dataMarket[i]['statusnm'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kuantitas",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Tanggal Pembayaran",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${dataMarket[i]['jumlahproduk'].toString()} Barang',
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dataMarket[i]['date2'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        // width: MediaQuery.of(context).size.width - 0.1,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: Color(0xFFF7DEE1),
                          // color: Color(0xFFF2F1F6),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Pembayaran",
                                    style: TextStyle(
                                        color: const Color(0xFF474544),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp ',
                                            decimalDigits: 0)
                                        .format(int.parse(
                                            dataMarket[i]['total_bayar'])),
                                    style: TextStyle(
                                        color: const Color(0xFF474544),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    ],
  );
}

Widget _noData(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.75,
    child: const Center(child: Text('Belum ada data')),
  );
}

Widget _isLoading(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.75,
    child: const Center(child: Text('Memuat ...')),
  );
}

Widget _iplList(BuildContext context, dataIPL) {
  var fontFamily = 'Poppins';
  return Column(
    children: [
      for (var i = 0; i < dataIPL.length; i++)
        Column(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                alignment: Alignment.bottomLeft,
                child: Column(
                  children: [
                    Text(
                      dataIPL[i]['term'],
                      style: TextStyle(
                          color: const Color(0xFF040404),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: GestureDetector(
                onTap: () {
                  // log(i.toString());
                  dynamic data = {
                    "isIpl": true,
                    "data": dataIPL[i],
                  };
                  Navigator.pushNamed(context, '/detailTransactionPage',
                      arguments: data);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white10, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: Colors.grey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Term",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Caption",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dataIPL[i]['term'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dataIPL[i]['judul'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Payment Date",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Payment Method",
                                    style: TextStyle(
                                        color: const Color(0xFF464646),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dataIPL[i]['tanggal_bayar'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dataIPL[i]['keterangan_bayar'],
                                    style: TextStyle(
                                        color: const Color(0xFF707070),
                                        fontSize: 12,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        // width: MediaQuery.of(context).size.width - 0.1,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: Color(0xFFF7DEE1),
                          // color: Color(0xFFF2F1F6),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Payment",
                                    style: TextStyle(
                                        color: const Color(0xFF474544),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dataIPL[i]['total_tagihan'],
                                    style: TextStyle(
                                        color: const Color(0xFF474544),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    ],
  );
}
