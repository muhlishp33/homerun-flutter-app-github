import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';

import '../../../component/widget/app_notification.dart';

class CardVoucherSaya extends StatefulWidget {
  dynamic listData, type;
  CardVoucherSaya(this.listData, this.type);
  @override
  State<CardVoucherSaya> createState() => _CardVoucherSayaState();
}

class _CardVoucherSayaState extends State<CardVoucherSaya> {
  TextEditingController voucherCode = new TextEditingController();
  bool isRedeem = true;
  HttpService http = HttpService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: widget.listData.isEmpty
          ? EmptyStateLoyalty('Anda tidak Memiliki Voucher Aktif')
          : ListView.builder(
              itemCount: widget.listData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, snap) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/detailVoucherSayaPage',
                        arguments: {
                          "data": widget.listData[snap],
                          "type": widget.type,
                          "from_page": "my_rewards"
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 320,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xffe5e5e5))),
                          child: Stack(
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '${widget.listData[snap]['image']}',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight:
                                                      Radius.circular(12)),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
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
                                            '${widget.listData[snap]['v_name']}',
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
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Berlaku Hingga ${widget.listData[snap]['end_date']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
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
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${widget.listData[snap]['use_at_description']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buttonRedeem(
                                      widget.listData[snap],
                                    )
                                  ],
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
    );
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

  Widget _buttonRedeem(dataVoucher) {
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
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Color(0xffee6055)),
        child: Center(
          child: Text(
            btnText,
            style: TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
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
