// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/appointments/func_appointment.dart';
import 'package:appid/component/appointments/modal_service_appointment.dart';
import 'package:appid/component/widget/index.dart';
import 'package:appid/helper/analytics.dart';
import 'package:path_provider/path_provider.dart';

class InkWellAppointment extends StatefulWidget {
  const InkWellAppointment(
      {super.key,
      required this.appointmentType,
      required this.child,
      this.appointmentParentId = -1,
      this.isFloatingActionButton = false,
      this.onTapExtra,
      this.navigatePath = ''});

  final String appointmentType;
  final Widget child;
  final int appointmentParentId;
  final bool isFloatingActionButton;
  final Function? onTapExtra;
  final String navigatePath;
  @override
  State<InkWellAppointment> createState() => _InkWellAppointmentState();
}

class _InkWellAppointmentState extends State<InkWellAppointment> {
  final HttpService http = HttpService();

  String _endpointPrefix = '';
  String navPath = '';
  String appointmentPagePath = '';

  String title = '';
  String imageUrl = '';
  bool show = true;
  bool isActive = true; // is_active or success status
  String message = '';
  dynamic popupService;
  List listService = [];

  // dynamic resultStatus;
  bool isLoading = true;
  bool isDocumentRequest = false;

  dynamic resultRequisiteForm;
  bool useRequisiteForm = false;

  @override
  void initState() {
    setState(() {
      _endpointPrefix = getAppointmentEndpointPrefix(widget.appointmentType);
      navPath = getAppointmentCreatePagePath(widget.appointmentType);
      appointmentPagePath = getAppointmentPagePath(widget.appointmentType);
      isDocumentRequest = widget.appointmentType == 'document-request';
    });
    getAppointmentStatus();
    getServiceAppointment();
    super.initState();
  }

  void getAppointmentStatus() {
    http.post('${_endpointPrefix}appointment-status').then((res) {
      bool useForm = false;
      dynamic resultForm;

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
        imageUrl = res['data']['image_url'];
        show = res['data']['show'];
        isActive = res['success'];
        message = res['msg'];
        popupService = res['data']['popup_service'];
        isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getServiceAppointment() {
    http.post('${_endpointPrefix}get-service-appointment').then((res) {
      // log('$endpointPrefix service $res');

      if (res['success'] == true) {
        setState(() {
          listService = res['data'];
        });
      }
    }).catchError((err) {
      // log('$_endpointPrefix service $err');
    });
  }

  void showModal() {
    showAppNotification(
      context: context,
      title: 'Info',
      desc: message,
    );
  }

  void onTapNavigateTo() {
    if (listService.isEmpty) {
      return showModal();
    }

    dynamic args = {
      ...listService[0],
      'appointmentType': widget.appointmentType,
    };

    if (widget.appointmentParentId != -1) {
      args['appointmentParentId'] = widget.appointmentParentId;
    }

    if (useRequisiteForm) {
      args['requisite_form'] = resultRequisiteForm;
      Navigator.of(context).pushNamed(
        '/appointmentRequisiteFormPage',
        arguments: args,
      );
      return;
    }

    if (widget.appointmentType == 'visitor' ||
        widget.appointmentType == 'rt-rw') {
      // log(appointmentPagePath);
      Navigator.of(context).pushNamed(
        appointmentPagePath,
        arguments: {'appointmentType': widget.appointmentType},
      );
      return;
    }

    // log('navPath: $navPath');

    Navigator.of(context).pushNamed(
      navPath,
      arguments: args,
    );
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
                  padding: EdgeInsets.only(
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
                            onTapNavigateTo();
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
            appointmentType: widget.appointmentType,
          );
        });
  }

  void onTap() {
    if (widget.onTapExtra != null) widget.onTapExtra!();

    // const String eventName = "drive-thru";
    // final Map<String, dynamic> eventValues = {
    //   "type": widget.appointmentType,
    // };

    if (isActive) {
      if (navPath != '') {
        if (widget.navigatePath != '') {
          Navigator.of(context).pushNamed(widget.navigatePath);
          return;
        }
        if (popupService['need_download'] == true) {
          onTapNeedDownload();
        } else {
          if (popupService != null && popupService['use'] == true) {
            onTapShowListService();
          } else {
            onTapNavigateTo();
          }
        }
      } else {
        showModal();
      }
    } else {
      showModal();
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (show == false) {
    //   return Container();
    // }

    if (widget.isFloatingActionButton) {
      return SizedBox(
        height: 36.0,
        child: FittedBox(
          child: FloatingActionButton.extended(
            onPressed: () {
              onTap();
            },
            label: widget.child,
            heroTag: null,
            backgroundColor: Constants.redTheme,
          ),
        ),
      );
    }

    return GestureDetector(
        onTap: () {
          onTap();
        },
        child: widget.child);
  }
}
