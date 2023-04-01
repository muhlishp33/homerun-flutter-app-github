import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/appointments/func_appointment.dart';
import 'package:appid/component/appointments/inkwell_appointment.dart';
import 'package:appid/component/appointments/modal_resident_service.dart';
import 'package:appid/component/appointments/modal_service_appointment.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:appid/component/widget/app_notification.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCareMenu extends StatefulWidget {
  const CustomerCareMenu(
      {super.key,
      required this.isResident,
      required this.menu,
      this.profile,
      required this.listService,
      required this.useRequisiteForm,
      this.resultRequisiteForm});
  final bool isResident;
  final List<dynamic> menu;
  final dynamic profile;
  final List listService;
  final bool useRequisiteForm;
  final dynamic resultRequisiteForm;
  @override
  State<CustomerCareMenu> createState() => _CustomerCareMenuState();
}

class _CustomerCareMenuState extends State<CustomerCareMenu> {
  HttpService http = HttpService();
  //Layanan Warga
  String _endpointPrefix = '';
  String navPath = '';
  bool isDocumentRequest = false;
  String title = '';
  String subTitle = '';
  String imageUrl = '';
  bool show = true;
  bool isActive = true; // is_active or success status
  String message = '';
  dynamic popupService;
  List listService = [];
  List listAppointment = [];
  dynamic resultRequisiteForm;
  bool useRequisiteForm = false;
  String appointmentType = '';
  dynamic profile;
  bool clusterAdmin = false;
  int startIndex = 0;
  List listData = [];
  dynamic homeData;
  String clusterComplainType = 'cluster-complain';
  String residentBillingType = 'resident-billing';
  bool _isLoading = true;
  Future getHomeData = getInstanceString('homeData');

  Widget cardClusterAppointment(data) {
    return InkWellAppointment(
        appointmentType: data['type'], child: cardClusterNew(data));
  }

  @override
  void initState() {
    getSampleAppointment();
    getProfile();
    fetchAsync();
    super.initState();
  }

  void fetchAsync() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProfile() {
    http.post('profile').then((res) async {
      if (res.toString() != null) {
        if (res['success'] == true) {
          setState(() {
            profile = res['data'];
          });
        }
      }
    });
    getHomeData.then((value) {
      if (value != null) {
        setState(() {
          homeData = json.decode(value);
        });
      }
    });
  }

  Widget cardClusterNew(data) {
    final double width = MediaQuery.of(context).size.width;
    final double heightContent = width / 3;
    final double widthContent = width / 2;
    var type = data['type'];

    return InkWell(
      onTap: () {
        if (data["category"] != "appointment") {
          Helper(context: context).pushToLogger(body: {
            "event_name": "customer_care",
            "event_values": {
              "id": 0,
              "type": "customer_care_menu",
              "title": data['title'] ?? "",
            }
          });
          Navigator.pushNamed(
            context,
            data['url'],
          );
        } else {
          if (data["type"] == "hand-over" && data["id"] == null) {
            // Update handover action
            openHandoverSheet(context: context);
          } else {
            Helper(context: context).pushToLogger(body: {
              "event_name": "customer_care",
              "event_values": {
                "id": 0,
                "type": "customer_care_menu",
                "title": data['title'] ?? "",
              }
            });
            setState(() {
              appointmentType = data['type'];
              subTitle = data['subTitle'];
            });

            _onTapAppoinment(data: data);
          }
        }
      },
      child: SizedBox(
        height: heightContent,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            height: heightContent,
            child: SizedBox(
              height: heightContent,
              child: Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Opacity(
                        opacity: 1,
                        child: data['imageUrl'] != ''
                            ? FadeInImage.assetNetwork(
                                image: data['imageUrl'],
                                height: heightContent,
                                width: widthContent,
                                fit: BoxFit.cover,
                                placeholder: 'assets/images/loader.gif',
                                placeholderErrorBuilder:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              )
                            : Image.asset(
                                data['imageAsset'].toString(),
                                height: heightContent,
                                width: widthContent,
                                fit: BoxFit.cover,
                              ),
                      )),
                  Container(
                    height: heightContent,
                    width: widthContent,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC000000),
                          Color(0x00000000),
                          Color(0x00000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: widthContent,
                    height: heightContent,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          data['title'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data['desc'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//Start Layanan Warga
  Future getAppointmentStatus() async {
    return http.post('${_endpointPrefix}appointment-status').then((res) {
      bool useForm = false;
      dynamic resultForm;
      // log('$_endpointPrefix service1 $res');

      if (res['success'] == true) {
        if (isDocumentRequest) {
          // res['data'].forEach((k,v) {
          //   log('$k ---> $v');
          // });
        }

        useForm = res['data']['additional_form']['use'] == true;
        resultForm = res['data']['additional_form'];
      }

      setState(() {
        useRequisiteForm = useForm;
        resultRequisiteForm = resultForm;

        // resultStatus = res['data'];
        title = res['data']['name'];
        subTitle = subTitle;
        imageUrl = res['data']['image_url'];
        show = res['data']['show'];
        isActive = res['success'];
        message = res['msg'];
        popupService = res['data']['popup_service'];
        _isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  getSampleAppointment() async {
    return http.post('get-service-appointment').then((res) {
      // log('/get-service-appointment service2 $res');

      if (res['success'] == true) {
        setState(() {
          listAppointment = res['data'];
        });
        for (int i = 0; i < listAppointment.length; i++) {
          // log(listAppointment[i]);
        }
      }
    }).catchError((err) {
      // log('get-service-appointment serviceError $err');
    });
  }

  newAppointmentAction({dynamic data}) {
    dynamic tmp = listAppointment.firstWhere((ap) => ap['id'] == data['id']);
    // log("tmp = $tmp");
    if (tmp != null) {
      tmp["appointmentType"] = "appointment";
      tmp["menuData"] = data;
      Helper(context: context).pushToLogger(body: {
        "event_name": "customer_care",
        "event_values": {
          "id": 0,
          "type": "customer_care_menu",
          "title": data['title'] ?? "",
        }
      });
      return Navigator.of(context)
          .pushNamed("/masterAppointmentCreatePage", arguments: tmp);
    }
  }

  Future getServiceAppointment() async {
    return http.post('${_endpointPrefix}get-service-appointment').then((res) {
      // log('$_endpointPrefix service2 $res');

      if (res['success'] == true) {
        setState(() {
          listService = res['data'];
        });
      }
    }).catchError((err) {
      // log('$_endpointPrefix serviceError $err');
    });
  }

  Future<void> _onTapAppoinment({String type = '', dynamic data}) async {
    // log("type = $type");
    setState(() {
      _endpointPrefix = getAppointmentEndpointPrefix(appointmentType);
      navPath = getAppointmentCreatePagePath(appointmentType);
    });
    // log('end poin : $_endpointPrefix');
    // log('nav path : $navPath');

    await getAppointmentStatus();
    await getServiceAppointment();
    (data != null && data["id"] != null)
        ? newAppointmentAction(data: data)
        : actionTap();
  }

  void actionTap() {
    // const String eventName = "drive-thru";
    // final Map<String, dynamic> eventValues = {
    //   "type": appointmentType,
    // };

    if (isActive) {
      if (navPath != '') {
        if (popupService['need_download'] == true) {
          onTapNeedDownload();
        } else {
          if (popupService != null && popupService['use'] == true) {
            onTapShowListService();
          } else {
            onTapNavigateTo(appointmentType);
          }
        }
      } else {
        showModal();
      }
    } else {
      showModal();
    }
  }

  void onTapNeedDownload() {
    String type = popupService['type'];
    List data = type == 'data' ? popupService['data'] : listService;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: TargetPlatform.iOS == defaultTargetPlatform
                    ? MediaQuery.of(context).viewPadding.bottom
                    : 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // panel
                SizedBox(
                  height: 36,
                  child: Center(
                    child: Container(
                      height: 3,
                      width: MediaQuery.of(context).size.width / 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.5),
                        color: Constants.colorBorder,
                      ),
                    ),
                  ),
                ),
                // end panel

                // listing
                Container(
                  // height: MediaQuery.of(context).size.height * 0.75,
                  padding:  EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0.0),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int i) {
                      dynamic item = data[i];

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          title: Text(item['caption'],
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              )),
                          subtitle: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Text(item['description'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFA1A4B2),
                                    )),
                              ),
                            ],
                          ),
                          trailing: item['url'] != ''
                              ? InkWell(
                                  onTap: () async {
                                    String filename =
                                        item['url'].split('/').last +
                                            '-' +
                                            DateTime.now().toString();

                                    final directory = TargetPlatform.android == defaultTargetPlatform
                                        ? await getExternalStorageDirectory()
                                        : await getApplicationDocumentsDirectory();

                                    String result = await downloadFile(
                                      url: item['url'],
                                      fileName: filename,
                                      dir: directory!.path,
                                    );

                                    // log('result $result');

                                    showAppNotification(
                                        context: context,
                                        title: result != '' ? 'Info' : 'Gagal',
                                        desc: result != ''
                                            ? 'Berhasil mengunduh dokumen'
                                            : 'Gagal mengunduh dokumen');
                                  },
                                  child: const Icon(
                                    Icons.file_download,
                                    color: Constants.green,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                // end listing

                // footer
                Container(
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Sudah mengunduh dan mengisi dokumen? ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          if (popupService != null &&
                              popupService['use'] == true) {
                            onTapShowListService();
                          } else {
                            onTapNavigateTo(appointmentType);
                          }
                        },
                        child: const Text(
                          'Lanjukan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // end footer
              ],
            ),
          );
        });
  }

  Future<String> downloadFile<T>(
      {String url = '', String fileName = '', String dir = ''}) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        // filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      // filePath = 'Can not fetch url';
    }

    return filePath;
  }

  void onTapShowResidentBillService({required BuildContext context}) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (context) {
          return ModalResidentService(
            ipl: homeData["ipl"],
            profile: profile,
          );
        });
  }

  void onTapShowListService() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (context) {
          return ModalServiceAppointment(
            data: listService,
            onTapString: navPath,
            appointmentType: appointmentType,
          );
        });
  }

  void onTapNavigateTo(String appointmentType) {
    if (listService.isEmpty) {
      return showModal();
    }

    if (useRequisiteForm) {
      final data = {
        ...listService[0],
        'requisite_form': resultRequisiteForm,
        'appointmentType': appointmentType,
      };

      Navigator.of(context).pushNamed(
        '/appointmentRequisiteFormPage',
        arguments: data,
      );
      return;
    }

    Navigator.of(context).pushNamed(navPath, arguments: {
      ...listService[0],
      'appointmentType': appointmentType,
    });
  }

  void showModal() {
    showAppNotification(
      context: context,
      title: 'Info',
      desc: message,
    );
  }

  dynamic handoverData;
  getDetailTiket({required StateSetter updateState}) {
    updateState(() {
      isDisabledButton = true;
    });
    // log(kodeUnikHandover.text);
    dynamic body = {
      "appointment_id": kodeUnikHandover.text,
      "is_claim_ticket": true,
    };
    // log("handover body = $body");
    http.post('hand-over-zero/get-appointment', body: body).then((res) async {
      // log("detail handover ======================> $res");
      if (res.toString() != '') {
        if (res['success'] == true) {
          setState(() {
            handoverData = res['data'];
          });
          // log("handoverData ========================> $handoverData");
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dataPemilikPage',
              arguments: handoverData);
        } else {
          Navigator.pop(context);
          showAppNotification(
              context: context, title: 'Gagal', desc: res['msg']);
        }
      }
      updateState(() {
        isDisabledButton = false;
      });
    }).catchError((e) {
      updateState(() {
        isDisabledButton = false;
      });
      showAppNotification(
          context: context, title: 'Gagal', desc: "Terjadi kesalahan!");
    });
  }

  TextEditingController kodeUnikHandover = TextEditingController();
  bool isDisabledButton = true;

  Future<void> updated(StateSetter updateState) async {
    setState(() {});
    updateState(() {
      isDisabledButton = kodeUnikHandover.text.trim().isEmpty ? true : false;
    });
  }

  openHandoverSheet({context}) async {
    showModalBottomSheet(
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return SafeArea(
              child: Container(
                padding:  EdgeInsets.only(
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kode Unik",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              "Masukkan Kode Unik yang Anda terima melalui Surat Undangan Serah Terima.",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: const Text(
                              "Kode Unik",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextInput(
                      isHasHint: false,
                      keyboardType: TextInputType.number,
                      placeholder: "Masukkan kode Unik",
                      controllerName: kodeUnikHandover,
                      enabled: true,
                      isRequired: true,
                      onEditingComplete: () {},
                      onTap: () {},
                      onChangeText: () {
                        updated(state);
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: InkWell(
                        onTap: () {
                          if (!isDisabledButton) {
                            getDetailTiket(updateState: state);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDisabledButton
                                ? const Color(0xFFB2B2B2)
                                : Constants.redTheme,
                          ),
                          child: const Text(
                            "Lanjut",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget oldBody() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: widget.menu.length,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 8,
        // crossAxisSpacing: 3,
      ),
      itemBuilder: (context, index) {
        dynamic data = widget.menu[index];
        return SizedBox(
            height: 10,
            child: data['category'] == 'appointment'
                ? cardClusterAppointment(data)
                : cardClusterNew(data));
      },
    );
  }

  //End Layanan Warga
  @override
  Widget build(BuildContext context) {
    // log("menu = ${widget.menu}");
    return LoadingFallback(
      isLoading: _isLoading,
      child: oldBody(),
    );
  }
}
