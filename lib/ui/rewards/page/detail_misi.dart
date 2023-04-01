import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:appid/helper/helper.dart';

import '../../../component/http_service.dart';

class DetailMisi extends StatefulWidget {
  dynamic id;
  DetailMisi(this.id);
  @override
  State<DetailMisi> createState() => _DetailMisiState();
}

class _DetailMisiState extends State<DetailMisi> {
  dynamic dataMisi;
  HttpService http = HttpService();
  bool loading = true;

  getData() {
    http.post('loyalty-detail-mission', body: {"id": widget.id}).then((res) {
      if (res['success']) {
        setState(() {
          dataMisi = res['data'];
          loading = false;
        });
      }
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
    getData();
    super.initState();
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
          'Detail Misi',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: loading
          ? Center(
              child: Image.asset(
                'assets/images/loader.gif',
                height: 100.0,
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 6,
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
                          imageUrl: '${dataMisi['image_url']}',
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
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Colors.black.withOpacity(0.88),
                                          Colors.black.withOpacity(0.4)
                                        ]),
                                    color: Colors.black.withOpacity(0.65),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${dataMisi['header_label']}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            '${dataMisi['caption_label']}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ]),
                                  ),
                                ),
                              ],
                            );
                          },
                          placeholder: (context, url) =>
                              Image.asset('assets/images/loader.gif'),
                          errorWidget: (context, url, error) => Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Colors.black.withOpacity(0.88),
                                      Colors.black.withOpacity(0.4)
                                    ]),
                                color: Colors.black.withOpacity(0.65),
                              ),
                              child: Icon(Icons.error)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 15, left: 20, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text('${dataMisi['description']}'),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Text(
                              'Progres Transaksi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Transaksi Berhasil'),
                                Text('${dataMisi['status_label'].toString()}'),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Color(0xffe5e5e5),
                                  ),
                                ),
                                Container(
                                  width: (MediaQuery.of(context).size.width) *
                                      (dataMisi['progress'] / 10),
                                  height: 7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Color(0xffee6055),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            dataMisi['progress_data'] != null
                                ? ListView.builder(
                                    itemCount: dataMisi['progress_data'].length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, snap) {
                                      return dataMisi['progress_data'][snap]
                                                  ['status'] ==
                                              false
                                          ? Container()
                                          : Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 12),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xffe5e5e5),
                                                      width: 0.5)),
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffee6055),
                                                        shape: BoxShape.circle),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${dataMisi['progress_data'][snap]['label']}',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                          '${dataMisi['progress_data'][snap]['date']}')
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                    },
                                  )
                                : dataMisi['progression'] != null &&
                                        dataMisi['progression'].isNotEmpty
                                    ? ListView.builder(
                                        itemCount:
                                            dataMisi['progression'].length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, snap) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Color(0xffe5e5e5),
                                                    width: 0.5)),
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffee6055),
                                                      shape: BoxShape.circle),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${dataMisi['progression'][snap]['label']}',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                        '${dataMisi['progression'][snap]['date']}')
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Syarat dan Ketentuan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: dataMisi['terms_data'].length,
                              itemBuilder: (context, snap) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${snap + 1}'),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Flexible(
                                        child: Text(
                                            '${dataMisi['terms_data'][snap]['label']}'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      if (dataMisi['category'] == 'DAILY_LOGIN') {
                        claimData();
                      } else {
                        if (dataMisi['path'] != null) {
                          // Helper(context: context).openPage(dataMisi['path']);
                        }

                        // Navigator.pushNamed(
                        //   context,
                        //   '/${dataMisi['path']}',
                        // );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 48),
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      decoration: BoxDecoration(
                          color: Color(0xffee6055),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Center(
                            child: Text(
                          '${dataMisi['button_label']}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        )),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
