import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/main_menu.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';

import '../../../component/widget/app_notification.dart';

class CardSearchVoucher extends StatefulWidget {
  dynamic listdata;
  CardSearchVoucher(this.listdata);
  @override
  State<CardSearchVoucher> createState() => _CardSearchVoucherState();
}

class _CardSearchVoucherState extends State<CardSearchVoucher> {
  dynamic profile;
  String namaProfile = "";
  String iplProfile = "";
  HttpService http = HttpService();
  TextEditingController voucherCode = new TextEditingController();
  bool isRedeem = false;

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
  void initState() {
    // TODO: implement initState

    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listdata.isEmpty
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyStateLoyalty('Oops data tidak ditemukan'),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              child: ListView.builder(
                itemCount: widget.listdata.length,
                itemBuilder: (context, snap) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detailVoucherSearchPage',
                        arguments: {
                          "data": widget.listdata[snap],
                          "from_page": "my_rewards"
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 360,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xffe5e5e5))),
                            child: Stack(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${widget.listdata[snap]['image']}',
                                          imageBuilder:
                                              (context, imageProvider) {
                                            return Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12),
                                                    topRight:
                                                        Radius.circular(12)),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  'assets/images/loader.gif'),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 100,
                                                  child: Icon(Icons.error)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${widget.listdata[snap]['v_name']}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  'Berlaku Hingga ${widget.listdata[snap]['end_date']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/location.png',
                                                  height: 16,
                                                  width: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    '${widget.listdata[snap]['use_at_description']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      )
                                    ]),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 100),
                                          child: _buttonRedeem(
                                              widget.listdata[snap], snap),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  Widget _buttonRedeem(dataVoucher, snap) {
    if (dataVoucher['status'] == 1) {
      String btnText = "Tukarkan Voucher";
      bool isOnline = (dataVoucher['type'] == "ONLINE") ? true : false;
      bool isImage = (dataVoucher['type'] == "IMAGE") ? true : false;
      if (isOnline) {
        btnText = "Salin Kode Voucher";
      }
      if (isImage) {
        btnText = "Lihat Voucher";
      }
      return InkWell(
        onTap: () async {
          if (!isOnline && !isImage) {
            final id = dataVoucher['id'];
            final title = dataVoucher['v_name'];
            // final String eventName = "my_reward/redeem";
            // final Map<String, dynamic> eventValues = {
            //   'id': id,
            //   'title': title,
            // };

            return showBottomModal();
          }
          if (isOnline) {
            return await Clipboard.setData(
                    ClipboardData(text: dataVoucher['copy_voucher_code']))
                .then((value) {
              return flushbarMessage("Copied");
            });
          }
          if (isImage) {
            (isImage);
            return Helper(context: context)
                .viewPhoto(
                    url: dataVoucher['image_voucher'], heroTag: "voucher-image")
                .then((value) {
              ("value = $value");
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            });
          }
        },
        child: Container(
          margin: EdgeInsets.only(
            top: 20,
          ),
          height: 38,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
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
          final id = dataVoucher['id'];
          final title = dataVoucher['v_name'];
          // final String eventName = 'loyalti/claim';
          // final Map<String, dynamic> eventValues = {
          //   'id': id,
          //   'title': title,
          // };

          _claimVoucher(snap);
        },
        child: Container(
          margin: EdgeInsets.only(
            top: 20,
          ),
          height: 38,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xffee6055),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
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

  _claimVoucher(snap) {
    var body = {"code": widget.listdata[snap]['v_code']};
    //("profile = ${profile} ");
    http.post("claim-voucher", body: body).then((res) {
      ("claim = $res");
      if (res["success"]) {
        return showAppNotification(
            context: context,
            title: 'Sukses',
            desc: res["msg"].toString(),
            onSubmit: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => MainMenuPage(
                    indexTab: 3,
                  ),
                ),
              );
            });
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
}
