import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:appid/component/HttpService.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
// import 'package:appid/component/image_picker_handler.dart';
// import 'package:appid/component/Constants.dart';

class InfoProfilPage extends StatefulWidget {
  const InfoProfilPage(this.data, {Key? key}) : super(key: key);

  final dynamic data;

  @override
  InfoProfilPageState createState() => InfoProfilPageState();
}

const CURVE_HEIGHT = 160.0;
const AVATAR_RADIUS = CURVE_HEIGHT * 0.28;
const AVATAR_DIAMETER = AVATAR_RADIUS * 2;

class InfoProfilPageState extends State<InfoProfilPage>
    with TickerProviderStateMixin {
  // ,  ImagePickerListener
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  String photo = '';
  File? _image;
  dynamic dat;

  late AnimationController _controller;
  // ImagePickerHandler imagePicker;

  @override
  void initState() {
    dat = widget.data['dataprofil'];
    photo = widget.data['photo'];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // imagePicker = new ImagePickerHandler(this, _controller);
    // imagePicker.init();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  userImage(File image, int type) {
    if (image != null) {
      String base64Image = base64Encode(image.readAsBytesSync());
      String fileName = image.path.split("/").last;

      http.post('uploadprofile', body: {
        "image": base64Image,
        "name": fileName,
      }).then((res) {
        if (res.toString() != null) {
          http.post('profile').then((response) {
            if (response.toString() != null) {
              setState(() {
                photo = response['data']['photo'];
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(photo);
        return Future.value(false);
      },
      child: Scaffold(
        key: _key,
        appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black, //change your color here
            ),
            backgroundColor: Colors.white,
            centerTitle: false,
            title: Text('My Profile', style: Constants.textAppBar3),
            elevation: 1,
            actions: const <Widget>[
              // new IconButton(
              //   padding: const EdgeInsets.only(right: 10),
              //   tooltip: "Edit Informasi Pengguna",
              //   icon: Icon(
              //     Icons.edit_outlined,
              //   ),
              //   onPressed: () {
              //     dynamic data = {
              //       "dataprofil": widget.data['dataprofil'],
              //       "data": widget.data['data']
              //     };

              //     Navigator.pushNamed(context, '/editProfilPage',
              //         arguments: data);
              //   },
              // ),
            ]),
        backgroundColor: Colors.white,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 30),
                                  child: Row(
                                    children: [
                                      (photo != '' && photo != null)
                                          ? GestureDetector(
                                              onTap: () {
                                                // imagePicker.showDialog(context);
                                              },
                                              child: CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(photo),
                                                radius: 35,
                                                child: const Text('',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                            )
                                          : CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              radius: 35,
                                              child: const FaIcon(
                                                  FontAwesomeIcons.userLarge,
                                                  color: Constants.redTheme),
                                            ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.data["data"]["nama"] ?? '',
                                            ),
                                            Text(
                                              widget.data["data"]["nama"] !=
                                                      null
                                                  ? 'Joined since August 2021'
                                                  : '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    dynamic data = {
                                      "dataprofil": widget.data['dataprofil'],
                                      "data": widget.data['data']
                                    };

                                    Navigator.pushNamed(
                                        context, '/editProfilPage',
                                        arguments: data);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Constants.redTheme),
                                        borderRadius: BorderRadius.circular(8)),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                          color: Constants.redTheme),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: [
                  for (var item in dat)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 0.5,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          item['value'] != 'Email' &&
                                  item['value'] != 'No. Handphone'
                              ? ''
                              : item['value'] != 'Email'
                                  ? Navigator.of(context)
                                      .pushNamed('/changeNoHp')
                                  : Navigator.of(context)
                                      .pushNamed('/changeEmail');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 30,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        item['value'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item['value2'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: item['value'] != 'Email' &&
                                        item['value'] != 'No. Handphone'
                                    ? Container()
                                    : const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
