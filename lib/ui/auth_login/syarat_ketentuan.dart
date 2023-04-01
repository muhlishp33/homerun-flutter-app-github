import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';

class SyaratKetentuanPage extends StatefulWidget {
  const SyaratKetentuanPage({super.key});

  @override
  SyaratKetentuanState createState() => SyaratKetentuanState();
}

class SyaratKetentuanState extends State<SyaratKetentuanPage> {
  List syaratKetentuan = [];
  bool isProses = true;

  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    var result = await http.post('static/page', body: {"type": "TERM"});

    // log('result $result');

    if (result['success'] &&
        result['data'] is List &&
        result['data'].length > 0) {
      setState(() {
        syaratKetentuan.add(result['data'][0]);
      });
    }

    var resultPengguna =
        await http.post('static/page', body: {"type": "POLICY"});

    // log('resultPengguna $resultPengguna');

    if (resultPengguna['success']) {
      setState(() {
        syaratKetentuan.add(resultPengguna['data'][0]);
      });
    }

    setState(() {
      isProses = false;
    });
  }

  void flushbarGagal(BuildContext context, msg) {
    // Flushbar(
    //   flushbarPosition: FlushbarPosition.TOP,
    //   margin: EdgeInsets.all(8),
    //   borderRadius: 8,
    //   message: msg,
    //   icon: Icon(
    //     Icons.info_outline,
    //     size: 28.0,
    //     color: Colors.red[300],
    //   ),
    //   duration: Duration(seconds: 3),
    // )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        // leading: new IconButton(
        //   icon: new Icon(Icons.arrow_back, color: Colors.black),
        //   tooltip: "Kembali",
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text('Term and Conditions', style: Constants.textAppBar3),
      ),
      body: _buildWidgetListDataAndroid(),
    );
  }

  Widget _buildWidgetListDataAndroid() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          if (!isProses)
            Expanded(
                child: ListView(
              children: syaratKetentuan
                  .map(
                    (data) => Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: ExpansionTile(
                        expandedCrossAxisAlignment: CrossAxisAlignment.center,
                        onExpansionChanged: (value) {
                          // ('value');
                        },
                        expandedAlignment: Alignment.center,
                        title: Text(
                          data['name'] ?? '',
                          style: const TextStyle(color: Constants.colorTitle, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        iconColor: Constants.colorTitle,
                        collapsedIconColor: Constants.colorTitle,
                        children: [
                          SingleChildScrollView(
                              child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Html(
                                data: data['description'] ?? '',
                                // linkStyle: {
                                //   "html": Style(
                                //       padding:
                                //           EdgeInsets.only(left: 10, right: 10)),
                                // },
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )),
        ],
      ),
    );
  }
}
