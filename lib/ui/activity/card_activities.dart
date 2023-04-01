import 'dart:developer';

import 'package:appid/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/widget/constants.dart';

class CardActivities extends StatefulWidget {
  const CardActivities(this.item, {super.key});

  final dynamic item;

  @override
  State<CardActivities> createState() => _CardActivitiesState();
}

class _CardActivitiesState extends State<CardActivities> {

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    bool hasExpiredDate = false;
    DateTime parseEndDate;
    String endDateFormat = '';

    if (widget.item['expired_date'] is String && isValidDateTime(widget.item['expired_date'])) {
      if (widget.item['status'] == 0) {
        hasExpiredDate = true;
      }
      parseEndDate = DateTime.parse(widget.item['expired_date']);
      endDateFormat = DateFormat('dd MMM yyyy | HH:mm').format(parseEndDate);
    }

    return InkWell(
              onTap: () {
                // log('widget.item ${widget.item}');
                dynamic args = {
                  "id": widget.item['id'],
                };
                Navigator.pushNamed(context, '/serviceOrderDetailPage',
                    arguments: args);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Constants.colorWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Constants.colorPlaceholder,
                          offset: Offset(0, 1),
                          blurRadius: 1),
                    ]),
                child: Column(
                    children: [
                      if (hasExpiredDate) Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 5, bottom: 3, left: 16, right: 16),
                      decoration: BoxDecoration(
                        color: Constants.colorSecondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        )
                      ),
                      child: Wrap(
                        children: [
                          Text('Complete your payment before ',
                            style: TextStyle(
                              color: Constants.colorTitle,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                          Text(endDateFormat,
                            style: TextStyle(
                              color: Constants.colorTitle,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: width * 0.1,
                            height: width * 0.1,
                            child: Image.asset(widget.item['order_type'] ==
                                    'GAS'
                                ? 'assets/images/activities/gas-circle.png'
                                : widget.item['order_type'] == 'AC'
                                    ? 'assets/images/activities/ac-services-circle.png'
                                    : widget.item['order_type'] == 'GALON'
                                        ? 'assets/images/activities/water-gallon-circle.png'
                                        : 'assets/images/activities/cleaning-services-circle.png'),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.item['order_name']??'',
                                        style: TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w500)),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/images/icon/calendar-edit.png',
                                            width: 12,
                                            height: 12),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(widget.item['created_date'],
                                            style: TextStyle(
                                                color: Constants
                                                    .colorCaption,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.w400)),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(int.parse(
                                        widget.item["final_amount"])),
                                style: const TextStyle(
                                    color: Constants.redTheme,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: colorFromHex(widget.item['status_bg_color']),
                                    borderRadius:
                                        BorderRadius.circular(120)),
                                child: Text(
                                  widget.item['status_label'],
                                    style: TextStyle(
                                        color: colorFromHex(widget.item['status_color']),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}
