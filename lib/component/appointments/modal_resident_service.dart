import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/appointments/func_appointment.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';

class ModalResidentService extends StatefulWidget {
  const ModalResidentService({super.key, required this.ipl, this.profile});

  final String ipl;
  final dynamic profile;
  @override
  State<ModalResidentService> createState() => _ModalResidentServiceState();
}

class _ModalResidentServiceState extends State<ModalResidentService> {
  //Layanan Warga
  List<dynamic> residentBilling = [
    {
      'parent': 'resident',
      'type': 'billing',
      'name': 'BSD City IPL',
      'subTitle': 'View and pay your BSD City IPL easily',
      'image': 'assets/images/home4/resident-billing.png',
      'imageUrl': '',
      'nav': '/iplMainPage',
      'enable': true,
      'enableMsg': '',
      'eventName': ResidentServiceEventName.ipl,
    },
  ];
  //End Layanan Warga
  @override
  void initState() {
    if (widget.profile != null && widget.profile["cluster_joined"]) {
      setState(() {
        residentBilling.insert(
          0,
          {
            'parent': 'resident',
            'type': 'resident-billing',
            'name': 'Resident Billing',
            'subTitle': 'View and pay your resident billing easily',
            'image': 'assets/images/home4/citizen-billing.png',
            'imageUrl': '',
            'nav': getAppointmentPagePath('resident-billing'),
            'enable': true,
            'enableMsg': '',
            'category': 'appointment',
            'eventName': ResidentServiceEventName.residentBilling,
          },
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            child: const Text(
              'Resident Billing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            // height: MediaQuery.of(context).size.height * 0.75,
            padding:  EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (var i = 0; i < residentBilling.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          if (widget.ipl != '' ||
                              residentBilling[i]['parent'] == 'customer_care') {
                            String category = residentBilling[i]['category'];
                            // log('category $category');
                            if (category == "appointment") {
                              if (residentBilling[i]["type"] ==
                                  'resident-billing') {
                                Helper(context: context).pushToLogger(body: {
                                  "event_name": "resident",
                                  "event_values": {
                                    "id": 0,
                                    "type": "resident_menu",
                                    "title": 'Resident Billing',
                                  }
                                });
                                Navigator.of(context).pushNamed(
                                    residentBilling[i]["nav"],
                                    arguments: {
                                      'appointmentType': residentBilling[i]
                                          ["type"]
                                    });
                                return;
                              }
                            }
                            Helper(context: context).pushToLogger(body: {
                              "event_name": "resident",
                              "event_values": {
                                "id": 0,
                                "type": "resident_menu",
                                "title": 'BSD City IPL',
                              }
                            });
                            Navigator.of(context).pushNamed(
                              residentBilling[i]["nav"],
                            );
                            return;
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image(
                              image: AssetImage(residentBilling[i]["image"]),
                              width: 48,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Constants.colorBorder,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 2.5),
                                      child: Text(
                                        residentBilling[i]['name'] is String
                                            ? residentBilling[i]['name']
                                            : '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        residentBilling[i]['subTitle'] is String
                                            ? residentBilling[i]['subTitle']
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
