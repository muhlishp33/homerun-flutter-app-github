import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../component/widget/app_notification.dart';

class DetailVoucherSearch extends StatefulWidget {
  dynamic dataVoucher, type;
  DetailVoucherSearch({this.dataVoucher, this.type});
  @override
  State<DetailVoucherSearch> createState() => _DetailVoucherSearchState();
}

class _DetailVoucherSearchState extends State<DetailVoucherSearch> {
  dynamic profile;
  String namaProfile = "";
  String iplProfile = "";
  HttpService http = HttpService();
  TextEditingController voucherCode = new TextEditingController();
  bool isRedeem = true;

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
    getProfile();
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
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        title: Text(
          'Detail Voucher',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: '${widget.dataVoucher['data']['image']}',
                  imageBuilder: (context, imageProvider) {
                    return Stack(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: []),
                          ),
                        ),
                      ],
                    );
                  },
                  placeholder: (context, url) =>
                      Image.asset('assets/images/loader.gif'),
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Colors.black,
                          size: 16,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Available until ${widget.dataVoucher['data']['end_date']}',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    SizedBox(
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
                    //       'Minimun Transaction ${widget.dataVoucher['amount']}',
                    //       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    //     )
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 4,
                    // ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/icon/ticket_expired.png',
                          width: 16,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Reedem at ${widget.dataVoucher['data']['use_at_description']}',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.coins,
                          size: 16,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('${widget.dataVoucher['data']['need_point']}'),
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Deskripsi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text('${widget.dataVoucher['data']['short_description']}'),
                    Text('${widget.dataVoucher['data']['description']}'),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Syarat dan Ketentuan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Html(
                      data: widget.dataVoucher['data']["term_and_condition"],
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
                    SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(child: _buttonRedeem()),
              ],
            ),
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
          margin: EdgeInsets.only(bottom: 40, top: 20, left: 20, right: 20),
          width: MediaQuery.of(context).size.width,
          height: 48,
          decoration: BoxDecoration(
              color: Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(14),
          child: Center(
            child: Text(
              btnText,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
          margin: EdgeInsets.only(bottom: 40, top: 20, left: 20, right: 20),
          width: MediaQuery.of(context).size.width,
          height: 48,
          decoration: BoxDecoration(
              color: Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(14),
          child: Center(
            child: Text(
              "Klaim Voucher",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget flushbarMessage(String msg) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      message: msg,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.red[300],
      ),
      duration: Duration(seconds: 3),
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
      shape: RoundedRectangleBorder(
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
                      decoration:
                          InputDecoration(hintText: 'Enter Your Voucher Code'),
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
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
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
