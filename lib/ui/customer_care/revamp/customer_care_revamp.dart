import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/ui/customer_care/revamp/customer_care_history.dart';
import 'package:appid/ui/customer_care/revamp/customer_care_menu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';

class CustomeCareRevPage extends StatefulWidget {
  const CustomeCareRevPage(this.data, {super.key});
  final dynamic data;
  @override
  State<CustomeCareRevPage> createState() => _CustomeCareRevPageState();
}

class _CustomeCareRevPageState extends State<CustomeCareRevPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final HttpService http = HttpService();
  TabController? _tabController1;
  // final TextEditingController _filter = TextEditingController();
  int? groupValue = 0;
  String dateNow = DateFormat('d MMM y').format(DateTime.now());
  String last7Date = DateFormat('d MMM y')
      .format(DateTime.now().subtract(const Duration(days: 7)));
  String last30Date = DateFormat('d MMM y')
      .format(DateTime.now().subtract(const Duration(days: 30)));
  String last60Date = DateFormat('d MMM y')
      .format(DateTime.now().subtract(const Duration(days: 60)));

  List<dynamic> bannerList = [];
  int _current = 0;
  String _ipl = '';
  String appointmentType = '';
  String navPath = '';
  dynamic profile;
  bool _isLoading = true;
  List<dynamic> menu = [];
  List listService = [];
  List filteredMenu = [];
  bool actionActive = false;
  AppBar? currentAppBar;
  dynamic resultRequisiteForm;
  bool useRequisiteForm = false;
  bool isPICContractor = false;
  bool defaultAppBar = true;
  List<bool> isChecked = List.generate(16, (_) => false);

  AppBar appBar1() {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          'Customer Care',
          style: Constants.textAppBar3,
        ),
      ),
    );
  }

  AppBar appBar2(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          'Customer Care',
          style: Constants.textAppBar3,
        ),
      ),
      // actions: [
      //   IconButton(
      //       onPressed: () {
      //         (dateNow);
      //         settings(context);
      //       },
      //       icon: Icon(Icons.sort_outlined))
      // ],
    );
  }

  Widget itemSettingsToggle(
    String title,
    String cond1,
    String cond2,
    int index,
  ) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
                flex: 7,
                child: Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  (cond1 == '' && cond2 == '')
                      ? const SizedBox(
                          height: 4,
                        )
                      : Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cond2 == '' ? cond1 : '$cond1 - $cond2',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                ])),
            Expanded(
              flex: 1,
              child: Radio(
                  value: index,
                  groupValue: groupValue,
                  toggleable: true,
                  onChanged: (int? value) {
                    setState(() {
                      groupValue = value;
                    });
                  }),
            ),
          ],
        ));
  }

  void settings(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (context) {
          return DraggableScrollableSheet(
              expand: false,
              // snap: true,
              initialChildSize: 0.75,
              maxChildSize: 1,
              minChildSize: 0.25,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Center(
                            child: Container(
                          height: 4,
                          width: 28,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4)),
                        )),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Row(children: [
                          const Expanded(
                              child: Text(
                            'Filter By',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          )),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'Clear all',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color.fromRGBO(238, 96, 85, 1),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // log('Clicked');
                                          }),
                                  ))),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Row(children: [
                          const Expanded(
                              child: Text(
                            'Date',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          )),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'Clear',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color.fromRGBO(238, 96, 85, 1),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // log('Clicked');
                                          }),
                                  )))
                        ]),
                      ),
                      itemSettingsToggle('Today', dateNow, '', 0),
                      itemSettingsToggle('This Week', last7Date, dateNow, 1),
                      itemSettingsToggle(
                          'Last 30 Days', last30Date, dateNow, 2),
                      itemSettingsToggle(
                          'Last 60 Days', last60Date, dateNow, 3),
                      // SizedBox(height: 8,),
                      // itemSettingsToggle('Last 60 Days', last60Date, dateNow,3),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Row(children: [
                          const Expanded(
                              child: Text(
                            'Status',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          )),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'Clear',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color.fromRGBO(238, 96, 85, 1),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // log('Clicked');
                                          }),
                                  )))
                        ]),
                      ),
                      itemSettingsToggle('Submitted',
                          'Show item(s) with "Submitted" status', '', 4),
                      itemSettingsToggle('On Progress',
                          'Show item(s) with "On Progress" status', '', 5),
                      itemSettingsToggle('Completed',
                          'Show item(s) with "Completed" status', '', 6),
                      itemSettingsToggle('Cancelled',
                          'Show item(s) with "Cancelled" status', '', 7),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Row(children: [
                          const Expanded(
                              child: Text(
                            'Services',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          )),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'Clear',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color.fromRGBO(238, 96, 85, 1),
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // log('Clicked');
                                          }),
                                  )))
                        ]),
                      ),
                      itemSettingsToggle('Document Retrieval',
                          'Show list of document retrieval(s)', '', 8),
                      itemSettingsToggle('Document Submission',
                          'Show list of document submission(s)', '', 9),
                      // itemSettingsToggle('Lot Handover',
                      //     'Show list of lot handover(s)', '', 10),
                      itemSettingsToggle('Information Service',
                          'Show list of information service(s)', '', 11),
                      itemSettingsToggle('Ticket & Inquiry',
                          'Show list of ticket & inquiry(s)', '', 12),
                      itemSettingsToggle('Request & Permission',
                          'Show list of request & permission(s)', '', 13),
                      itemSettingsToggle(
                          'Handover', 'Show list of handover(s)', '', 14),
                    ],
                  ),
                );
              });
        });
  }

  @override
  void initState() {
    getBanner();
    getProfile();
    currentAppBar = appBar1();
    _tabController1 = TabController(length: 2, vsync: this);
    if (widget.data != null && widget.data['index'] != null) {
      setState(() {
        _tabController1?.index = widget.data['index'];
      });
    }
    _tabController1?.addListener(changeAppBar);
    super.initState();
  }

  void changeAppBar() {
    setState(() {
      if (_tabController1?.index == 0) {
        currentAppBar = appBar2(context);
      }
      if (_tabController1?.index == 1) {
        currentAppBar = appBar1();
      }
      // currentAppBar = appBarList[_tabController1.index];
    });
  }

  getAppointmentStatus({dynamic data}) async {
    return await http.post(data["type"] + '/appointment-status').then((res) {
      // log("masuk => ${data["type"]} = ${res["data"]["show"]}");
      if (res['success'] == true && res["data"] != null) {
        if (res["data"]["show"]) {
          setState(() {
            menu.insert(data["order"], data);
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
      // log("err ${data["type"]}");
      setState(() {
        _isLoading = false;
      });
    });
  }

//  S E T E L A H   D I P E R J E L A S ,   B A R U   I N T E G R A S I   I N I
  List listAppointment = [
    // {
    //   "order": 2,
    //   "id": 4,
    //   "title": "Lot Handover",
    //   "desc": "Kavling document submission",
    //   "imageAsset": 'assets/images/resident_care/club_house.png',
    //   "imageUrl": '',
    //   "url": "/formLotHandover",
    //   "category": 'appointment',
    //   "type": 'hand-over',
    //   "show": true,
    //   "enable": true,
    //   "enableMsg": '',
    // },
    {
      "order": 4,
      "title": "Handover",
      "desc": "Handover with Customer Care",
      "imageAsset": 'assets/images/resident_care/resident_billing.png',
      "imageUrl": '',
      "url": "/formHandover",
      "category": 'appointment',
      "type": 'hand-over',
      "show": true,
      "enable": true,
      "enableMsg": '',
    },
    {
      "order": 6,
      "title": "Ticket & Inquiry",
      "desc": "Submit your ticket to interact with CS",
      "imageAsset": 'assets/images/resident_care/document_request.png',
      "imageUrl": '',
      "url": "/formTicketInquiry",
      "category": 'appointment',
      'type': 'ticketing',
      "show": true,
      "enable": true,
      "enableMsg": '',
    },
  ];
  void getProfile() {
    http.post('profile').then((res) {
      if (res.toString() != '') {
        setState(() {
          _ipl = res['data']['ipl'];
          profile = res['data'];
          isPICContractor = res['data']['is_pic_contractor'] ?? false;
        });

        bool isResident = _ipl != '';

        setState(() {
          menu.addAll([
            //TODO uncomment ini
            // {
            //   "id": 2,
            //   "title": "Document Retrieval",
            //   "desc": "Renovation Permit Sticker, IMB, etc.",
            //   "imageAsset": 'assets/images/resident_care/resident_billing.png',
            //   "imageUrl": '',
            //   "url": "/masterAppointmentCreatePage",
            //   "category": 'appointment',
            //   "type": 'appointment',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
            // {
            //   "id": 3,
            //   "title": "Document Submission",
            //   "desc": "AJB document submission",
            //   "imageAsset": 'assets/images/resident_care/contact_management.png',
            //   "imageUrl": '',
            //   "url": "/appointmentRequisiteFormPage",
            //   "category": 'appointment',
            //   "type": 'appointment',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
            //TODO sampe sini
            // {
            //   "order": 2,
            //   "id": 4,
            //   "title": "Lot Handover",
            //   "desc": "Kavling document submission",
            //   "imageAsset": 'assets/images/resident_care/club_house.png',
            //   "imageUrl": '',
            //   "url": "/formLotHandover",
            //   "category": 'appointment',
            //   "type": 'hand-over',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
          ]);
        });

        //TODO uncomment
        // if (isResident || isPICContractor) {
        //   setState(() {
        //     menu.addAll([
        //       {
        //         "title": "Request & Permission",
        //         "desc": "Create your document request form",
        //         "imageAsset": 'assets/images/resident_care/citizen_document.png',
        //         "imageUrl": '',
        //         "url": '/requestPermissionPage',
        //         "category": '',
        //         "type": 'document-request',
        //         "show": true,
        //         "enable": true,
        //         "enableMsg": '',
        //       },
        //     ]);
        //   });
        // }

        setState(() {
          menu.addAll([
            // {
            //   "order": 4,
            //   "title": "Handover",
            //   "desc": "Handover with Customer Care",
            //   "imageAsset":
            //       'assets/images/resident_care/resident_billing.png',
            //   "imageUrl": '',
            //   "url": "/formHandover",
            //   "category": 'appointment',
            //   "type": 'hand-over',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
            //TODO uncomment
            // {
            //   "id": 1,
            //   "title": "Information Service",
            //   "desc": "Updates on data, water/IPL, etc",
            //   "imageAsset": 'assets/images/resident_care/visitor_form.png',
            //   "imageUrl": '',
            //   "url": "/masterAppointmentCreatePage",
            //   "category": 'appointment',
            //   "type": 'appointment',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
            //TODO sampe sini

            // {
            //   "order": 6,
            //   "title": "Ticket & Inquiry",
            //   "desc": "Submit your ticket to interact with CS",
            //   "imageAsset":
            //       'assets/images/resident_care/document_request.png',
            //   "imageUrl": '',
            //   "url": "/formTicketInquiry",
            //   "category": 'appointment',
            //   'type': 'ticketing',
            //   "show": true,
            //   "enable": true,
            //   "enableMsg": '',
            // },
            {
              "title": "Contact Us",
              "desc": "Contact us for further info & assistance",
              "imageAsset":
                  'assets/images/resident_care/contact_management.png',
              "imageUrl": '',
              "url": "/contactUsPage",
              "category": '',
              "type": '',
              "show": true,
              "enable": true,
              "enableMsg": '',
            },
          ]);
        });

        // setState(() {
        //   menu.addAll([
        //     {
        //       "title": "Information Service",
        //       "desc": "Updates on data, water/IPL, etc",
        //       "imageAsset": 'assets/images/resident_care/visitor_form.png',
        //       "imageUrl": '',
        //       "url": "/masterAppointmentCreatePage",
        //       "category": 'appointment',
        //       "type": 'appointment',
        //       "show": true,
        //       "enable": true,
        //       "enableMsg": '',
        //     },
        //     // {
        //     //   "id": 1,
        //     //   "title": "Ticket & Inquiry",
        //     //   "desc": "Submit your ticket to interact with CS",
        //     //   "imageAsset":
        //     //       'assets/images/resident_care/document_request.png',
        //     //   "imageUrl": '',
        //     //   "url": "/formTicketInquiry",
        //     //   "category": 'appointment',
        //     //   'type': 'ticketing',
        //     //   "show": true,
        //     //   "enable": true,
        //     //   "enableMsg": '',
        //     // },
        //     {
        //       "title": "Contact Us",
        //       "desc": "Contact us for further info & assistance",
        //       "imageAsset":
        //           'assets/images/resident_care/contact_management.png',
        //       "imageUrl": '',
        //       "url": "/contactUsPage",
        //       "category": '',
        //       "type": '',
        //       "show": true,
        //       "enable": true,
        //       "enableMsg": '',
        //     },
        //   ]);
        // });

        //TODO uncomment
        // for (int i = 0; i < listAppointment.length; i++) {
        //   setState(() {
        //     menu.insert(listAppointment[i]["order"], listAppointment[i]);
        //   });
        //   // getAppointmentStatus(
        //   //   data: listAppointment[i],
        //   // );
        // }
      }
      setState(() {
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void getBanner() {
    http.post('banner-customer-care').then((res) {
      // ('banner === $res');
      if (res.toString() != '') {
        if (res['success'] == true) {
          dynamic datagbr = res['data'];
          setState(() {
            bannerList = [];
            for (var item in datagbr) {
              bannerList.add(item);
            }
          });
        }
      }
    });
  }

  _launchWhatsappURL() async {
    String waNumber = profile['pic_customer_care_wa'];
    Uri url = ('https://wa.me/$waNumber?text=Halo%20Customer%20Care') as Uri;

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _carousel() {
    final double width = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1.0, color: Constants.colorBorder),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
                viewportFraction: 0.9,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: bannerList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () async {
                      if (i['banner_link'] != null) {
                        // const String mixpanelName = "customer-banner";
                        // final Map<String, dynamic> mixpanelValues = {
                        //   'id': i['banner_id'],
                        //   'title': i['banner_judul'],
                        // };
                        
                        // final String eventName =
                        //     "customer-banner-${i["banner_id"]}";
                        // final Map<String, dynamic> eventValues = {
                        //   "af_content_id": "0",
                        //   "af_currency": "IDR",
                        //   "af_revenue": "0"
                        // };
                        
                        Helper(context: context).pushToLogger(body: {
                          "event_name": "banner",
                          "event_values": {
                            "id": i['banner_id'],
                            "type": "banner_customer",
                            "title": i['banner_judul'] ?? "",
                          }
                        });
                        var isHttp = i['banner_link'].contains('http');
                        if (isHttp) {
                          loadingShow(context);
                          await Future.delayed(const Duration(seconds: 1));
                          //TODO
                          // Helper(context: context).launchURL(i['banner_link']);
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        } else {
                          if (i['banner_link'].toLowerCase() == "loyalty") {
                            loadingShow(context);
                            await Future.delayed(const Duration(seconds: 1));
                            //TODO
                            // Helper(context: context)
                            //     .toLoyalty(link: i['banner_link'].toLowerCase(), backToHome: true);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          } else {
                            loadingShow(context);
                            await Future.delayed(const Duration(seconds: 1));
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            //TODO
                            // Helper(context: context).openPage(i['banner_link']);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: i['banner_file'],
                        imageBuilder: (context, imageProvider) {
                          return Container(
                              margin: const EdgeInsets.only(
                                  top: 16, right: 4, left: 4, bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                                color: Colors.grey,
                              ));
                        },
                        placeholder: (context, url) =>
                            Image.asset('assets/images/loader.gif'),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 16,
          left: width * 0.1,
          child: SizedBox(
            width: width * 0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: bannerList.map((url) {
                int index = bannerList.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.7)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget tabButton(String title) {
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

  @override
  Widget build(BuildContext context) {
    // log("menu =====================> ${menu.length}");
    bool isResident = _ipl != ''; // _ipl != '';
    // List<dynamic> listMenu = _filter.text.length > 0 ? filteredMenu : menu;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, '/mainMenuPage');
        return Future.value(true);
      },
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        appBar: _tabController1!.index == 0 ? appBar1() : appBar2(context),
        body: LoadingFallback(
          isLoading: _isLoading,
          child: SafeArea(
            child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _carousel(),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: TabBar(
                          tabs: const [
                            Text(
                              "Services",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "History",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            )
                          ],
                          controller: _tabController1,
                          labelColor: const Color.fromRGBO(238, 96, 85, 1),
                          unselectedLabelColor:
                              const Color.fromRGBO(178, 178, 178, 1),
                          indicatorColor: const Color.fromRGBO(238, 96, 85, 1),
                          indicatorSize: TabBarIndicatorSize.label,
                          onTap: ((_) {
                            setState(() {
                              actionActive = !actionActive;
                            });
                          }),
                        )),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                        child: TabBarView(
                          controller: _tabController1,
                          children: [
                            CustomerCareMenu(
                              isResident: isResident,
                              menu: menu,
                              profile: profile,
                              listService: listService,
                              useRequisiteForm: useRequisiteForm,
                              resultRequisiteForm: resultRequisiteForm,
                            ),
                            CustomerCareHistory(
                              actionActive: actionActive,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  loadingShow(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter stateSetter) {
              return AlertDialog(
                backgroundColor: const Color(0xfffafbff),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.only(top: 12, bottom: 15),
                content: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12))),
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 12,
                      ),
                      Text('Mohon Tunggu....')
                    ],
                  ),
                ),
              );
            }));
  }
}
