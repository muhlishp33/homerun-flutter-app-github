import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appid/helper/color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';

import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/component/widget/Index.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../component/http_service.dart';

class VoucherDetailPage extends StatefulWidget {
  VoucherDetailPage(this.data, {this.fromPage, Key? key}) : super(key: key);
  final dynamic data;
  dynamic fromPage;
  _VoucherDetailPageState createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  HttpService http = HttpService();
  int like = 0;
  List<String> bannerList = [];
  dynamic datahis;
  dynamic datapembayaran;
  dynamic summary;
  List<dynamic> listTransaksi = [];
  TextEditingController voucherCode = TextEditingController();
  bool isRedeem = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String total = '0';
  String firstDate = "";
  String secondDate = "";
  dynamic voucherDetail;
  List<dynamic> partnerList = [];
  DateTime selectedEndDate = DateTime.now();
  DateTime selectedStartDate = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  GlobalKey _androidScreenShoot = GlobalKey();
  dynamic profile;
  String namaProfile = "";
  String iplProfile = "";
  String dateEnd = '';

  @override
  void initState() {
    getData();
    getProfile();
    super.initState();
  }

  getData() {
    http.post("voucher-detail", body: {"id": widget.data['data']['id']}).then(
        (res) {
      if (res['success']) {
        setState(() {
          voucherDetail = res['data'];
          partnerList = res['data']['partner'];
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
                        "Use Now",
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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final bannerHeight = height * 0.3;
    final imageUrl = 'https://placekitten.com/300/300';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  new Stack(
                    children: [
                      Container(
                        height: bannerHeight,
                        width: width,
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CachedNetworkImage(
                            imageUrl: widget.data['data']['image'].toString(),
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  // borderRadius:
                                  //     BorderRadius.circular(8),
                                  color: Colors.black,
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                      colorFilter: ColorFilter.mode(
                                          const Color(0x000000).withOpacity(0),
                                          BlendMode.darken)),
                                ),
                              );
                            },
                            placeholder: (context, url) =>
                                Image.asset('assets/images/loader.gif'),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: new Icon(Icons.arrow_back, color: Colors.white),
                        tooltip: "Back",
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  widget.data['data']['v_name'].toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            if (widget.data['data']['share_link'] != null)
                              InkWell(
                                onTap: () {
                                  Helper(context: context).share(
                                    title: widget.data['data']['v_name'],
                                    linkUrl: widget.data['data']['share_link'],
                                    text: widget.data['data']['v_name'],
                                  );
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  'Available until ${DateFormat("dd MMMM yyyy").format(DateTime.parse(widget.data['data']['end_date']))}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
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
                                  'Reedem at ${widget.data['data']['use_at_description']}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
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
                                Text('${widget.data['data']['need_point']}'),
                              ],
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Text(
                              'Deskripsi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text('${widget.data['data']['short_description']}'),
                            Text('${widget.data['data']['description']}'),
                            SizedBox(
                              height: 15,
                            ),
                            if (widget.data['data']['online_voucher'])
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kode Voucher',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (widget.data['data']
                                                      ['copy_voucher_code'] !=
                                                  null)
                                              ? widget.data['data']
                                                      ['copy_voucher_code']
                                                  .toString()
                                              : "-",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        child: Icon(Icons.copy,
                                            color: Colors.black),
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: widget.data['data']
                                                  ['copy_voucher_code']));

                                          flushbarMessage("Copied");
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 14,
                            ),
                            if (voucherDetail != null &&
                                voucherDetail["type"] != null &&
                                voucherDetail["type"] == "BARCODE")
                              Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
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
                                              child: Center(
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
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              'Syarat dan Ketentuan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Html(
                              data: widget.data['data']["term_and_condition"],
                              //Optional parameters:

                              style: {
                                "html": Style(
                                    fontSize: FontSize.medium,
                                    letterSpacing: 0.5,
                                    wordSpacing: 1.2,
                                    fontFamily: "Poppins"),
                              },
                              onLinkTap: (url, rcontext, attributes, element) {
                                ("Opening $url...");
                                return Helper(context: context).launchURL(url);
                              },
                              onImageTap: (src, rcontext, attributes, element) {
                                (src);
                              },
                              onImageError: (exception, stackTrace) {
                                (exception);
                              },
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Cara Memakai Voucher',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Html(
                              data: '${widget.data['data']["how_to_use"]}',
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
                              onLinkTap: (url, rcontext, attributes, element) {
                                ("Opening $url...");
                                return Helper(context: context).launchURL(url);
                              },
                              onImageTap: (src, rcontext, attributes, element) {
                                (src);
                              },
                              onImageError: (exception, stackTrace) {
                                (exception);
                              },
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (isRedeem)
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Expanded(child: _buttonRedeem()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _claimVoucher() {
    var body = {"code": widget.data['data']['v_code']};
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

  Widget _flushbar({context, msg, bool success: false}) {
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
    )..show(context).then((value) {
        if (success) {
          Navigator.of(context).popUntil((route) {
            return route.settings.name == 'voucherPage';
          });
        }
      });
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

  Widget _buttonRedeem() {
    if (widget.fromPage == 'my_rewards' || widget.fromPage == 'loyalti') {
      String btnText = "Tukarkan Voucher";
      bool isOnline = (widget.data['data']["type"] == "ONLINE") ? true : false;
      bool isImage = (widget.data['data']["type"] == "IMAGE") ? true : false;
      if (isOnline) {
        btnText = "Salin Kode Voucher";
      }
      if (isImage) {
        btnText = "Lihat Voucher";
      }
      return InkWell(
        onTap: () async {
          if (!isOnline && !isImage) {
            final id = widget.data['data']['id'];
            final title = widget.data['data']['v_name'];
            // final String eventName = "my_reward/redeem";
            // final Map<String, dynamic> eventValues = {
            //   'id': id,
            //   'title': title,
            // };

            return showBottomModal();
          }
          if (isOnline) {
            return await Clipboard.setData(ClipboardData(
                    text: widget.data['data']['copy_voucher_code']))
                .then((value) {
              return flushbarMessage("Copied");
            });
          }
          if (isImage) {
            (isImage);
            return Helper(context: context)
                .viewPhoto(
                    url: widget.data['data']['image_voucher'],
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
          margin: EdgeInsets.only(bottom: 40, top: 20),
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
          final id = widget.data['data']['id'];
          final title = widget.data['data']['v_name'];
          // final String eventName = 'loyalti/claim';
          // final Map<String, dynamic> eventValues = {
          //   'id': id,
          //   'title': title,
          // };

          _claimVoucher();
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          width: MediaQuery.of(context).size.width,
          height: 48,
          decoration: BoxDecoration(
              color: Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Center(
                child: Text(
              'Klaim Voucher',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            )),
          ),
        ),
      );
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }
}
