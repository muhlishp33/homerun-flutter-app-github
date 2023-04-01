import 'dart:async';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:appid/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/app_notification.dart';
import 'package:appid/component/widget/constants.dart';

class DaftarAlamatPage extends StatefulWidget {
  const DaftarAlamatPage({Key? key}) : super(key: key);
  @override
  DaftarAlamatState createState() => DaftarAlamatState();
}

class DaftarAlamatState extends State<DaftarAlamatPage> {
  List<dynamic> dataList = [];
  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  bool isLoading = true;

  List dataAddress = [];
  List filterAddress = [];
  dynamic selectedAlamat;
  Timer? _debounce;
  TextEditingController searchText = TextEditingController();

  @override
  void initState() {
    getAddressUser();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void getAddressUser() {
    http.post('address').then((res) {
      // log('res address $res');

      setState(() {
        dataAddress = res['data'];
        isLoading = false;
      });
    }).catchError((err) {
      log('err address $err');

      setState(() {
        isLoading = false;
      });
    });
  }

  void deleteAddress(item) {
    setState(() {
      isLoading = true;
    });

    dynamic body = {"id": item['id']};

    http.post('address/delete', body: body).then((res) {
      if (res['success'] == true) {
        showAppNotification(
          context: context,
          title: 'Success',
          desc: res["msg"],
          onSubmit: () {}
        );

        setState(() {
          selectedAlamat = null;
        });

        getAddressUser();
      } else {
        Helper(context: context).flushbar(msg: res['msg'], success: false);
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<dynamic> onSetPrimaryAddress() async {
    setState(() {
      isLoading = true;
    });

    dynamic body = {"id": selectedAlamat['id']};

    // log('body $body');

    http.post('address/primary', body: body).then((res) {
      if (res['success'] == false) {
        showAppNotification(
            context: context,
            title: 'Gagal',
            desc: res["msg"],
            onSubmit: () {}
        );
      } else {
        showAppNotification(
            context: context,
            title: 'Berhasil',
            desc: res["msg"],
            onSubmit: () {}
        );

        setState(() {
          selectedAlamat = null;
        });

        getAddressUser();
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      showAppNotification(
          context: context,
          title: 'Gagal',
          desc: e.toString(),
          onSubmit: () {}
      );

      setState(() {
        isLoading = false;
      });
    });
  }

  void flushbarGagal(BuildContext context, msg) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      message: msg,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.red[300],
      ),
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  AppBar _buildBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      // leading: new IconButton(
      //   icon: new Icon(Icons.arrow_back, color: Colors.black),
      //   tooltip: "Kembali",
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      backgroundColor: Colors.white,
      titleSpacing: 0,
      centerTitle: false,
      title: Text('My Address', style: Constants.textAppBar3),
      actions: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(right: 20),
          child: InkWell(
            onTap: () {
              dynamic args = {};
              Navigator.pushNamed(context, '/addAddressPage', arguments: args)
                  .then(
                (value) => getAddressUser(),
              );
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 24,
                  color: Constants.redTheme,
                ),
                Text(
                  'Add New',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Constants.redTheme),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(),
      body: body(),
      bottomNavigationBar: selectedAlamat != null ?
        BottomAppBar(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Constants.redTheme,
                borderRadius: BorderRadius.circular(120),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onSetPrimaryAddress();
                  },
                  child: const Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Set as Primary Address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Constants.colorWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ) : SizedBox(),
    );
  }

  void onAlertDelete(dynamic data) {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        content: Container(
          width: width - 40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure want to delete?',
                style: TextStyle(
                  color: Constants.colorTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your data will not be saved if you delete your “home” address',
                style: TextStyle(
                  color: Constants.colorCaption,
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteAddress(data);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Constants.redTheme,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            // side: const BorderSide(width: 1.0, color: Constants.redTheme),
                          ),
                          backgroundColor: Constants.redThemeUltraLight,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Constants.redTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardData({dynamic data}) {
    double width = MediaQuery.of(context).size.width;
    double widthButton = width * 0.25;
    bool isSelected = selectedAlamat == data;
    
    return Card(
      color: isSelected ? Constants.redThemeUltraLight : Constants.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 18),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAlamat = data;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon/location.png',
                    width: 14,
                    height: 14,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    data["name"] ?? '',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Constants.colorTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  if (data['is_primary']) Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Constants.colorSecondary,
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 8.0,
                        color: Constants.redTheme,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data["address"] ?? '',
                      style: TextStyle(color: Constants.colorText, fontSize: 12.0),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Constants.colorCaption,
                  )
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      onAlertDelete(data);
                    },
                    child: Container(
                      width: widthButton,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                          color: Constants.redTheme,
                          width: 1,
                        )
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            margin: EdgeInsets.only(right: 6),
                            child: Image.asset('assets/images/icon/primary-trash.png'),
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Constants.redTheme,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6,),
                  InkWell(
                    onTap: () {
                      dynamic args = data;
                      Navigator.pushNamed(context, '/addAddressPage', arguments: args)
                          .then(
                        (value) => getAddressUser(),
                      );
                    },
                    child: Container(
                      width: widthButton,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                          color: Constants.redTheme,
                          width: 1,
                        )
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            margin: EdgeInsets.only(right: 6),
                            child: Image.asset('assets/images/icon/primary-pen-edit.png'),
                          ),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Constants.redTheme,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: LoadingFallback(
        isLoading: isLoading,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Constants.colorFormInput,
                  borderRadius: BorderRadius.circular(120),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 16),
                      child: Image.asset('assets/images/icon/search.png'),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: searchText,
                        cursorColor: Constants.redTheme,
                        decoration: const InputDecoration(
                          hintText: 'Search Address',
                          isDense: true,
                          contentPadding: EdgeInsets.all(0),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                        onChanged: (String v) {
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 500), () {
                            dynamic listSearch = dataAddress.where((e) {
                              String nm = e['name'] is String ? e['name'] : '';
                              String name = nm.toLowerCase();
                              String val = v.toLowerCase();
                              if (name == '') return false;
                              return name.contains(val);
                            }).toList();

                            setState(() {
                              // selectedAlamat = null;
                              filterAddress = listSearch;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (searchText.text == '') Expanded(
                child: dataAddress.length > 0 ? ListView(
                  children: [
                    for (int i = 0; i < dataAddress.length; i++)
                      cardData(data: dataAddress[i]),
                  ],
                )
                :
                Container(
                  width: width / 2,
                  height: width / 2,
                  child: Image.asset('assets/images/state/empty-state-img.png'),
                ),
              ),
              if (searchText.text != '') Expanded(
                child: filterAddress.length > 0 ? ListView(
                  children: [
                    for (int i = 0; i < filterAddress.length; i++)
                      cardData(data: filterAddress[i]),
                  ],
                )
                :
                Container(
                  width: width / 2,
                  height: width / 2,
                  child: Image.asset('assets/images/state/empty-state-img.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
