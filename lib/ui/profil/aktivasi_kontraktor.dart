import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:appid/component/form/custom_form_input.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';

class AktivasiKontraktor extends StatefulWidget {
  const AktivasiKontraktor({Key? key}) : super(key: key);

  @override
  State<AktivasiKontraktor> createState() => _AktivasiKontraktorState();
}

class _AktivasiKontraktorState extends State<AktivasiKontraktor> {
  HttpService http = HttpService();

  final TextEditingController _kodeController = TextEditingController();

  bool isProses = false;
  bool showInputReferal = false;
  bool showInputPIC = false;

  bool isLoading = true;

  List _listClient = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listClient();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showCustomDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/icon/new_design/close-circle.png',
                  width: 100,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unit sudah terdaftar di dalam list Client Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 44,
                    width: 154,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  activateContractor() {
    dynamic body = {
      'contractor_code': _kodeController.text,
    };
    http.post('aktivasi-contractor', body: body).then(
      (res) {
        isLoading = true;
        setState(() {});

        // log('AKTIVASIIIII ======== $res');
        if (res['success']) {
          Helper(context: context).flushbar(msg: res['msg'], success: true);
          _kodeController.text = '';
          listClient();
          setState(() {});
        } else {
          Helper(context: context).flushbar(msg: res['msg']);
          setState(() {});
        }
        Future.delayed(const Duration(milliseconds: 1200), () {
          isLoading = false;
          setState(() {});
        });
      },
    ).catchError((error) {});
  }

  listClient() {
    http.post('list-contractor-client').then(
      (res) {
        if (res['success']) {
          _listClient.clear();
          _listClient = res['data'];
          // log('list-contractor-client ===== $res');
          // for (var item in res['data']) {
          //   log('_listClient ===== $item');
          // }
        } else {}
        isLoading = false;
        setState(() {});
      },
    ).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return LoadingFallback(
      isLoading: isLoading,
      loadingLabel: 'Memuat',
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     for (var item in _listClient) log(item.toString());
        //   },
        // ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text('Aktivasi Kontraktor', style: Constants.textAppBar3),
          elevation: 1,
          centerTitle: true,
        ),
        bottomNavigationBar: _navButton(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Center(
                    child: Image(
                        image:
                            const AssetImage('assets/logo/onesmile-final.jpg'),
                        width: MediaQuery.of(context).size.width * 0.50),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  const Center(
                      child: Text(
                    'Kode Kontraktor',
                    style: TextStyle(
                      color: Constants.redTheme,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  FormInput(
                      controller: _kodeController,
                      isReadOnly: false,
                      keyboardType: TextInputType.text,
                      outLineBorderForm: OutlineBorderFrom.all,
                      lengthChar: 10,
                      hintText: 'Masukan Kode Kontraktor'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildListClient(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    String text = 'Aktivasi',
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
      child: ElevatedButton(
        onPressed: () {
          activateContractor();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: Constants.redTheme,
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildListClient() {
    if (_listClient.isEmpty) return Container();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semua Client',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < _listClient.length; i++)
                _buildListTile(
                  index: i,
                  data: _listClient[i],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({int? index, dynamic data}) {
    String nama = data['name'];
    String phone = data['phone'];
    if (data['parent_member_name'] != '') {
      nama = data['parent_member_name'];
      phone = data['parent_member_phone'];
    }

    return SizedBox(
      height: 55,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          phone,
          style: const TextStyle(
            color: Color(0xff828382),
          ),
        ),
      ),
    );
  }
}
