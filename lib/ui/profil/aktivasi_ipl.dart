import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:appid/component/form/custom_form_input.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AktivasiiplPage extends StatefulWidget {
  const AktivasiiplPage({Key? key}) : super(key: key);
  @override
  AktivasiiplPageState createState() => AktivasiiplPageState();
}

class AktivasiiplPageState extends State<AktivasiiplPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  final TextEditingController _numberCode = TextEditingController();
  final TextEditingController _referralCode = TextEditingController();
  final TextEditingController _clusterCode = TextEditingController();

  bool isProses = false;
  bool showInputReferal = false;
  bool showInputPIC = false;
  LocalStorage storage = LocalStorage('homerunapp');

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
      isProses = true;
    });

    Map body = {
      "ipl": _numberCode.text,
      "referral_code": _referralCode.text,
      "is_tenant": showInputPIC && _clusterCode.text != '',
      "cluster_code": _clusterCode.text,
      'referrer': storage.getItem("referrer"),
    };

    http.post('aktivasiipl', body: body).then((res) {
      setState(() {
        isProses = false;
      });

      if (res['success'] == false) {
        Alert(
          closeIcon: const Icon(Icons.close_outlined),
          style: const AlertStyle(
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            isCloseButton: true,
            //isOverlayTapDismiss: false,
            //isButtonVisible:false,

            //buttonAreaPadding :EdgeInsets.all(10)
          ),
          context: context,
          //type: AlertType.,
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
                Navigator.of(context).pushNamed('/customerCarePage');
              },
              color: Constants.redTheme,
              child: const Text(
                "Customer Care",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ).show();
      } else {
        // Timer(Duration(seconds: 3), () {
        //   // Navigator.pushReplacementNamed(context, '/loginPage');
        //   Navigator.of(context).pushNamed('/suksesAktivasiPage');
        // });

        Navigator.of(context)
            .pushNamed('/suksesAktivasiPage', arguments: res['msg']);
      }
    }).catchError((e) {
      setState(() {
        isProses = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // leading: new IconButton(
        //   icon: new Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Aktivasi IPL', style: Constants.textAppBar3),
        elevation: 1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                        child: Image(
                            image: const AssetImage(
                                'assets/logo/onesmile-final.jpg'),
                            width: MediaQuery.of(context).size.width * 0.50)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    const Center(
                        child: Text(
                      'Nomor IPL',
                      style: TextStyle(
                        color: Constants.redTheme,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    FormInput(
                        controller: _numberCode,
                        isReadOnly: isProses,
                        keyboardType: TextInputType.text,
                        outLineBorderForm: OutlineBorderFrom.all,
                        lengthChar: 10,
                        hintText: 'Masukan Nomor IPL'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showInputReferal = true;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                            children: [
                              const TextSpan(text: 'Kamu punya kode referal?'),
                              if (showInputReferal == false)
                                TextSpan(
                                    text: ' Klik',
                                    style: TextStyle(
                                      color: Constants.blue,
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (showInputReferal)
                      FormInput(
                          controller: _referralCode,
                          isReadOnly: isProses,
                          keyboardType: TextInputType.text,
                          outLineBorderForm: OutlineBorderFrom.all,
                          lengthChar: 10,
                          hintText: 'Masukan Kode Referal'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showInputPIC = true;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                            children: [
                              const TextSpan(text: 'Apakah Kamu penyewa?'),
                              if (showInputPIC == false)
                                TextSpan(
                                    text: ' Klik',
                                    style: TextStyle(
                                      color: Constants.blue,
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (showInputPIC)
                      FormInput(
                          controller: _clusterCode,
                          isReadOnly: isProses,
                          keyboardType: TextInputType.text,
                          outLineBorderForm: OutlineBorderFrom.all,
                          lengthChar: 10,
                          hintText: 'Masukan Kode Pengurus'),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (isProses == false) {
                  if (_numberCode.text == '') {
                    Helper(context: context).flushbar(
                        msg: 'Silakan masukan Nomor IPL', success: false);
                  } else {
                    _callPostApi();
                  }
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: Constants.redTheme,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: isProses == false
                      ? const Text(
                          'Aktivasi',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      : const CircularProgressIndicator(
                          backgroundColor: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
