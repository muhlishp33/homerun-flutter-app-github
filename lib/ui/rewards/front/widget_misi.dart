import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';

import '../../../component/http_service.dart';

class WidgetMisi extends StatefulWidget {
  dynamic dataMisi;
  WidgetMisi(this.dataMisi);
  @override
  State<WidgetMisi> createState() => _WidgetMisiState();
}

class _WidgetMisiState extends State<WidgetMisi> {
  HttpService http = HttpService();

  claimData() {
    http.post('daily-login').then((value) {
      if (value['success']) {
        setState(() {
          Helper(context: context).alert(text: 'Berhasil klaim');
        });
      } else {
        Helper(context: context).alert(text: value['msg'].toString());
      }
    }).catchError((e) {
      Helper(context: context).alert(text: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.dataMisi.isEmpty
        ? EmptyStateLoyalty('Anda tidak Memiliki Misi saat ini')
        : Container(
            height: 320,
            child: ListView.builder(
              itemCount: widget.dataMisi.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, snap) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/detailMisiPage',
                        arguments: widget.dataMisi[snap]['id']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xffe5e5e5))),
                          child: Stack(
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 6,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '${widget.dataMisi[snap]['image_url']}',
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight:
                                                      Radius.circular(12)),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill,
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
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.dataMisi[snap]['header_label']}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Dapatkan ${NumberFormat.currency(locale: 'id', decimalDigits: 0).format(widget.dataMisi[snap]['get_point']).split('IDR').last} Point',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                '${widget.dataMisi[snap]['status_label'].toString()}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ]),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Color(0xfff5f5f5),
                                            ),
                                          ),
                                          Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.65) *
                                                (widget.dataMisi[snap]
                                                        ["progress"] /
                                                    widget.dataMisi[snap]
                                                        ["total_progress"]),
                                            height: 7,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Color(0xffee6055),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 11,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (widget.dataMisi[snap]
                                                  ['category'] ==
                                              'DAILY_LOGIN') {
                                            claimData();
                                          } else {
                                            if (widget.dataMisi[snap]['path'] !=
                                                null) {
                                              // helper(context: context).openPage(
                                              //     widget.dataMisi[snap]
                                              //         ['path']);
                                            }

                                            // Navigator.pushNamed(
                                            //   context,
                                            //   '/${dataMisi['path']}',
                                            // );
                                          }
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xffee6055)),
                                          child: Center(
                                              child: Text(
                                            '${widget.dataMisi[snap]['button_label']}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800),
                                          )),
                                        ),
                                      ),
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
          );
  }
}
