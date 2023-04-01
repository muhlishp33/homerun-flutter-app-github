import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/widget/index.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage(this.data, {super.key});
  final dynamic data;
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  bool showPass = true;
  bool showPass2 = true;
  bool isProses = false;
  TextEditingController newPassword = TextEditingController();
  TextEditingController repeatPassword = TextEditingController();
  dynamic dataProfile;
  @override
  void initState() {
    if (widget.data != null && widget.data["data"] != null) {
      setState(() {
        dataProfile = widget.data["data"];
      });
    }
    super.initState();
  }

  postData() {
    var body = {
      "nama": dataProfile["nama"],
      "phone": dataProfile["nohp"],
      "pass": newPassword.text,
      "alamat": dataProfile["alamat"],
      "ipl": dataProfile["ipl"],
      "cluster": dataProfile["cluster"],
      "project": dataProfile["project"],
      "email": dataProfile["email"],
      "gender": dataProfile["gender"].toString(),
      "dob": dataProfile["dob"],
      "hobi": dataProfile["hobi"],
    };
    // log("body = $body");
    http.post('gettokenedit', body: body).then((res) {
      // log("res = $res");
      if (res['success'] == false) {
        showAppNotification(
            context: context,
            title: 'Gagal',
            desc: res["msg"],
            onSubmit: () {});
      } else {
        Navigator.of(context)
            .pushReplacementNamed("/konfirmasiEditPage", arguments: body);
      }
    }).catchError((e) {
      setState(() {
        isProses = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List controllers = [newPassword, repeatPassword];
    List text = ["Kata sandi baru", "Konfirmasi kata sandi"];

    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Change Password', style: Constants.textAppBar3),
        elevation: 1,
        centerTitle: false,
      ),
      resizeToAvoidBottomInset: true,
      body: LoadingFallback(
        isLoading: isProses,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < controllers.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: CustomTextInput(
                            hintText: text[i],
                            controllerName: controllers[i],
                            enabled: true,
                            isRequired: true,
                            isObsecure: true,
                            onTap: () {},
                            onChangeText: () {},
                            onEditingComplete: () {},
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (newPassword.text == "" ||
                              repeatPassword.text == "") {
                            showAppNotification(
                                context: context,
                                title: 'Gagal',
                                desc: "Please complete the filling form",
                                onSubmit: () {});
                          } else if (newPassword.text != repeatPassword.text) {
                            showAppNotification(
                                context: context,
                                title: 'Gagal',
                                desc: "Password Missmatch",
                                onSubmit: () {});
                          } else {
                            postData();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Constants.redTheme,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
