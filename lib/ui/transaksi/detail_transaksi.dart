import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';

class DetailTransactionPage extends StatefulWidget {
  const DetailTransactionPage(this.data, {super.key});
  final dynamic data;

  @override
  State<DetailTransactionPage> createState() => _DetailTransactionPageState();
}

class _DetailTransactionPageState extends State<DetailTransactionPage> {
  String tagihanAir = "Rp 0";
  String tagihanIpl = "Rp 0";
  String dendaAir = "Rp 0";
  String dendaIpl = "Rp 0";
  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 1,
      title: Text('Detail Transaksi', style: Constants.textAppBar3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: widget.data['isIpl']
          ? _buildWidgetListDataIplAndroid()
          : _buildWidgetListDataMarketAndroid(),
    );
  }

  Widget _buildWidgetListDataMarketAndroid() {
    var fontFamily = 'Poppins';
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      widget.data['data']['statusnm'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      widget.data['data']['date2'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Transaction Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              widget.data['data']['inv'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
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
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Contact Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['namapembeli'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['phone'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['addr'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Transaction Summary",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        for (var b = 0;
                            b < widget.data['data']['produks'].length;
                            b++)
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: [
                                          Text(
                                              "Toko ${widget.data['data']['produks'][b]['merchant_nm']}"),
                                        ],
                                      ),
                                    ),
                                    for (var c = 0;
                                        c <
                                            widget
                                                .data['data']['produks'][b]
                                                    ['produk']
                                                .length;
                                        c++)
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    widget.data['data']
                                                                    ['produks']
                                                                [b]['produk'][c]
                                                            ['nama'] +
                                                        " ( ${widget.data['data']['produks'][b]['produk'][c]['jumlah']} Barang ) ",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: fontFamily,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Text(
                                                      "Rp ${widget.data['data']['produks'][b]['produk'][c]['harga']}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: fontFamily,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Payment Detail",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total Payment",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp ',
                                                  decimalDigits: 0)
                                              .format(int.parse(
                                                  widget.data['data']
                                                      ['total_bayar'])),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: fontFamily,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.data['data']['namabayar'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        NumberFormat.currency(
                                                locale: 'id',
                                                symbol: 'Rp ',
                                                decimalDigits: 0)
                                            .format(int.parse(widget
                                                .data['data']['total_bayar'])),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              color: const Color(0xFFFAFAFA),
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed('/customerCarePage');
                                    },
                                    child: Center(
                                      child: Text("Call Resident Care",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: fontFamily,
                                          )),
                                    )),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildWidgetListDataIplAndroid() {
    for (var i = 0; i < widget.data['data']['detail'].length; i++) {
      if (widget.data['data']['detail'][i]['nama'] == 'IPL') {
        tagihanIpl = widget.data['data']['detail'][i]['value'];
      }
      if (widget.data['data']['detail'][i]['nama'] == 'Denda IPL') {
        dendaIpl = widget.data['data']['detail'][i]['value'];
      }
      if (widget.data['data']['detail'][i]['nama'] == 'Air') {
        tagihanAir = widget.data['data']['detail'][i]['value'];
      }
      if (widget.data['data']['detail'][i]['nama'] == 'Denda Air') {
        dendaAir = widget.data['data']['detail'][i]['value'];
      }
    }
    var fontFamily = 'Poppins';
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      widget.data['data']['status_ket'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      widget.data['data']['tanggal_bayar'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Transaction Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              widget.data['data']['transaction_number'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
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
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Contact Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['contact_name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['contact_phone'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.data['data']['contact_address'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Transaction Summary",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Tagihan Air",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        tagihanAir,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Tagihan IPL",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          tagihanIpl,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: fontFamily,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Payment Detail",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Denda Air",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          dendaAir,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Denda IPL",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          dendaIpl,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF2F1F6)),
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total Payment",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          widget.data['data']['total_tagihan'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          alignment: Alignment.topLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.black38, width: 0.5),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.data['data']['keterangan_bayar'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        widget.data['data']['total_tagihan'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              color: const Color(0xFFFAFAFA),
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed('/customerCarePage');
                                    },
                                    child: Center(
                                      child: Text("Call Resident Care",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: fontFamily,
                                          )),
                                    )),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
          ],
        )),
      ],
    );
  }
}
