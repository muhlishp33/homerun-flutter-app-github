import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/form/custom_form_input.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TambahAkunPage extends StatefulWidget {
  const TambahAkunPage(this.data, {Key? key}) : super(key: key);

  final dynamic data;
  @override
  TambahAkunPageState createState() => TambahAkunPageState();
}

class TambahAkunPageState extends State<TambahAkunPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();
  final LocalStorage storage = LocalStorage('homerunapp');
  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController();
  final TextEditingController _ipl = TextEditingController();

  String response = '';
  // StreamController<ErrorAnimationType> errorController;

  final formKey = GlobalKey<FormState>();

  bool showPass = true;
  bool showPass2 = true;
  bool hasError = false;
  String currentText = "";
  bool isProses = false;
  String? tokenFcm;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void flushbarGagal(BuildContext context, msg) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      message: msg,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.red[300],
      ),
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  addIpl() async {
    await http.post('ipladd', body: {"ipl": _ipl.text}).then((res) {
      setState(() {
        _isLoading = false;
      });

      if (res['success']) {
        Navigator.of(context).pushReplacementNamed("/selesaitambahPage");
      } else {
        Alert(
          closeIcon: const Icon(Icons.close_outlined),
          style: const AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            isCloseButton: true,
          ),
          context: context,
          title: "Oops",
          content: Column(
            children: [
              Column(
                children: [
                  const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                  Text(
                    res['msg'],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/customerCarePage');
              },
              color: Colors.red,
              child: const Text(
                "Resident Care",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ).show();
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });

      Alert(
        closeIcon: const Icon(Icons.close_outlined),
        style: const AlertStyle(
          titleStyle: TextStyle(fontWeight: FontWeight.bold),
          isCloseButton: true,
        ),
        context: context,
        title: "Oops",
        content: Column(
          children: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/customerCarePage');
            },
            color: Colors.red,
            child: const Text(
              "Resident Care",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ).show();
    });
  }

  void _callPostApi() {
    setState(() {
      _isLoading = true;
    });

    addIpl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Tambah Akun', style: Constants.textAppBar3),
        elevation: 1,
        centerTitle: true,
      ),
      body: LoadingFallback(
        isLoading: _isLoading,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                FormInput(
                  controller: _ipl,
                  labelText: "IPL",
                  isError: response != '' ? true : false,
                  errorText: response != '' ? response : '',
                  outLineBorderForm: OutlineBorderFrom.all,
                  hintText: 'IPL',
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffed1c24),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: const Color(0xffed1c24),
                      onTap: () {
                        if (_ipl.text == '') {
                          Flushbar(
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            flushbarPosition: FlushbarPosition.TOP,
                            borderRadius: BorderRadius.circular(8),
                            message: "Silakan lengkapi formulir isian",
                            duration: const Duration(seconds: 3),
                          ).show(context);
                        } else {
                          _callPostApi();
                        }
                      },
                      child: const Center(
                        child: Text(
                          "Lanjut",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
