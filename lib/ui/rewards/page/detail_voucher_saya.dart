import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../component/widget/app_notification.dart';

class DetailVoucherSaya extends StatefulWidget {
  dynamic dataVoucher, type;
  DetailVoucherSaya({this.dataVoucher, this.type});
  @override
  State<DetailVoucherSaya> createState() => _DetailVoucherSayaState();
}

class _DetailVoucherSayaState extends State<DetailVoucherSaya> {
  TextEditingController voucherCode = new TextEditingController();
  bool isRedeem = true;
  HttpService http = HttpService();
  dynamic voucherDetail;
  List<dynamic> partnerList = [];
  dynamic profile;
  String namaProfile = "";
  String iplProfile = "";
  bool loading = true;
  GlobalKey _androidScreenShoot = GlobalKey();

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    

    if (widget.dataVoucher['data']['status'] != 3) {
      setState(() {
        isRedeem = true;
      });
    }
    getData();
    getProfile();
  }

  getData() {
    http.post("voucher-detail",
        body: {"id": widget.dataVoucher['data']['id']}).then((res) {
      if (res['success']) {
        setState(() {
          voucherDetail = res['data'];
          partnerList = res['data']['partner'];
          loading = false;
        });
      }
      ("partnerList = $partnerList");
    });
  }

  getProfile() {
    http.post('profile').then((res) async {
      ('res ${res}');
      if (res.toString() != null) {
        if (res['success'] == true) {
          ("profile = ${res['data']}");

          setState(() {
            profile = res['data'];
            namaProfile = res['data']['nama'];
            iplProfile = res['data']['ipl'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        title: const Text(
          'Detail Voucher',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                Center(
                    child: Image.asset('assets/images/loader.gif',
                        height: 100, width: 100)),
              ],
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child:
                            // widget.data['banner_file'] == ''
                            //     ? Center(
                            //         child: Container(
                            //             width: 100.0,
                            //             height: 119,
                            //             margin: EdgeInsets.all(8),
                            //             padding: const EdgeInsets.all(8),
                            //             decoration: BoxDecoration(
                            //               color: Color.fromRGBO(0, 0, 0, 0.2),
                            //               borderRadius:
                            //                   BorderRadius.all(Radius.circular(8)),
                            //               boxShadow: [
                            //                 new BoxShadow(
                            //                     color: Colors.transparent,
                            //                     //offset: new Offset(2.0, 2.0),
                            //                     //blurRadius: 0.5,
                            //                     spreadRadius: 0)
                            //               ],
                            //             ),
                            //             alignment: Alignment.center,
                            //             child: Text('no image',
                            //                 style: TextStyle(color: Colors.black))),
                            //       )
                            //     :
                            CachedNetworkImage(
                          imageUrl: '${widget.dataVoucher['data']['image']}',
                          imageBuilder: (context, imageProvider) {
                            return Stack(
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    )),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.bottomCenter,
                                  decoration: const BoxDecoration(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: []),
                                  ),
                                ),
                              ],
                            );
                          },
                          placeholder: (context, url) =>
                              Image.asset('assets/images/loader.gif'),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 15, left: 20, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.dataVoucher['data']['v_name']}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.watch_later_outlined,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Available until ${widget.dataVoucher['data']['end_date']}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            // Row(
                            //   children: [
                            //     Image.asset(
                            //       'assets/images/icon/broken_card.png',
                            //       width: 16,
                            //       color: Colors.black,
                            //     ),
                            //     SizedBox(
                            //       width: 8,
                            //     ),
                            //     Text(
                            //       // 'Minimun Transaction ${NumberFormat.currency(locale: 'ID').format(promodetail['min_value']).replaceAll(',00', '')}',
                            //       'Minimun Transaction ${widget.dataVoucher['data']['amount']}',
                            //       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            //     )
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 4,
                            // ),
                            widget.dataVoucher['data']['use_at_description'] ==
                                    null
                                ? Container()
                                : Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/icon/ticket_expired.png',
                                        width: 16,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Reedem at ${widget.dataVoucher['data']['use_at_description']}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text(
                              'Deskripsi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text('${widget.dataVoucher['short_description']}'),
                            Text(
                                '${widget.dataVoucher['data']['description']}'),
                            const SizedBox(
                              height: 24,
                            ),
                            if (widget.dataVoucher['data']['online_voucher'])
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kode Voucher',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (widget.dataVoucher['data']
                                                      ['copy_voucher_code'] !=
                                                  null)
                                              ? widget.dataVoucher['data']
                                                      ['copy_voucher_code']
                                                  .toString()
                                              : "-",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        child: const Icon(Icons.copy,
                                            color: Colors.black),
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: widget.dataVoucher['data']
                                                  ['copy_voucher_code']));

                                          flushbarMessage("Copied");
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            if (voucherDetail != null &&
                                voucherDetail["type"] != null &&
                                voucherDetail["type"] == "BARCODE")
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: RepaintBoundary(
                                        key: _androidScreenShoot,
                                        child: QrImage(
                                          data: voucherDetail != null &&
                                                  voucherDetail['v_code'] !=
                                                      null &&
                                                  voucherDetail['v_code'] != ''
                                              ? voucherDetail['v_code']
                                              : '',
                                          version: QrVersions.auto,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          backgroundColor: Colors.white,
                                          errorStateBuilder: (cxt, err) {
                                            return Container(
                                              child: const Center(
                                                child: Text(
                                                  "Uh oh! Something went wrong...",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(
                              height: 15,
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            const Text(
                              'Syarat dan Ketentuan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Html(
                              data:
                                  '${widget.dataVoucher['data']["term_and_condition"]}',
                              //Optional parameters:
                              style: {
                                "html": Style(
                                  fontSize: FontSize.medium,
                                  letterSpacing: 0.5,
                                  wordSpacing: 1.2,
                                  //textAlign: TextAlign.justify,
                                  //margin: EdgeInsets.only(left:-10),
                                ),
                              },
                              onLinkTap: (url, context, map, element) {
                                _launchURL(url);
                              },
                              onImageError: (exception, stackTrace) {},
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            const Text(
                              'Cara Memakai Voucher',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Html(
                              data:
                                  '${widget.dataVoucher['data']["how_to_use"]}',
                              //Optional parameters:
                              style: {
                                "html": Style(
                                  fontSize: FontSize.medium,
                                  letterSpacing: 0.5,
                                  wordSpacing: 1.2,
                                  //textAlign: TextAlign.justify,
                                  //margin: EdgeInsets.only(left:-10),
                                ),
                              },
                              onLinkTap: (url, context, map, element) {
                                _launchURL(url);
                              },
                              onImageError: (exception, stackTrace) {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
                if (isRedeem)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.dataVoucher['type'] == 'ACTIVE'
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Row(
                              children: [
                                Expanded(child: _buttonRedeem()),
                              ],
                            ),
                          )
                        : Container(),
                  )
              ],
            ),
    );
  }

  Widget _buttonRedeem() {
    if (widget.dataVoucher['from_page'] == 'my_rewards') {
      String btnText = "Tukarkan Voucher";
      bool isOnline =
          (widget.dataVoucher['data']['type'] == "ONLINE") ? true : false;
      bool isImage =
          (widget.dataVoucher['data']['type'] == "IMAGE") ? true : false;
      if (isOnline) {
        btnText = "Salin Kode Voucher";
      }
      if (isImage) {
        btnText = "Lihat Voucher";
      }
      return InkWell(
        onTap: () async {
          if (!isOnline && !isImage) {
            final id = widget.dataVoucher['data']['id'];
            final title = widget.dataVoucher['data']['v_name'];
            // final String eventName = "my_reward/redeem";
            // final Map<String, dynamic> eventValues = {
            //   'id': id,
            //   'title': title,
            // };

            return showBottomModal();
          }
          if (isOnline) {
            return await Clipboard.setData(ClipboardData(
                    text: widget.dataVoucher['data']['copy_voucher_code']))
                .then((value) {
              return flushbarMessage("Copied");
            });
          }
          if (isImage) {
            (isImage);
            return Helper(context: context)
                .viewPhoto(
                    url: widget.dataVoucher['data']['image_voucher'],
                    heroTag: "voucher-image")
                .then((value) {
              ("value = $value");
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 40, top: 20),
          width: MediaQuery.of(context).size.width,
          height: 48,
          decoration: BoxDecoration(
              color: const Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(14),
          child: Center(
            child: Text(
              btnText,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          final id = widget.dataVoucher['data']['id'];
          final title = widget.dataVoucher['data']['v_name'];
          // final String eventName = 'loyalti/claim';
          // final Map<String, dynamic> eventValues = {
          //   'id': id,
          //   'title': title,
          // };

          _claimVoucher();
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Color(0xFFED1B24),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: const Text(
            "Klaim Voucher",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget flushbarMessage(String msg) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      message: msg,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.red[300],
      ),
      duration: const Duration(seconds: 3),
    )..show(context);
  }

  _claimVoucher() {
    var body = {"code": widget.dataVoucher['data']['v_code']};
    //("profile = ${profile} ");
    http.post("claim-voucher", body: body).then((res) {
      ("claim = $res");
      if (res["success"]) {
        return showAppNotification(
            context: context,
            title: 'Sukses',
            desc: res["msg"].toString(),
            onSubmit: () {});
      } else {
        showAppNotification(
            context: context,
            title: 'Gagal',
            desc: res["msg"].toString(),
            onSubmit: () {});
      }
    }).catchError((e) {
      ("e = $e");
      showAppNotification(
          context: context,
          title: 'Gagal',
          desc: e.toString(),
          onSubmit: () {});
    });
  }

  showBottomModal() async {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      backgroundColor: Colors.white,
      context: context,
      useRootNavigator: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: TextFormField(
                      controller: voucherCode,
                      decoration: const InputDecoration(
                          hintText: 'Enter Your Voucher Code'),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: voucherCode.text == ''
                        ? () {}
                        : () {
                            _redeemVoucher();
                          },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: const Text(
                        "Pakai Voucher",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 36),
          ],
        ),
      ),
    );
  }

  _redeemVoucher() {
    http.post("redeem-voucher", body: {"code": voucherCode.text.trim()}).then(
        (res) {
      if (res['success']) {
        setState(() {
          isRedeem = false;
        });
      }
      Navigator.of(context).pop();
      // _flushbar(context: context, msg: res['msg']);
      if (res["success"]) {
        showAppNotification(
            context: context,
            title: 'Sukses',
            desc: res["msg"].toString(),
            onSubmit: () {});
      } else {
        showAppNotification(
            context: context,
            title: 'Gagal',
            desc: res["msg"].toString(),
            onSubmit: () {});
      }
    }).catchError((e) {
      showAppNotification(
          context: context,
          title: 'Gagal',
          desc: e.toString(),
          onSubmit: () {});
    });
  }
}
