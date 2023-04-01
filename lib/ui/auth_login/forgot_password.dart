import 'package:flutter/material.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/widget/constants.dart';

class ForgotpasswordPage extends StatefulWidget {
  const ForgotpasswordPage({super.key});

  @override
  ForgotpasswordPageState createState() => ForgotpasswordPageState();
}

class ForgotpasswordPageState extends State<ForgotpasswordPage> {
  HttpService http = HttpService();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _isLoading = false;
  final TextEditingController _nohp = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _ipl = TextEditingController();
  String response = '';
  bool showPass = true;
  bool isProses = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _callPostApi() {
    setState(() {
      _isLoading = true;
      isProses = true;
    });

    http.post('gettokenforgot', body: {
      "phone": _nohp.text,
      "ipl": _ipl.text,
      "email": _email.text
    }).then((res) {
      setState(() {
        _isLoading = false;
        isProses = false;
      });

      if (res['success'] == false) {
        // Flushbar(
        //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        //   flushbarPosition: FlushbarPosition.TOP,
        //   borderRadius: 8,
        //   message: res['msg'],
        //   duration: Duration(seconds: 3),
        // )..show(context);
      } else {
        dynamic data = {
          "nohp": _nohp.text,
          "ipl": _ipl.text,
          "email": _email.text
        };

        if (res['msg']['msg'].toString() != "null") {
          // Flushbar(
          //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          //   flushbarPosition: FlushbarPosition.TOP,
          //   borderRadius: 8,
          //   message: res['msg']['msg'],
          //   duration: Duration(seconds: 3),
          // )..show(context);
        }
        Navigator.pushNamed(context, '/konfirmasiforgotPage', arguments: data);
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        isProses = false;
      });
    });
  }

  Widget actionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.065,
              width: MediaQuery.of(context).size.width * 0.02,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Constants.redTheme,
                // boxShadow: [
                //   new BoxShadow(
                //       color: Constants.redTheme,
                //       offset: new Offset(2.0, 2.0),
                //       blurRadius: 0,
                //       spreadRadius: 0)
                // ]
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Constants.redTheme,
                  onTap: () {
                    if (_nohp.text == '') {
                      // Flushbar(
                      //   margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      //   flushbarPosition: FlushbarPosition.TOP,
                      //   borderRadius: 8,
                      //   message: "Please complete the filling form",
                      //   duration: Duration(seconds: 3),
                      // )..show(context);
                    } else {
                      _callPostApi();
                    }
                  },
                  child: const Center(
                    child: Text(
                      "Kirim kode verifikasi",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.black, //change your color here
      ),
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      actions: const <Widget>[],
    );
  }

  Widget header() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: const Text(
              "Lupa kata sandi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            alignment: Alignment.topLeft,
            child: const Text(
              "Mohon masukkan nomor telepon yang terdaftar. Kami akan mengirimkan Anda kode verifikasi.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          child: CustomTextInput(
            hintText: "Nomor telepon",
            placeholder: "Masukan nomor telepon Anda",
            controllerName: _nohp,
            enabled: true,
            isRequired: true,
            onChangeText: () {},
            onEditingComplete: () {},
            onTap: () {},
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: LoadingFallback(
        isLoading: _isLoading,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        header(),
                        form(),
                        actionButton(),
                      ],
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
