import 'dart:developer';

import 'package:appid/helper/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/form/custom_dropdown_box.dart';
import 'package:appid/component/form/custom_select_map.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/app_notification.dart';
import 'package:appid/component/widget/constants.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage(this.data, {Key? key}) : super(key: key);

  final dynamic data;

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');

  bool _isEditPage = false;
  bool _isLoading = false;
  AnimationController? _controller;
  final TextEditingController _addressName = TextEditingController();
  final TextEditingController _addressDetail = TextEditingController();
  final FocusNode _addressNameFocus = FocusNode();
  final FocusNode _addressDetailFocus = FocusNode();

  List provincies = [];
  List cities = [];
  List suburbs = [];
  List areas = [];

  dynamic selectedProvince = {};
  dynamic selectedCity = {};
  dynamic selectedSuburb = {};
  dynamic selectedArea = {};

  dynamic mapData;
  dynamic coords = {
    'latitude': '0',
    'longitude': '0',
  };

  @override
  void initState() {
    super.initState();

    dynamic setCoords = {
      'latitude': _isEditPage && widget.data['latitude'] != null ? widget.data['latitude'] : '0',
      'longitude': _isEditPage && widget.data['longitude'] != null ? widget.data['longitude'] : '0',
    };

    setState(() {
      _isEditPage = widget.data['id'] != null;
      _addressName.text = _isEditPage ? widget.data['name'] : '';
      _addressDetail.text = _isEditPage ? widget.data['address'] : '';
      coords = setCoords;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log('widget ${widget.data}');

    return Scaffold(
      key: _key,
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(_isEditPage ? 'Edit Address' : 'Add New Address', style: Constants.textAppBar3),
          titleSpacing: 0,
          actions: const <Widget>[]),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              generateForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
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
                    postData();
                  },
                  child: const Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Save Address',
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
        ),
      )
    );
  }

  postData() {
    String errorMsg = '';
    if (_addressName.text == '') {
      errorMsg = 'Address Name must be filled';
    }
    if (_addressDetail.text == '') {
      errorMsg = 'Detail Address must be filled';
    }
    if (errorMsg != '') {
      Helper(context: context).flushbar(msg: errorMsg, success: false);
      return;
    }

    String endpoint = _isEditPage ? 'address/edit' : 'address/add';

    dynamic body = {
      "name": _addressName.text,
      "address": _addressDetail.text,
    };

    if (_isEditPage) {
      body = {
        "id": widget.data['id'],
        "name": _addressName.text,
        "address": _addressDetail.text,
      };
    }

    if (mapData != null &&
        mapData['geometry'] != null &&
        mapData['geometry']['location'] != null) {
      body["longitude"] = mapData['geometry']['location']['lng'].toString();
      body["latitude"] = mapData['geometry']['location']['lat'].toString();
    }

    // log('body $endpoint $body');

    http.post(endpoint, body: body).then((res) {
      // log('res $endpoint $res');

      if (res['success'] == true) {
        showAppNotification(
          context: context,
          title: 'Success',
          desc: res["msg"],
          onSubmit: () {
            Navigator.pop(context);
          });
      } else {
        Helper(context: context).flushbar(msg: res['msg'], success: false);
      }
    })
    .catchError((err) {
      log('err $endpoint $err');

      Helper(context: context).flushbar(msg: 'Terjadi kesalahan', success: false);
    });
  }

  Widget generateForm() {
    // log('mapData $mapData');

    String lblAddress = 'Please Pin Address';
    if (coords['latitude'] != '0' && coords['longitude'] != '0') {
      lblAddress = 'Pinned';
    }
    if (mapData != null && mapData['vicinity'] != null) {
      lblAddress = mapData['vicinity'];
    }

    return Column(
      children: [
        if (!kIsWeb) Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CustomSelectMap(
            isHasHint: true,
            hintText: "Pin Point Location",
            fullAddress: lblAddress,
            enabled: true,
            isRequired: true,
            mapData: mapData,
            onMapDataChanged: (val) {
              // log('message ${val['name']}');

              setState(() {
                mapData = val;
                coords = {
                  'latitude': val['geometry']['location']['lng'],
                  'longitude': val['geometry']['location']['lat'],
                };
                _addressDetail.text = val['name'] + ', ' + val['vicinity'];
              });
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CustomTextInput(
            hintText: "Address Name",
            placeholder: "Input address name",
            controllerName: _addressName,
            enabled: true,
            isRequired: true,
            onChangeText: () {},
            onTap: () {},
            onEditingComplete: () {
              _addressDetailFocus.nextFocus();
            },
            textInputAction: TextInputAction.next,
            focusNode: _addressNameFocus
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: CustomTextInput(
            hintText: "Detail Address",
            placeholder: "Input detail address",
            controllerName: _addressDetail,
            enabled: true,
            isRequired: true,
            onChangeText: () {},
            onTap: () {},
            onEditingComplete: () {
              postData();
            },
            minLines: 4,
            maxLines: 6,
            textInputAction: TextInputAction.done,
            focusNode: _addressDetailFocus
          ),
        ),
        // Container(
        //   // margin: EdgeInsets.symmetric(vertical: 5),
        //   child: selectProvince(item: provincies),
        // ),
        // Container(
        //   // margin: EdgeInsets.symmetric(vertical: 5),
        //   child: selectCity(item: cities),
        // ),
        // Container(
        //   // margin: EdgeInsets.symmetric(vertical: 5),
        //   child: selectSuburb(item: suburbs),
        // ),
        // Container(
        //   margin: const EdgeInsets.only(bottom: 15),
        //   child: selectArea(item: areas),
        // ),
      ],
    );
  }
}
