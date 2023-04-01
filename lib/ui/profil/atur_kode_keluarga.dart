import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class AturKodeKeluargaPage extends StatefulWidget {
  const AturKodeKeluargaPage(this.data, {Key? key}) : super(key: key);
  final dynamic data;
  @override
  _AturKodeKeluargaPageState createState() => _AturKodeKeluargaPageState();
}

const CURVE_HEIGHT = 160.0;
const AVATAR_RADIUS = CURVE_HEIGHT * 0.28;
const AVATAR_DIAMETER = AVATAR_RADIUS * 2;

class _AturKodeKeluargaPageState extends State<AturKodeKeluargaPage>
    with TickerProviderStateMixin {
  // , ImagePickerListener
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool statusClose = false;
  dynamic datahis;
  dynamic datap;
  List<Widget> _his = [];
  final List<Widget> _listdetail = [];
  String photo = '';
  String nama = '';
  int merch = 1;
  late AnimationController _controller;
  File? _image;
  dynamic dat;
  bool isLoading = false;

  @override
  void initState() {
    dat = widget.data['dataprofil'];
    photo = widget.data['photo'];
    (photo);
    super.initState();
    _callGetData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  buildItem(String label) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(label),
    );
  }

  void _callGetData() {
    http.post('keluarga').then((res) {
      ('Keluarga bro === $res');
      setState(() {
        _his = [];
      });

      setState(() {
        datahis = res['msg'];
        for (var item in datahis) {
          _his.add(
            Card(
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xffed1c24),
                      radius: 20,
                      child:
                          FaIcon(FontAwesomeIcons.userAlt, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      //leading: FlutterLogo(size: 56.0),
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Text(
                          item['value'],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text(
                          item['value2'],
                          style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ),

                      //trailing: Icon(Icons.more_vert),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      deleteakun(item);
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const FaIcon(FontAwesomeIcons.trashAlt,
                          size: 15.0, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          );

          _his.add(SizedBox(height: MediaQuery.of(context).size.height * 0.02));
        }
      });
    });
  }

  void close() {
    var duration = const Duration(seconds: 2);
    Timer(duration, () {
      statusClose = false;
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      _his = [];
    });

    http.post('keluarga').then((res) {
      if (res.toString() != null) {
        setState(() {
          datahis = res['msg'];
          for (var item in datahis) {
            _his.add(
              Card(
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xffed1c24),
                        radius: 20,
                        child: FaIcon(FontAwesomeIcons.userAlt,
                            color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        //leading: FlutterLogo(size: 56.0),
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Text(
                            item['value'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            item['value2'],
                            style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        //trailing: Icon(Icons.more_vert),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        deleteakun(item);
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const FaIcon(FontAwesomeIcons.trashAlt,
                            size: 15.0, color: Colors.grey),
                      ),
                    )
                  ],
                ),
              ),
            );

            _his.add(
                SizedBox(height: MediaQuery.of(context).size.height * 0.02));
          }
        });

        _refreshController.refreshCompleted();
      } else {
        _refreshController.refreshFailed();
      }
    });
  }

  void deleteakun(dynamic data) {
    Alert(
      style: const AlertStyle(
        isCloseButton: false,
        //isOverlayTapDismiss: false,
        //isButtonVisible:false,

        //buttonAreaPadding :EdgeInsets.all(10)
      ),
      context: context,
      //type: AlertType.,
      title: "",
      content: Column(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffed1c24),
            radius: 40,
            child: FaIcon(FontAwesomeIcons.userAlt, color: Colors.white),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const Text(
            "Anda yakin ingin menghapus data ini ?",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            _callPostApi(data['val']);
          },
          color: Colors.blue,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: const Color(0xffed1c24),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  void _callPostApi(String id) {
    setState(() {
      isLoading = true;
    });

    http.post('deletekeluarga', body: {
      "id": id,
    }).then((res) {
      setState(() {
        isLoading = false;
      });

      if (res['success'] == false) {
        Flushbar(
          //title:  "Hey Ninja",
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          flushbarPosition: FlushbarPosition.TOP,
          borderRadius: BorderRadius.circular(8),
          //backgroundColor: Colors.white,

          //showProgressIndicator:true,
          message: res['msg'],
          duration: const Duration(seconds: 3),
        ).show(context);
      } else {
        Flushbar(
          //title:  "Hey Ninja",
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          flushbarPosition: FlushbarPosition.TOP,
          borderRadius: BorderRadius.circular(8),
          //backgroundColor: Colors.white,

          //showProgressIndicator:true,
          message: 'Hapus data berhasil',
          duration: const Duration(seconds: 3),
        ).show(context);
        setState(() {});
        _callGetData();
      }
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: LoadingFallback(
        isLoading: isLoading,
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      child: Center(
                        child:
                            //  (photo != '' && photo != null)
                            //     ?
                            CircleAvatar(
                          backgroundImage: NetworkImage(photo),
                          radius: 50,
                          child: const Text('',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center),
                        ),
                        // : (_image == null
                        //     ? CircleAvatar(
                        //         backgroundColor: Colors.white,
                        //         radius: 50,
                        //         child: FaIcon(
                        //           FontAwesomeIcons.userAlt,
                        //           color: Color(0xffed1c24),
                        //           size: 36.0,
                        //         ),
                        //       )
                        //     : Container(
                        //         height: 100.0,
                        //         width: 100.0,
                        //         decoration: new BoxDecoration(
                        //           color: Colors.white,
                        //           image: new DecorationImage(
                        //             image: FileImage(File(_image.path)),
                        //             fit: BoxFit.cover,
                        //           ),
                        //           //border:
                        //           //Border.all(color: const Color(0xff33a9e5), width: 2.0),
                        //           borderRadius: new BorderRadius.all(
                        //               const Radius.circular(80.0)),
                        //         ),
                        //       )),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 12, 0, 2),
                      child: Text(
                        widget.data['data']['nama'] ?? '',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    // === takeout points ===
                    // Container(
                    //   child: Text(
                    //     '100 Point',
                    //     style: TextStyle(
                    //         color: Colors.red,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w500),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                      child: Column(
                        children: _his,
                      ),
                    ),

                    //Column(children: _profil),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // userImage(File _image, int type) {
  //   // TODO: implement userImage
  //   if (_image != null) {
  //     String base64Image = base64Encode(_image.readAsBytesSync());
  //     String fileName = _image.path.split("/").last;
  //     (base64Image);
  //     (fileName);
  //     http.post('uploadprofile', body: {
  //       "image": base64Image,
  //       "name": fileName,
  //     }).then((res) {
  //       if (res.toString() != null) {
  //         setState(() {
  //           this._image = _image;
  //         });
  //       }
  //     });
  //   }
  // }
}

class CurvedShape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: CURVE_HEIGHT,
      child: CustomPaint(
        painter: _MyPainter(),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = const Color(0xffed1c24);

    Offset circleCenter = Offset(size.width / 2, size.height - AVATAR_RADIUS);

    Offset topLeft = const Offset(0, 0);
    Offset bottomLeft = Offset(0, size.height * 0.8);
    Offset topRight = Offset(size.width, 0);
    Offset bottomRight = Offset(size.width, size.height * 0.8);

    Offset leftCurveControlPoint = Offset(circleCenter.dx * 100.5, size.height);
    Offset rightCurveControlPoint = Offset(size.width * 0.5, size.height * 1.5);

    const arcStartAngle = 200 / 180 * pi;
    final avatarLeftPointX =
        circleCenter.dx + AVATAR_RADIUS * cos(arcStartAngle);
    final avatarLeftPointY =
        circleCenter.dy + AVATAR_RADIUS * sin(arcStartAngle);
    Offset avatarLeftPoint =
        Offset(avatarLeftPointX, avatarLeftPointY); // the left point of the arc

    const arcEndAngle = -5 / 180 * pi;
    final avatarRightPointX =
        circleCenter.dx + AVATAR_RADIUS * cos(arcEndAngle);
    final avatarRightPointY =
        circleCenter.dy + AVATAR_RADIUS * sin(arcEndAngle);
    Offset avatarRightPoint = Offset(
        avatarRightPointX, avatarRightPointY); // the right point of the arc

    Path path = Path()
      ..moveTo(topLeft.dx,
          topLeft.dy) // this move isn't required since the start point is (0,0)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      //..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy, bottomLeft.dx, bottomLeft.dy)
      //..arcToPoint(avatarRightPoint, radius: Radius.circular(AVATAR_RADIUS))
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
