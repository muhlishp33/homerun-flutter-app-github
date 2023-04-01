import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class DetailInboxPage extends StatefulWidget {
  const DetailInboxPage(this.data, {super.key});

  final dynamic data;
  @override
  State<DetailInboxPage> createState() => _DetailInboxPageState();
}

class _DetailInboxPageState extends State<DetailInboxPage> {
  HttpService http = HttpService();
  bool _isLoading = true;
  Map detailInbox = {
    'judul': '',
  };

  _getDetailInbox() async {
    Map body = {
      'id': widget.data['id'],
    };

    await http.post('getnotif-detail', body: body).then((res) {
      if (res['success']) {
        setState(() {
          detailInbox = res['msg'];
        });
      }
    }).catchError((err) {
      log("======ERROR $err");
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getDetailInbox();
  }

  @override
  void dispose() {
    super.dispose();
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
      body: LoadingFallback(
        isLoading: _isLoading,
        child: SafeArea(
            child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(238, 238, 238, 1),
                            offset: Offset(0.0, 9.0),
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
                        child: const Icon(
                          Icons.mail_outline,
                          size: 35,
                          color: Color(0xff444444),
                        ),
                      )),
                    ),
                  ],
                ),
                if (detailInbox != {} && _isLoading == false)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            detailInbox['judul'] != ''
                                ? detailInbox['judul']
                                : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff444444),
                              fontSize: 20,
                            )),

                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: Text(
                            detailInbox['tgl2'] != ''
                                ? detailInbox['tgl2']
                                : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Color(0xff444444),
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // AutoSizeText(widget.data.isi !=''?widget.data.isi : '', minFontSize: 10,
                        //   style: TextStyle(
                        //   fontWeight: FontWeight.normal,
                        //   color: Colors.black,
                        //   fontSize: 18,
                        // )),

                        // Html(
                        //   data: widget.data.isi != '' ? widget.data.isi : '',
                        //   //Optional parameters:
                        //   style: {
                        //     "html": Style(fontSize: FontSize.medium),
                        //   },
                        //   onLinkTap: (url) {
                        //     _launchURL(url);
                        //     ("Opening $url...");
                        //   },
                        //   onImageTap: (src) {
                        //     (src);
                        //   },
                        //   onImageError: (exception, stackTrace) {
                        //     (exception);
                        //   },
                        // ),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: SelectableText(
                            detailInbox['isi'],
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Color(0xff444444),
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: Wrap(
                            children: [
                              if (widget.data['link_label'] is String &&
                                  widget.data['link_label'] != '')
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
                                        widget.data['link'].contains('http');
                                    if (isHttp) {
                                      // Helper(context: context).launchURL(widget.data['link']);
                                    } else {
                                      // Helper(context: context).openPage(widget.data['link']);
                                    }
                                  },
                                  child: const Text(
                                    'Lihat Tautan',
                                    style: TextStyle(
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
                                      ClipboardData(text: widget.data['link']),
                                    );

                                    // Helper(context: context).flushbar(
                                    //   msg: 'Berhasil disalin',
                                    //   success: true,
                                    // );
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
        )),
      ),
    );
  }
}
