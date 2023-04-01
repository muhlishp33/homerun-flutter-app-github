import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage(this.data, {Key? key}) : super(key: key);

  final dynamic data;
  @override
  NotificationDetailPageState createState() => NotificationDetailPageState();
}

class NotificationDetailPageState extends State<NotificationDetailPage> {
  HttpService http = HttpService();

  int? like;
  List<String> bannerList = [];

  @override
  void initState() {
    _callGetData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _callGetData() {
    http
        .post('getnotif-detail',
            body: {'type': widget.data['type'], 'id': widget.data['id']})
        .then((res) {})
        .catchError((err) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.colorWhite,
      appBar: AppBar(
        backgroundColor: Constants.colorWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            offset: const Offset(0.0, 9.0),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 0.5,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 0),
                      child: Center(
                          child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 35,
                        child: Image.asset(
                          'assets/images/home/icon_notif.png',
                          width: 35,
                          height: 35,
                        ),
                      )),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.data['judul'] != ''
                              ? widget.data['judul']
                              : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff444444),
                            fontSize: 20,
                          )),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Text(
                          widget.data['tgl'] != '' ? widget.data['tgl'] : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xff444444),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Text(
                          widget.data['isi'],
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xff444444),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            if (widget.data['link_label'] != null &&
                                widget.data['link_label'] is String)
                              Text(
                                widget.data['link_label'] + ': ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xff444444),
                                ),
                              ),
                            if (widget.data['link'] is String &&
                                widget.data['link'] != '')
                              InkWell(
                                onTap: () {
                                  bool isHttp =
                                      widget.data.link.contains('http');
                                  if (isHttp) {
                                    Helper(context: context)
                                        .launchURL(widget.data.link);
                                  } else {
                                    // Helper(context: context).openPage(widget.data.link);
                                  }
                                },
                                child: Text(
                                  widget.data['link'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.blue),
                                ),
                              ),
                            const SizedBox(width: 4),
                            if (widget.data['link'] is String &&
                                widget.data['link'] != '')
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: widget.data['link']));

                                  Helper(context: context).flushbar(
                                    msg: 'Berhasil disalin',
                                    success: true,
                                  );
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
