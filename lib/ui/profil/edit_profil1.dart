import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:appid/component/form/custom_date_picker.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:appid/component/HttpService.dart';
import 'package:appid/component/form/custom_select_map.dart';
// import 'package:appid/component/image_picker_handler.dart';
// import 'package:appid/component/Constants.dart';
import 'package:appid/component/form/custom_text_input.dart';
// import 'package:appid/component/form/custom_date_picker.dart';
import 'package:appid/component/form/custom_dropdown_box.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:intl/intl.dart';

List gender = [
    {"value": 1, "label": "Male"},
    {"value": 2, "label": "Female"},
];

class EditProfilPage extends StatefulWidget {
  const EditProfilPage(this.data, {Key? key}) : super(key: key);

  final dynamic data;

  @override
  EditProfilPageState createState() => EditProfilPageState();
}

class EditProfilPageState extends State<EditProfilPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  final TextEditingController _nama = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nohp = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  DateTime selectDatePicker = DateTime(1930);
  String photo = '';
  File? _image;
  bool isLoading = false;

  AnimationController? _controller;
  int _mySelection = 0;

  List provincies = [];
  List cities = [];
  List suburbs = [];
  List areas = [];

  dynamic selectedProvince;
  dynamic selectedCity;
  dynamic selectedSuburb;
  dynamic selectedArea;
  
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    setData();
    super.initState();
  }

  bool isValidDateTime(str) {
    if (str is !String) return false;
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void setData() async {
    dynamic profile = await getInstanceJson('profile');

    // log('profile $profile');

    _nama.text = profile['fullname'];
    _email.text = profile['email'];
    _nohp.text = profile['phone'];
    _dob.text = profile['dob'];

    if (profile['dob'] is String && isValidDateTime(profile['dob'])) {
      DateTime parseEndDate = DateTime.parse(profile['dob']);
      selectDatePicker = parseEndDate;
    }

    if (profile['gender'] == 'MALE') {
      _mySelection = 1;
    } else if (profile['gender'] == 'FEMALE') {
      _mySelection = 2;
    }

    setState(() {
      _mySelection = _mySelection;
      selectDatePicker = selectDatePicker;
    });
  }

  onSubmit() {
    if (_nama.text == '' ||
        _nohp.text == '' ||
        _email.text == '') {
      Helper(context: context).flushbar(msg: 'Please filled the form', success: false);
      return;
    } else if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_email.text) ==
        false) {
      Helper(context: context).flushbar(msg: 'Wrong email format', success: false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    var body = {
      "fullname": _nama.text,
      "phone": _nohp.text,
      "email": _email.text,
      "gender": _mySelection == 1 ? 'MALE' : _mySelection == 2 ? 'FEMALE' : '',
      "dob": _dob.text,
    };

    http.post('profile/edit', body: body).then((res) {
      // log('res profile/edit $res');

      if (res['success'] == true) {
        showAppNotification(
          context: context,
          title: 'Success',
          desc: res["msg"],
          onSubmit: () {
            Navigator.of(context).pop();
          }
        );
      } else {
        Helper(context: context).flushbar(msg: res['msg'], success: false);
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((err) {
      log('err profile/edit $err');

      Helper(context: context).flushbar(msg: 'Terjadi kesalahan', success: false);

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  final List _text = [
    "Full Name",
    "Gender",
    "Phone Number",
    "Email",
    "Date of Birth",
  ];

  final List _placeholders = [
    "Enter full name",
    "Select",
    "Enter phone number",
    "Enter email",
    "Select",
  ];

  Widget generateForm() {
    return Column(
      children: [
        for (int i = 0; i < _text.length; i++) switchForm(i: i),
      ],
    );
  }

  Widget switchForm({i}) {
    List controllers = [
      _nama,
      _mySelection,
      _nohp,
      _email,
      _dob,
    ];
    
    switch (i) {
      case 4:
        return AppointmentDatePicker(
          initialDate: selectDatePicker,
          firstDate: DateTime(1930),
          lastDate: DateTime.now(),
          controller: _dob,
          onTap: (DateTime picked) {
            setState(() {
              selectDatePicker = picked;
              _dob.text = DateFormat('yyyy-MM-dd').format(picked.toLocal());
            });
          },
          placeholder: _text[i],
        );
      case 1:
        return CustomDropdownBox(
          data: gender,
          value: _mySelection,
          keyValue: 'value',
          keyLabel: 'label',
          placeholder: _text[i],
          onChanged: (newVal) {
            setState(() {
              _mySelection = newVal;
            });
          },
        );
      default:
        return Container(
          // margin: const EdgeInsets.symmetric(vertical: 5),
          child: CustomTextInput(
            hintText: _text[i],
            placeholder: _placeholders[i],
            controllerName: controllers[i],
            enabled: true,
            isRequired: true,
            onChangeText: () {},
            onEditingComplete: () {},
            onTap: () {},
          ),
        );
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
            title: Text('Edit Profile', style: Constants.textAppBar3),
            actions: const <Widget>[]),
        backgroundColor: Colors.white,
        body: LoadingFallback(
          isLoading: isLoading,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        // GestureDetector(
                        //   onTap: () {
                        //   },
                        //   child: Container(
                        //     margin: const EdgeInsets.only(bottom: 20),
                        //     child: Center(
                        //       child: (photo != '')
                        //           ? Stack(
                        //               children: [
                        //                 CircleAvatar(
                        //                   backgroundImage: NetworkImage(photo),
                        //                   radius: 50,
                        //                   child: const Text('',
                        //                       style: TextStyle(
                        //                         color: Colors.white,
                        //                         fontSize: 20,
                        //                       ),
                        //                       textAlign: TextAlign.center),
                        //                 ),
                        //                 CircleAvatar(
                        //                   backgroundColor:
                        //                       Colors.black.withOpacity(0.2),
                        //                   radius: 50,
                        //                 ),
                        //                 Positioned(
                        //                   bottom: 35,
                        //                   right: 30,
                        //                   child: Transform.rotate(
                        //                     angle: 4.7,
                        //                     child: Container(
                        //                       padding: const EdgeInsets.symmetric(
                        //                           vertical: 2.5, horizontal: 2.5),
                        //                       margin: const EdgeInsets.only(
                        //                           right: 0, bottom: 0),
                        //                       decoration: BoxDecoration(
                        //                           borderRadius:
                        //                               BorderRadius.circular(50)),
                        //                       child: Container(
                        //                         padding:
                        //                             const EdgeInsets.fromLTRB(
                        //                                 2.5, 3, 14, 6),
                        //                         child: Image.asset(
                        //                           'assets/images/icon/new_design/edit-new.png',
                        //                           height: 25,
                        //                           width: 25,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             )
                        //           : (_image == null
                        //               ? CircleAvatar(
                        //                   backgroundColor: Colors.grey[200],
                        //                   radius: 50,
                        //                   child: const FaIcon(
                        //                       FontAwesomeIcons.userLarge,
                        //                       color: Colors.red),
                        //                 )
                        //               : Container(
                        //                   height: 100.0,
                        //                   width: 100.0,
                        //                   decoration: BoxDecoration(
                        //                     color: Colors.white,
                        //                     image: DecorationImage(
                        //                       image:
                        //                           FileImage(File(_image!.path)),
                        //                       fit: BoxFit.cover,
                        //                     ),
                        //                     borderRadius: const BorderRadius.all(
                        //                         Radius.circular(80.0)),
                        //                   ),
                        //                 )),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  generateForm(),
                ],
              ),
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
                    onSubmit();
                  },
                  child: const Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Save Profile',
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
      ),
    );
  }
}
