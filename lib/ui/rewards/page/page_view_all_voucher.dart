import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/ui/rewards/all/card_all_beli.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';

// ignore: must_be_immutable
class ViewAllKlaimVoucher extends StatefulWidget {
  dynamic dataKategori;

  ViewAllKlaimVoucher(this.dataKategori, {super.key});

  @override
  State<ViewAllKlaimVoucher> createState() => _ViewAllKlaimVoucherState();
}

class _ViewAllKlaimVoucherState extends State<ViewAllKlaimVoucher> {
  List listdata = [];
  bool loading = true;
  HttpService http = HttpService();
  bool isEnd = false, isReady = false;
  int startIndex = 0;

  _getVoucherList() {
    http.post('voucher-list', body: {
      "sf": startIndex,
      "limit": 10,
      "type": null,
      "category":
          widget.dataKategori['id'] == 0 ? null : widget.dataKategori['id'],
    }).then((res) {
      // ("res = $res");

      if (res['success']) {
        setState(() {
          for (int i = 0; i < res['data'].length; i++) {
            listdata.add(res['data'][i]);
          }

          loading = false;
          startIndex = startIndex + res['data'].length as int;
          if (res['success'] == false) {
            isEnd = true;
            loading = false;
            listdata = [];
          }
        });
      }
      setState(() {
        isReady = true;
        loading = false;
      });
    }).catchError((e) {
      setState(() {
        loading = false;
        listdata = [];

        isReady = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getVoucherList();
  }

  @override
  Widget build(BuildContext context) {
    ('ini data $listdata');
    return Scaffold(
      appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: const Color(0xffe5e5e5),
              )),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(
            widget.dataKategori['name'],
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          )),
      backgroundColor: Colors.white,
      body: loading == true
          ? Center(child: Image.asset('assets/images/loader.gif'))
          : listdata == null
              ? Center(child: EmptyStateLoyalty('Voucher belum tersedia'))
              : LazyLoadScrollView(
                  onEndOfPage: () {
                    _getVoucherList();
                  },
                  child: ListView(children: [
                    listdata.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: EmptyStateLoyalty(
                                      'Voucher belum tersedia')),
                            ],
                          )
                        : CardAllBeli(listdata)
                  ]),
                ),
    );
  }
}
