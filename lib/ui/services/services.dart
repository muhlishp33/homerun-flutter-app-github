import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/helper/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:appid/component/form/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage(this.data, {super.key});

  final dynamic data;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  HttpService http = HttpService();

  dynamic stateProfile;
  bool _isLoading = true;
  List listAddresss = [];
  dynamic selectedAddress = {
    'id': -1,
    'name': 'Select Address',
    'address': 'Select or Add New Address',
  };

  List listCategory = [];
  List listInformation = [];
  List listTimeslotDate = [];
  List listTimeslotMonthYear = [];
  List listTimeslotTime = [];
  String selectedTimeslotDate = '';
  String selectedTimeslotMonthYear = '';
  String selectedTimeslotTime = '';
  TextEditingController notesText = TextEditingController();
  int totalPrice = 0;
  int totalDicount = 0;
  TextEditingController searchText = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
    getTimeSlot(null);
    getAddressUser();
  }

  void _getData() async {
    dynamic profile = await getInstanceJson('profile');
    setState(() {
      stateProfile = profile;
    });
    
    http.post('services/category',
        body: {'services_id': widget.data['id']}).then((res) {
      // log('res services/category ${res}');

      if (res['success'] == true) {
        setState(() {
          listCategory = res['data'];
        });
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err services/category ${err}');

      setState(() {
        _isLoading = false;
      });
    });

    http.post('services/information',
        body: {'services_id': widget.data['id']}).then((res) {
      // log('res services/information ${res}');

      if (res['success'] == true) {
        setState(() {
          listInformation = res['data'];
        });
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err services/information ${err}');

      setState(() {
        _isLoading = false;
      });
    });
  }

  void getTimeSlot(date) {
    dynamic body = {
      'services_id': widget.data['id'],
    };

    if (date != null) {
      body['date'] = date;
    }

    // log('body $body');

    http.post('services/timeslot', body: body).then((res) {
      // log('res services/timeslot ${res}');

      dynamic resData = res['data'];
      List newDate = [];
      List newMonthYear = [];
      List newTime = [];
      // log('wawaw ${newMonthYear}');

      if (res['success'] == true) {
        resData['date'].forEach((k, v) => {
          // newDate.add({k: v})
          newDate.add(v)
        });

        resData['month_year'].forEach((k, v) => {
          // newMonthYear.add({k: v})
          newMonthYear.add(v)
        });

        resData['time'].forEach((e) {
          newTime.add(e);
        });
      }

      setState(() {
        listTimeslotDate = newDate;
        listTimeslotMonthYear = newMonthYear;
        listTimeslotTime = newTime;
        _isLoading = false;
      });

      if (date != null) {
        onTapDateTime();
      }
    }).catchError((err) {
      log('err services/timeslot ${err}');

      setState(() {
        _isLoading = false;
      });
    });
  }

  void getAddressUser() {
    // dynamic body = {"is_primary": true};

    http.post('address').then((res) {
      // log('res address ${res}');

      if (res['success'] == true &&
          res['data'] is List &&
          res['data'].length > 0) {
        dynamic primaryAddr;
        res['data'].forEach((e) {
          if (e['is_primary'] == true) primaryAddr = e;
        });

        setState(() {
          if (primaryAddr != null) selectedAddress = primaryAddr;
          listAddresss = res['data'];
        });
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      log('err address ${err}');

      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<dynamic> onSetPrimaryAddress(id) async {
    setState(() {
      _isLoading = true;
    });

    dynamic body = {"id": id};

    // log('body $body');

    http.post('address/primary', body: body).then((res) {
      if (res['success'] == true) {
        getAddressUser();
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((e) {
      Helper(context: context).flushbar(
        msg: 'Terjadi kesalahan',
        success: false,
      );

      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget renderCardServiceCategory(dynamic item, int i) {
    final double width = MediaQuery.of(context).size.width;
    bool useQuantity = item['use_quantity'] == true;

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
        width: width * 0.4,
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
        child: Center(
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
                      )
                  ),
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
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
                if (showHargaCoret) SizedBox(
                  height: 7,
                ),
                if (showHargaCoret) Wrap(
                  children: [
                    Text(
                      NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0)
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
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0)
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
                if (useQuantity) Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 3, horizontal: 5),
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (!canDescrease) return;

                          List newArr = [...listCategory];
                          newArr[i]['quantity'] = itemQty - 1;
                          setState(() {
                            listCategory = newArr;
                            totalPrice = totalPrice - itemPrice;
                            totalDicount = totalDicount - totalDicount;
                          });
                        },
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                              color: Constants.colorSecondary,
                              borderRadius:
                                  BorderRadius.circular(120)),
                          child: Icon(
                            Icons.remove,
                            color: Constants.colorWhite,
                            size: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14),
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
                          if (!canIncrease) return;

                          List newArr = [...listCategory];
                          newArr[i]['quantity'] = itemQty + 1;
                          setState(() {
                            listCategory = newArr;
                            totalPrice = totalPrice + itemPrice;
                            totalDicount = totalDicount + totalDicount;
                          });
                        },
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                              color: Constants.colorSecondary,
                              borderRadius:
                                  BorderRadius.circular(120)),
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
                if (!useQuantity) InkWell(
                  onTap: () {
                    List newArr = [...listCategory];
                    int calcPrice = totalPrice;
                    int calcDiscount = totalDicount;

                    if (itemQty > 0) {
                      newArr[i]['quantity'] = itemQty - 1;
                      calcPrice = totalPrice - itemPrice;
                      calcDiscount = totalDicount - totalDicount;
                    } else {
                      newArr[i]['quantity'] = itemQty + 1;
                      calcPrice = totalPrice + itemPrice;
                      calcDiscount = totalDicount + totalDicount;
                    }
                            
                    setState(() {
                      listCategory = newArr;
                      totalPrice = calcPrice;
                      totalDicount = calcDiscount;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 7, left: 16, right: 16),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: itemQty > 0 ? Color(0xFFEB5757) : Constants.colorSecondary,
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
                              color: itemQty > 0 ? Constants.colorWhite : Constants.colorText,
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
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _list() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    String dateInfoLabel = '$selectedTimeslotDate $selectedTimeslotMonthYear $selectedTimeslotTime';
    bool isEmptyDateInfo = selectedTimeslotDate == '' || selectedTimeslotMonthYear == '' || selectedTimeslotTime == '';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              // margin: EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Constants.colorWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Constants.colorPlaceholder,
                      offset: Offset(0, 1),
                      blurRadius: 1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // address
                  InkWell(
                    onTap: () {
                      if (listAddresss.isNotEmpty) {
                        onTapAddress();
                      } else {
                        Navigator.pushNamed(context, '/daftarAlamatPage')
                            .then(
                          (value) => getAddressUser(),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.5,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: width * 0.1,
                            height: width * 0.1,
                            child: Image.asset(
                              'assets/images/services/pick-location.png',
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(selectedAddress?['name'],
                                        style: const TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(selectedAddress?['address'],
                                        style: const TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                  ]),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  // date time
                  InkWell(
                    onTap: () {
                      onTapDateTime();
                    },
                    child: Container(
                      // padding: EdgeInsets.only(bottom: 20),
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     bottom: BorderSide(
                      //       width: 0.5,
                      //       color: Colors.grey.shade300,
                      //     ),
                      //   ),
                      // ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: width * 0.1,
                            height: width * 0.1,
                            child: Image.asset(
                              'assets/images/services/pick-date.png',
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date & Time',
                                        style: const TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Text(
                                        isEmptyDateInfo ? 'Please pick date time' : dateInfoLabel,
                                        style: const TextStyle(
                                            color: Constants.colorTitle,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                  ]),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (listInformation.length > 0) Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Container(
                  // padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What kind problem are you having?',
                    style: TextStyle(
                        color: Constants.colorTitle,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  // margin: EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Constants.colorWhite,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: Constants.colorPlaceholder,
                          offset: Offset(0, 1),
                          blurRadius: 1),
                    ],
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0.0),
                      itemCount: listInformation.length,
                      itemBuilder: (BuildContext context, int i) {
                        dynamic item = listInformation[i];
                        bool isLast = (i + 1) == listInformation.length;
                        // list.firstWhere((a) => a == b, orElse: () => null);
                        bool isSelected = item['selected'] == true ? true : false;

                        return Container(
                          padding: EdgeInsets.only(top: 14, bottom: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: isLast ? 0 : 0.5,
                                color: isLast
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  // padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item?['information_name'],
                                            style: const TextStyle(
                                                color: Constants.colorTitle,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400)),
                                      ]),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  List newArr = [...listInformation];
                                  newArr[i]['selected'] = !isSelected;
                                  setState(() {
                                    listInformation = newArr;
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? Constants.redTheme
                                          : Constants.colorWhite,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected
                                            ? Constants.redTheme
                                            : Constants.colorCaption,
                                      )),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Constants.colorWhite,
                                        )
                                      : Container(),
                                ),
                              )
                            ],
                          ),
                        );
                      })),
              ],
            ),
            
            if (listCategory.length > 0) Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Container(
                  // padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'The service you need',
                    style: TextStyle(
                        color: Constants.colorTitle,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(1),
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < listCategory.length; i++) renderCardServiceCategory(listCategory[i], i),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // notes
            Container(
              margin: EdgeInsets.only(top: 24),
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: CustomTextInput(
                hintText: "Add Notes",
                placeholder: "Write notes here (optional)",
                controllerName: notesText,
                enabled: true,
                maxLines: 3,
                minLines: 3,
                isRequired: true,
                onChangeText: () {},
                onTap: () {},
                onEditingComplete: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapOrderInfo() {
    double width = MediaQuery.of(context).size.width;
    double paddingBottom = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: paddingBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // toggle
                Container(
                  width: width * 0.1,
                  height: 4,
                  margin: EdgeInsets.only(top: 10, bottom: 30),
                  decoration: BoxDecoration(
                    color: Constants.colorCaption,
                  ),
                ),
                // title
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('Total Price',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Column(
                  children: listCategory.map((e) {
                    dynamic item = e;
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
                    int itemQty =
                        item['quantity'] is int ? item['quantity'] : 0;

                    itemPrice = itemPrice * itemQty;
                    itemDiscount = itemDiscount * itemQty;

                    bool showHargaCoret = itemDiscount > 0;

                    if (itemQty <= 0) return Container();

                    return Container(
                      margin: EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '(Qty: ${itemQty} ${item['type_quantity']})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Constants.colorCaption,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (showHargaCoret)
                                Text(
                                  NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp ',
                                          decimalDigits: 0)
                                      .format(itemDiscount ),
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Constants.colorCaption,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(itemPrice),
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
                // Container(
                //   padding: EdgeInsets.only(bottom: 14),
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(
                //         width: 0.5,
                //         color: Colors.grey.shade300,
                //       ),
                //     ),
                //   ),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: Wrap(
                //           children: [
                //             Text(
                //               'Diskon',
                //               style: TextStyle(
                //                   fontSize: 12, fontWeight: FontWeight.w400),
                //             ),
                //           ],
                //         ),
                //       ),
                //       Wrap(
                //         crossAxisAlignment: WrapCrossAlignment.center,
                //         children: [
                //           Text(
                //             '0%',
                //             style: TextStyle(
                //                 fontSize: 12, fontWeight: FontWeight.w500),
                //           ),
                //         ],
                //       )
                //     ],
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.only(top: 18, bottom: 18),
                  child: Row(
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NumberFormat.currency(
                                          locale: 'id',
                                          symbol: 'Rp ',
                                          decimalDigits: 0)
                                      .format(totalDicount > 0 ? totalDicount : totalPrice),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Constants.redTheme),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void onTapAddress() {
    final double width = MediaQuery.of(context).size.width;
    double paddingBottom = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
              return Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: paddingBottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // toggle
                    Container(
                      width: width * 0.1,
                      height: 4,
                      margin: EdgeInsets.only(top: 10, bottom: 30),
                      decoration: BoxDecoration(
                        color: Constants.colorCaption,
                      ),
                    ),
                    // title
                    Text('Address',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saved Places',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/daftarAlamatPage')
                                  .then(
                                (value) => getAddressUser(),
                              );
                            },
                            child: Text('View All',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Constants.redTheme),
                            ),
                          )
                        ],
                      ),
                    ),
                    // list address
                    Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          // margin: EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Constants.colorWhite,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                  color: Constants.colorPlaceholder,
                                  offset: Offset(0, 1),
                                  blurRadius: 1),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0.0),
                            itemCount: listAddresss.length,
                            itemBuilder: ((context, index) {
                              dynamic item = listAddresss[index];
                              bool isLast = index == (listAddresss.length - 1);
                              
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onSetPrimaryAddress(item['id']);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 0.5,
                                        color: isLast ? Colors.transparent : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: width * 0.1,
                                        height: width * 0.1,
                                        child: Image.asset(
                                          'assets/images/icon/primary-saved.png',
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Wrap(
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: [
                                                    Text(item['name'],
                                                        style: const TextStyle(
                                                            color: Constants.colorTitle,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500)),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    // selected
                                                    if (item['is_primary']) Container(
                                                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                                                      decoration: BoxDecoration(
                                                        color: Constants.colorSecondary,
                                                        borderRadius: BorderRadius.circular(120),
                                                      ),
                                                      child: Text(
                                                        'Selected',
                                                        style: TextStyle(
                                                          fontSize: 8.0,
                                                          color: Constants.redTheme,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Text(item['address'],
                                                    style: const TextStyle(
                                                        color: Constants.colorTitle,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400)),
                                              ]),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset('assets/images/icon/edit.png'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          )
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void onTapDateTime() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
              return Padding(
                padding: EdgeInsets.only(top: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // toggle
                    Container(
                      width: width * 0.1,
                      height: 4,
                      margin: EdgeInsets.only(top: 10, bottom: 30),
                      decoration: BoxDecoration(
                        color: Constants.colorCaption,
                      ),
                    ),
                    // title
                    Text('Service Date & Time',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 22,),
                    // list datetime
                    Row(
                      children: [
                        Column(
                          children: [
                            Text('Date',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                            Container(
                              margin: EdgeInsets.only(top: 14),
                              width: width * 0.25,
                              height: height / 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Constants.redTheme,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0.0),
                                  itemCount: listTimeslotDate.length,
                                  itemBuilder: ((context, index) {
                                    dynamic item = listTimeslotDate[index];
                                    bool isLast = index == (listTimeslotDate.length - 1);
                                    bool isSelected = selectedTimeslotDate == item;
                                    
                                    return InkWell(
                                      onTap: () {
                                        setStateModal(() {
                                          selectedTimeslotDate = item;
                                        });
                                        Navigator.of(context).pop();
                                        getTimeSlot(item);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 14),
                                        child: Text('$item',
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w400,
                                              color: isSelected ? Constants.redTheme : Constants.colorCaption,
                                              )),
                                      ),
                                    );
                                  })
                                )
                              ),
                            ),
                          ],
                        ),
                        // list months
                        Column(
                          children: [
                            Text('Month',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                            Container(
                              margin: EdgeInsets.only(top: 14),
                              width: width * 0.3,
                              height: height / 4,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Constants.colorBorder, width: 1.0),
                                  right: BorderSide(color: Constants.colorBorder, width: 1.0),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Constants.colorSecondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0.0),
                                  itemCount: listTimeslotMonthYear.length,
                                  itemBuilder: ((context, index) {
                                    dynamic item = listTimeslotMonthYear[index];
                                    bool isLast = index == (listTimeslotMonthYear.length - 1);
                                    bool isSelected = selectedTimeslotMonthYear == item;
                                    
                                    return InkWell(
                                      onTap: () {
                                        setStateModal(() {
                                          selectedTimeslotMonthYear = item;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 14),
                                        child: Text(item,
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w400,
                                              color: isSelected ? Constants.redTheme : Constants.colorCaption,
                                              )),
                                      ),
                                    );
                                  })
                                )
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Time',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                            Container(
                              margin: EdgeInsets.only(top: 14),
                              width: width * 0.45,
                              height: height / 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Constants.redTheme,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(0.0),
                                  itemCount: listTimeslotTime.length,
                                  itemBuilder: ((context, index) {
                                    dynamic item = listTimeslotTime[index];
                                    bool isLast = index == (listTimeslotTime.length - 1);
                                    bool isSelected = selectedTimeslotTime == item;
                                    
                                    return InkWell(
                                      onTap: () {
                                        setStateModal(() {
                                          selectedTimeslotTime = item;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 14),
                                        child: Text(item,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: isSelected ? Constants.redTheme : Constants.colorCaption,
                                          )),
                                      ),
                                    );
                                  })
                                )
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    // btn
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelectDateTime(selectedTimeslotDate, selectedTimeslotMonthYear, selectedTimeslotTime);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Constants.redTheme,
                            borderRadius: BorderRadius.circular(120),
                          ),
                          child: const Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Select & Changes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Constants.colorWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void onSelectDateTime(date, monthYear, time) {
    setState(() {
      selectedTimeslotDate = date;
      selectedTimeslotMonthYear = monthYear;
      selectedTimeslotTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {

    // log('listTimeslotTime ${listTimeslotTime}');

    bool showTotalCoret = totalDicount > 0;

    return Scaffold(
        backgroundColor: Colors.white,
        key: _key,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: true,
          backgroundColor: Constants.colorWhite,
          centerTitle: false,
          title:
              Text(widget.data['services_name'], style: Constants.textAppBar3),
          titleSpacing: 0,
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 5),
          width: MediaQuery.of(context).size.width,
          child: LoadingFallback(
            isLoading: _isLoading,
            child: _list(),
          ),
        ),
        // resizeToAvoidBottomInset: true,
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 7, bottom: 18),
                    child: Row(
                      children: [
                        Text('Total Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showTotalCoret) Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp ',
                                            decimalDigits: 0)
                                        .format(totalDicount),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Constants.colorCaption),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp ',
                                            decimalDigits: 0)
                                        .format(totalPrice),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Constants.redTheme),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onTapOrderInfo,
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: const Icon(
                              Icons.expand_more,
                              size: 24,
                              color: Constants.colorTitle,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (stateProfile != null && stateProfile['is_guest']) {
                        Helper(context: context).flushbar(msg: 'Silakan login untuk menikmati fitur ini', success: false);
                        return;
                      }

                      dynamic args = widget.data;
                      args['totalPrice'] = totalPrice;
                      args['selectedNote'] = notesText.text;
                      args['selectedAddress'] = selectedAddress;
                      args['dateInfo'] = selectedTimeslotDate + ' ' + selectedTimeslotMonthYear + ' ' + selectedTimeslotTime;
                      List selectedCategory = [];
                      listCategory.forEach((e) {
                        if (e['quantity'] is int && e['quantity'] > 0) {
                          int itemPrice = e['price'] is int
                              ? e['price']
                              : e['price'] is String
                                  ? int.parse(e['price'])
                                  : 0;
                          int itemDiscount = e['discount'] is int
                              ? e['discount']
                              : e['discount'] is String
                                  ? int.parse(e['discount'])
                                  : 0;
                          e['amount'] = itemDiscount;
                          e['final_amount'] = itemPrice;
                          selectedCategory.add(e);
                        }
                      });
                      args['selectedCategory'] = selectedCategory;

                      List selectedInformation = [];
                      listInformation.forEach((e) {
                        if (e['selected'] == true) selectedInformation.add(e);
                      });

                      args['selectedInformation'] = selectedInformation;
                      
                      // log('${args}');
                      String errorMsg = '';
                      if (selectedAddress == null) {
                        errorMsg = 'Mohon pilih alamat';
                      }
                      if (selectedTimeslotDate == '' || selectedTimeslotMonthYear == '' || selectedTimeslotTime == '') {
                        errorMsg = 'Mohon pilih tanggal';
                      }
                      if (listCategory.length > 0) {
                        if (selectedCategory.length == 0) {
                          errorMsg = 'Mohon pilih category of service';
                        }
                      }
                      if (listInformation.length > 0) {
                        if (selectedInformation.length == 0) {
                          errorMsg = 'Mohon pilih information';
                        }
                      }

                      if (errorMsg != '') {
                        Helper(context: context).flushbar(msg: errorMsg, success: false);
                        return;
                      }

                      Navigator.pushNamed(context, '/serviceOrderConfirmationPage', arguments: args);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: stateProfile != null && stateProfile['is_guest'] ? Constants.colorCaption : Constants.redTheme,
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: const Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Confirm Order',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Constants.colorWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
