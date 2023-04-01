import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/color.dart';

class CustomerCareHistory extends StatefulWidget {
  const CustomerCareHistory(
      {super.key, required this.actionActive, this.isResidentService = false});

  final bool actionActive;
  final bool isResidentService;
  @override
  State<CustomerCareHistory> createState() => _CustomerCareHistoryState();
}

class _CustomerCareHistoryState extends State<CustomerCareHistory> {
  HttpService http = HttpService();
  List<String> selectedCategory = [];
  List<String> title = [];
  int choice = 0;

  final String submittedCode = 'SUBMITTED';
  dynamic objRequestHistory = {
    "loading": true,
  };
  List listHistory = [];

  @override
  void initState() {
    // log("masuk sini");
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() {
    dynamic body = {"sf": 0, "limit": 10};
    if (widget.isResidentService) {
      body = {"sf": 0, "limit": 10, "type": "RESIDENT"};
    }
    // log("body appointment-history = $body");
    http.post('appointment-history', body: body).then((res) {
      // log("res appointment-history = $res");
      if (res['success'] == true && res["data"] is List) {
        setState(() {
          listHistory.addAll(res['data']);
        });
      }
    }).catchError((err) {
      log("err = $err");
    });
  }

  Widget tabToggle(String title) {
    return PreferredSize(
      preferredSize: const Size.fromWidth(32),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(247, 247, 247, 1)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget toggle(String title, int pref) {
    return InkWell(
      splashColor: Colors.blue[100],
      onTap: () {
        // selectedCategory = [];
        // selectedCategory.add(title);
        if (choice == pref) {
          setState(() {
            choice = 0;
            pref = 0;
          });
        }
        setState(() {
          choice = pref;
        });
        // log(choice);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          // color: selectedCategory.contains(title) ? Color.fromRGBO(238, 96, 85, 1) : Color.fromRGBO(247, 247, 247, 1),
          color: choice == pref
              ? const Color.fromRGBO(238, 96, 85, 1)
              : const Color.fromRGBO(247, 247, 247, 1),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          title,
          style: TextStyle(
              // color: selectedCategory.contains(title) ? Colors.white : Color.fromRGBO(178, 178, 178, 1),
              color: choice == pref
                  ? Colors.white
                  : const Color.fromRGBO(178, 178, 178, 1),
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget listItem(dynamic item) {
    String serviceName = item['service_name'] ?? '';
    String appointmentDate = item['appointment_date'] ?? '';
    String locationName = item['location_name'] ?? '';
    if (item['client_type'] == 'HAND_OVER_ZERO') {
      if (item["appointment_schedule_date"] != '' &&
          item["appointment_schedule_date"] != null) {
        appointmentDate = item["appointment_schedule_date"];
      }
      for (int i = 0; i < item["additional_form"].length; i++) {
        item["additional_form"][i].forEach((k, v) {
          if (v["code"] == "hand_over_zero_part_1_alamat_st" &&
              v["value"] != null) {
            locationName = v["value"];
          }
        });
      }
    }

    DateTime formattedAppointmentDate;
    String date = '';
    if (appointmentDate != '') {
      formattedAppointmentDate = DateTime.parse(appointmentDate);
      date = DateFormat('dd MMM yyyy').format(formattedAppointmentDate);
    }

    return InkWell(
      onTap: () {
        String appointmentType = '';

        // item.forEach((k, v) {
        //   log('$k :$v');
        // });
        List nonAppointment = ['HAND_OVER_ZERO'];
        switch (item['client_type']) {
          case 'DOCUMENT_PERMISSION':
            appointmentType = 'document-request';
            break;
          case 'TICKETING':
            appointmentType = 'ticketing';
            break;
          case 'CLUB_HOUSE':
            appointmentType = "club-house";
            break;
          case 'RESIDENT_BILLING':
            appointmentType = "resident-billing";
            break;
          case 'CUSTOMER_SERVICE':
            appointmentType = "appointment";
            break;
          default:
            appointmentType = item['client_type'].toString().toLowerCase();
            break;
        }
        dynamic tmp = {
          "appointment_id": item["appointment_id"],
          "appointmentType": appointmentType
        };
        if (nonAppointment.contains(item["client_type"])) {
          //TODO
          // Helper(context: context).toDetailHandoverPage(item["appointment_id"]);
          return;
        }
        Navigator.pushNamed(context, "/masterAppointmentDetailPage",
            arguments: tmp);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      serviceName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    )),
                    Expanded(
                        child: Text(
                      item['appointment_status'],
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colorFromHex(item['appointment_status_color']),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    )),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationName,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // ([2, 9].contains(item['status']))
                  //     ? Container(
                  //         // alignment: Alignment.centerRight,
                  //         padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  //         width: (MediaQuery.of(context).size.width / 2) - 24,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.end,
                  //           children: [
                  //             InkWell(
                  //               splashColor: Colors.blue[100],
                  //               onTap: () {},
                  //               child: Wrap(
                  //                 children: [
                  //                   Container(
                  //                     padding: const EdgeInsets.symmetric(
                  //                         vertical: 6, horizontal: 10),
                  //                     height: 36,
                  //                     decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.all(
                  //                             Radius.circular(10)),
                  //                         border: Border.all(
                  //                             color: Color.fromRGBO(
                  //                                 238, 96, 85, 1),
                  //                             width: 1,
                  //                             style: BorderStyle.solid)),
                  //                     child: Center(
                  //                       child: Text(
                  //                         'Chat',
                  //                         style: TextStyle(
                  //                             color: Color.fromRGBO(
                  //                                 238, 96, 85, 1),
                  //                             fontSize: 12,
                  //                             fontWeight: FontWeight.w700),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               width: 4,
                  //             ),
                  //             InkWell(
                  //               splashColor: Colors.blue[100],
                  //               onTap: () {},
                  //               child: Wrap(
                  //                 children: [
                  //                   Container(
                  //                     padding: const EdgeInsets.symmetric(
                  //                         vertical: 6, horizontal: 10),
                  //                     height: 36,
                  //                     decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.all(
                  //                             Radius.circular(10)),
                  //                         color: Color.fromRGBO(238, 96, 85, 1),
                  //                         border: Border.all(
                  //                             color: Color.fromRGBO(
                  //                                 238, 96, 85, 1),
                  //                             width: 1,
                  //                             style: BorderStyle.solid)),
                  //                     child: Center(
                  //                       child: Text(
                  //                         'Deposit Refund',
                  //                         style: TextStyle(
                  //                             color: Colors.white,
                  //                             fontSize: 12,
                  //                             fontWeight: FontWeight.w700),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : SizedBox(
                  //         height: 0.1,
                  //         width: 0.1,
                  //       )
                ])
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(children: [
        // Container(
        //     // padding: const EdgeInsets.all(12),
        //     height: (MediaQuery.of(context).size.height * 0.05),
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       children: [
        //         toggle('All', 0),
        //         SizedBox(
        //           width: 12,
        //         ),
        //         toggle('Submitted', 1),
        //         SizedBox(
        //           width: 12,
        //         ),
        //         toggle('On Progress', 2),
        //         SizedBox(
        //           width: 12,
        //         ),
        //         toggle('Completed', 3),
        //         SizedBox(
        //           width: 12,
        //         ),
        //         toggle('Canceled', 4),
        //       ],
        //     )),
        // SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
              itemCount: listHistory.length,
              itemBuilder: (context, index) {
                dynamic item = listHistory[index];

                return listItem(item);
              }),
        )
      ]),
    );
  }
}
