import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/ui/main_menu.dart';

import '../../../component/widget/app_notification.dart';

class CardAllBeli extends StatefulWidget {
  dynamic listdata;
  CardAllBeli(this.listdata);
  @override
  State<CardAllBeli> createState() => _CardAllBeliState();
}

class _CardAllBeliState extends State<CardAllBeli> {
  dynamic profile;
  String namaProfile = "";
  String iplProfile = "";
  HttpService http = HttpService();

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        child: ListView.builder(
          itemCount: widget.listdata.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, snap) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/detailVoucherBeliPage',
                    arguments: widget.listdata[snap]);
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '${widget.listdata[snap]['image']}',
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12)),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) =>
                                        Image.asset('assets/images/loader.gif'),
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
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            '${widget.listdata[snap]['use_at_description']}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
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
                                InkWell(
                                  onTap: () {
                                    final id = widget.listdata[snap]['id'];
                                    final title =
                                        widget.listdata[snap]['v_name'];
                                    // final String eventName = 'loyalti/claim';
                                    // final Map<String, dynamic> eventValues = {
                                    //   'id': id,
                                    //   'title': title,
                                    // };

                                    _claimVoucher(snap);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xffee6055)),
                                    child: Center(
                                        child: Text(
                                      'Klaim Voucher',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800),
                                    )),
                                  ),
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
      ),
    );
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
