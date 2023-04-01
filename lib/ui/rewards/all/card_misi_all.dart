import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';

class CardMisiAll extends StatefulWidget {
  dynamic type;
  CardMisiAll(this.type);
  @override
  State<CardMisiAll> createState() => _CardMisiAllState();
}

class _CardMisiAllState extends State<CardMisiAll> {
  HttpService http = HttpService();
  dynamic dataMisi;

  getData() {
    http.post('loyalty-my-mission', body: {'type': widget.type}).then((res) {
      if (res['success']) {
        setState(() {
          dataMisi = res['data'];
        });
      }
      // ("profil = $dataProfile");
    }).catchError((e) {
      Helper(context: context).alert(
        text: e.toString(),
      );
    });
  }

  claimData() {
    http.post('daily-login').then((value) {
      if (value['success']) {
        setState(() {
          getData();
        });
      } else {
        Helper(context: context).alert(text: value['msg'].toString());
      }
    }).catchError((e) {
      Helper(context: context).alert(text: e.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return dataMisi == null
        ? Image.asset('assets/images/loader.gif')
        : dataMisi.isEmpty
            ? EmptyStateLoyalty('Misi belum tersedia')
            : ListView.builder(
                itemCount: dataMisi.length,
                itemBuilder: (context, snap) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailMisiPage',
                          arguments: dataMisi[snap]['id']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: widget.type == 'ACTIVE' ? 320 : 290,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color(0xffe5e5e5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 6,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${dataMisi[snap]['image_url']}',
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
                                              dataMisi[snap]['header_label'],
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Dapatkan ${NumberFormat.currency(locale: 'id', decimalDigits: 0).format(dataMisi[snap]['get_point']).split('IDR').last} Point',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                                Text(
                                                  '${dataMisi[snap]['status_label'].toString()}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                      .width) *
                                                  (
                                                      // data["detail_rank"][
                                                      //       "member_current_progress"]
                                                      dataMisi[snap]
                                                              ["progress"] /
                                                          dataMisi[snap][
                                                              "total_progress"]),
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
                                        widget.type == 'ACTIVE'
                                            ? InkWell(
                                                onTap: () {
                                                  if (dataMisi[snap]
                                                          ['category'] ==
                                                      'DAILY_LOGIN') {
                                                    claimData();
                                                  } else {
                                                    if (dataMisi[snap]
                                                            ['path'] !=
                                                        null) {
                                                      // Helper(context: context)
                                                      //     .openPage(
                                                      //         dataMisi[snap]
                                                      //             ['path']);
                                                    }

                                                    // Navigator.pushNamed(
                                                    //   context,
                                                    //   '/${dataMisi['path']}',
                                                    // );
                                                  }
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: widget.type ==
                                                              'ACTIVE'
                                                          ? Color(0xffee6055)
                                                          : Colors.white
                                                              .withOpacity(
                                                                  0.4)),
                                                  child: Center(
                                                      child: Text(
                                                    '${dataMisi[snap]['button_label']}',
                                                    style: TextStyle(
                                                        color: widget.type ==
                                                                'ACTIVE'
                                                            ? Colors.white
                                                            : Color(0xffcccccc),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  )),
                                                ),
                                              )
                                            : Container()
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
              );
  }
}
