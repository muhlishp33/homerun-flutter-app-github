import 'dart:developer';

import 'package:appid/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appid/component/widget/constants.dart';

class CardServiceCategory extends StatefulWidget {
  const CardServiceCategory(this.item, this.index, this.isHomeCleaning,
      {super.key});

  final dynamic item;
  final int index;
  final bool isHomeCleaning;

  @override
  State<CardServiceCategory> createState() => _CardServiceCategoryState();
}

class _CardServiceCategoryState extends State<CardServiceCategory> {
  @override
  void initState() {
    super.initState();
  }

  bool isValidDateTime(str) {
    if (str is! String) return false;
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic item = widget.item;
    int itemPrice = item['price'] is int
        ? item['price']
        : item['price'] is String
            ? int.parse(item['price'])
            : 0;
    int itemDiscount = item['discount'] is int
        ? item['discount']
        : item['discount'] is String
            ? int.parse(item['discount'])
            : 0;
    int itemQty = item['quantity'] is int ? item['quantity'] : 0;
    bool canDescrease = itemQty > 0;
    bool canIncrease = itemQty < 100;
    bool showHargaCoret = itemDiscount > 0;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Constants.colorWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Constants.colorPlaceholder,
                offset: Offset(0, 0.5),
                blurRadius: 0.5),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 7 / 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                      border: Border.all(
                        width: 1,
                        color: Constants.colorPlaceholder,
                      )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Image.network(
                      item['image'],
                    ),
                  ),
                ),
                Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                if (showHargaCoret)
                  SizedBox(
                    height: 7,
                  ),
                if (showHargaCoret)
                  Wrap(
                    children: [
                      Text(
                        NumberFormat.currency(
                                locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                            .format(itemDiscount),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            decoration: TextDecoration.lineThrough),
                      ),
                      // Text(
                      //   '/${item['type_quantity']}',
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.w400,
                      //     fontSize: 8,
                      //     decoration: TextDecoration.lineThrough
                      //   ),
                      // ),
                    ],
                  ),
                SizedBox(height: 7),
                Wrap(
                  children: [
                    Text(
                      NumberFormat.currency(
                              locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                          .format(itemPrice),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Constants.redTheme,
                      ),
                    ),
                    // Text(
                    //   '/${item['type_quantity']}',
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 10),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                // add quantity
                if (!widget.isHomeCleaning)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Constants.colorWhite,
                      borderRadius: BorderRadius.circular(120),
                      boxShadow: const [
                        BoxShadow(
                            color: Constants.colorPlaceholder,
                            offset: Offset(0, 0.5),
                            blurRadius: 0.5),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            // if (!canDescrease) return;

                            // List newArr = [...listCategory];
                            // newArr[i]['quantity'] = itemQty - 1;
                            // setState(() {
                            //   listCategory = newArr;
                            //   totalPrice = totalPrice - itemPrice;
                            //   totalDicount = totalDicount - totalDicount;
                            // });
                          },
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                color: Constants.colorSecondary,
                                borderRadius: BorderRadius.circular(120)),
                            child: Icon(
                              Icons.remove,
                              color: Constants.colorWhite,
                              size: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            itemQty.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Constants.colorCaption,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // if (!canIncrease) return;

                            // List newArr = [...listCategory];
                            // newArr[i]['quantity'] = itemQty + 1;
                            // setState(() {
                            //   listCategory = newArr;
                            //   totalPrice = totalPrice + itemPrice;
                            //   totalDicount = totalDicount + totalDicount;
                            // });
                          },
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                color: Constants.colorSecondary,
                                borderRadius: BorderRadius.circular(120)),
                            child: Icon(
                              Icons.add,
                              color: Constants.colorWhite,
                              size: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                // remove item
                if (widget.isHomeCleaning)
                  InkWell(
                    onTap: () {
                      // List newArr = [...listCategory];
                      // int calcPrice = totalPrice;
                      // int calcDiscount = totalDicount;

                      // if (itemQty > 0) {
                      //   newArr[i]['quantity'] = itemQty - 1;
                      //   calcPrice = totalPrice - itemPrice;
                      //   calcDiscount = totalDicount - totalDicount;
                      // } else {
                      //   newArr[i]['quantity'] = itemQty + 1;
                      //   calcPrice = totalPrice + itemPrice;
                      //   calcDiscount = totalDicount + totalDicount;
                      // }

                      // setState(() {
                      //   listCategory = newArr;
                      //   totalPrice = calcPrice;
                      //   totalDicount = calcDiscount;
                      // });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 7, left: 16, right: 16),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: itemQty > 0
                            ? Color(0xFFEB5757)
                            : Constants.colorSecondary,
                        borderRadius: BorderRadius.circular(120),
                        boxShadow: const [
                          BoxShadow(
                              color: Constants.colorPlaceholder,
                              offset: Offset(0, 0.5),
                              blurRadius: 0.5),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          itemQty > 0 ? 'Remove' : 'Add',
                          style: TextStyle(
                            fontSize: 10,
                            color: itemQty > 0
                                ? Constants.colorWhite
                                : Constants.colorText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                Container(
                    margin: EdgeInsets.only(top: 6),
                    child: Text(
                      'per ${item['type_quantity']}',
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
