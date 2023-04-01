import 'package:flutter/material.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/ui/rewards/all/card_all_beli_front.dart';

class KlaimPage extends StatefulWidget {
  const KlaimPage({super.key});

  @override
  State<KlaimPage> createState() => _KlaimPageState();
}

class _KlaimPageState extends State<KlaimPage> {
  dynamic dataVoucher;
  dynamic dataKategori;
  HttpService http = HttpService();
  bool isEnd = false, isReady = false;

  _getVoucherCategory() async {
    await http.post('voucher-category', body: {'status': 2}).then((res) {
      // ("voucherCategory = $res");

      if (res['success']) {
        setState(() {
          dataKategori = res['data'];
          getDataVoucher();
        });
      }
    });
  }

  getDataVoucher() {
    if (dataKategori != null) {
      for (var i = 0; i < dataKategori.length; i++) {
        voucher(dataKategori[i]['id']);
      }
    }
  }

  voucher(id) {
    http.post('voucher-list', body: {
      "sf": 0,
      "limit": 10,
      "type": null,
      "category": id == 0 ? null : id,
    }).then((res) {
      // ("res = $res");

      if (res['success']) {
        setState(() {
          dataVoucher = res['data'];

          if (res['data'].length == 0) {
            isEnd = true;
          }
        });
      }
      setState(() {
        isReady = true;
      });
    }).catchError((e) {
      setState(() {
        dataVoucher = [];
        isReady = true;
      });
    });
  }

  Widget listCard() {
    return SizedBox(
      height: 170,
      // margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            children: [
              for (var i = 0; i < dataVoucher.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CardBeliVoucherFront(dataVoucher[i]),
                )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getVoucherCategory();
    getDataVoucher();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            'Voucher',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          )),
      backgroundColor: Colors.white,
      body: dataKategori == null
          ? Center(child: Image.asset('assets/images/loader.gif'))
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dataKategori.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                dataKategori[index] == null ||
                                        dataKategori[index]['length'] == 0
                                    ? Container()
                                    : Text(
                                        dataKategori[index]['name'],
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800),
                                      ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/viewAllVoucherKlaim',
                                        arguments: dataKategori[index]);
                                  },
                                  child: Text(
                                    (dataKategori[index] == null ||
                                            dataKategori[index]['length'] == 0)
                                        ? ''
                                        : 'Lihat Semua',
                                    style: const TextStyle(
                                        color: Color(0xffee6055),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800),
                                  ),
                                )
                              ],
                            ),
                            dataKategori[index] == null ||
                                    dataKategori[index]['length'] == 0
                                ? Container()
                                : const SizedBox(
                                    height: 10,
                                  ),
                            dataKategori[index] == null ||
                                    dataKategori[index]['length'] == 0
                                ? Container()
                                : CardBeliVoucherFront(
                                    dataKategori[index]['id']),
                            dataKategori[index] == null ||
                                    dataKategori[index]['length'] == 0
                                ? Container()
                                : const SizedBox(
                                    height: 24,
                                  ),
                          ],
                        );
                      }),
                ),
              ],
            ),
    );
  }
}
