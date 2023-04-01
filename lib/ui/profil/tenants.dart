import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage(this.data, {Key? key}) : super(key: key);
  final dynamic data;
  @override
  _TenantsPageState createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  String ipl = "";
  String reff = "";
  bool isLoading = true;
  List<dynamic> listKodeKeluarga = [];

  @override
  void initState() {
    _callGetData();
    super.initState();
  }

  void _callGetData() {
    http.post('pic-cluster-referral').then((res) {
      ('res pic-cluster-referral $res');

      setState(() {
        ipl = res['data']['ipl'];
        reff = res['data']['reff'];
      });
    });

    http.post('list-tenants').then((res) {
      ('res list tenants $res');

      if (res['success'] == true) {
        setState(() {
          listKodeKeluarga = res['data'];
        });
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void fetchDeleteItem(dynamic item) {
    dynamic body = {
      'id': item['child_phone'],
    };

    http.post('remove-tenant', body: body).then((res) {
      ('res remove tenant $res');

      if (res['success']) {
        _callGetData();
      }

      Helper(context: context)
          .flushbar(msg: res['msg'], success: res['success']);
    }).catchError((err) {
      ('err remove tenant $err');

      Helper(context: context)
          .flushbar(msg: 'Terjadi kesalahan', success: false);
    });
  }

  void deleteakun(dynamic data) {
    Alert(
      style: const AlertStyle(
        isCloseButton: false,
      ),
      context: context,
      title: "",
      content: Column(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffed1c24),
            radius: 40,
            child: FaIcon(FontAwesomeIcons.userAlt, color: Colors.white),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const Text(
            "Anda yakin ingin menghapus data ini ?",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            fetchDeleteItem(data);
          },
          color: Colors.blue,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: const Color(0xffed1c24),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.data != null) {
          (widget.data);
          Navigator.pushReplacementNamed(context, '/mainMenuPage');
        }
        return Future.value(true);
      },
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text('Kode Pengurus', style: Constants.textAppBar3),
          elevation: 1,
          centerTitle: true,
        ),
        body: LoadingFallback(
          isLoading: isLoading,
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Center(
                      child: Image(
                          image: const AssetImage(
                              'assets/logo/onesmile-final.jpg'),
                          width: MediaQuery.of(context).size.width * 0.50)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const Center(
                      child: Text(
                    'Kode Pengurus:',
                    style: TextStyle(
                      color: Constants.redTheme,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: SelectableText(
                        isLoading
                            ? 'Memuat'
                            : reff != ''
                                ? reff
                                : 'Kamu belum memiliki kode',
                        style: const TextStyle(
                          color: Constants.redTheme,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(width: 8.0),
                      if (reff != '')
                        Center(
                          child: InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: reff));

                              Helper(context: context).flushbar(
                                msg: 'Kode berhasil disalin',
                                success: true,
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  listKodeKeluarga.isNotEmpty
                      ? Container(
                          padding:   EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: const Center(
                            child: Text(
                              'Kode yang sudah dipakai :',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ))
                      : Container(),
                  listKodeKeluarga.isNotEmpty
                      ? ListView.builder(
                          padding:   EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            bottom: MediaQuery.of(context).size.height * 0.01,
                          ),
                          shrinkWrap: true,
                          primary: false,
                          itemCount: listKodeKeluarga.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Card(
                                margin: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 0, 20),
                                      child: const CircleAvatar(
                                        backgroundColor: Color(0xffed1c24),
                                        radius: 20,
                                        child: FaIcon(FontAwesomeIcons.userAlt,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        //leading: FlutterLogo(size: 56.0),
                                        title: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 5, 5, 5),
                                          child: Text(
                                            listKodeKeluarga[i]['mr_code'],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 0),
                                          child: Text(
                                            listKodeKeluarga[i]['child_name'],
                                            style: const TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),

                                        //trailing: Icon(Icons.more_vert),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        deleteakun(listKodeKeluarga[i]);
                                      },
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: const FaIcon(
                                            FontAwesomeIcons.trashAlt,
                                            size: 15.0,
                                            color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          })
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
