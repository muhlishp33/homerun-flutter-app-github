import 'dart:developer';

import 'package:appid/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/widget/constants.dart';

class CardInsightList extends StatefulWidget {
  const CardInsightList(this.item, {super.key});

  final dynamic item;

  @override
  State<CardInsightList> createState() => _CardInsightListState();
}

class _CardInsightListState extends State<CardInsightList> {

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

    DateTime parseDate;
    String dateFormat = '';

    if (widget.item['created_date'] is String && isValidDateTime(widget.item['created_date'])) {
      parseDate = DateTime.parse(widget.item['created_date']);
      dateFormat = DateFormat('dd MMM yyyy').format(parseDate);
    }

    return InkWell(
              onTap: () {
                // log('widget.item ${widget.item}');
                dynamic args = {
                  "id": widget.item['id'],
                };
                Navigator.pushNamed(context, '/insightDetailPage',
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: width * 0.175,
                            height: width * 0.175,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.network(
                                widget.item['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12),
                                  height: width * 0.175,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.item['article_category_name'],
                                            style: TextStyle(
                                                color: Constants
                                                    .redTheme,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.w400)),
                                        SizedBox(height: 2,),
                                        Text(widget.item['title'],
                                            style: TextStyle(
                                                color: Constants.colorTitle,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Text(dateFormat,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}
