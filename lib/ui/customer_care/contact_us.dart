import 'dart:developer';

import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage(this.data, {super.key});

  final dynamic data;
  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String picClusterPhone = '';
  final HttpService http = HttpService();
  dynamic profile;
  List<dynamic> customerCare = [
    {
      "title": "Email",
      "subtitle": "Proses Aspirasi dan Keluhan melalui Email",
      "imageUrl": "assets/images/icon/email.png",
      "eventName": "email",
    },
    {
      "title": "Phone Call",
      "subtitle": "Proses Aspirasi dan Keluhan melalui Telepon",
      "imageUrl": "assets/images/icon/phone.png",
      "eventName": "call",
    },
    {
      'title': 'WhatsApp',
      'subtitle': 'Chat on WhatsApp with Our Customer Care Service',
      'imageUrl': 'assets/images/icon/whatsapp.png',
      'eventName': CustomerCareEventName.openWhatsapp
    },
    // {
    //   "title": "Contact Security Office",
    //   "subtitle": "Proses Aspirasi dan Keluhan melalui Telepon",
    //   "imageUrl": "assets/images/icon/phone.png"
    // },
  ];
  _launchWhatsappURL() async {
    String waNumber = profile['pic_customer_care_wa'];
    String url = 'https://wa.me/$waNumber?text=Halo%20Customer%20Care';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
      // log("masuk");
    } else {
      throw 'Could not launch $url';
    }
  }

  void getProfile() {
    http.post('profile').then((res) {
      if (res.toString() != '') {
        setState(() {
          profile = res['data'];
        });

        if (profile != null && profile['pic_cluster_email'] != null) {
          _emailLaunchUri = Uri(
              scheme: 'mailto',
              path: profile['pic_cluster_email'],
              queryParameters: {'subject': '[ONESMILE]'});
        }

        picClusterPhone =
            profile != null && profile['pic_cluster_phone'] != null
                ? profile['pic_cluster_phone']
                : '';
      }
    });
  }

  final List redirectAction = ['/liveChatPage'];

  Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'customer.care@sinarmasland.com',
      queryParameters: {'subject': '[ONESMILE]'});

  @override
  void initState() {
    super.initState();
    getProfile();
    // setState(() {
    //   if (widget.data != null && widget.data['pic_cluster_email'] != null) {
    //     _emailLaunchUri = Uri(
    //         scheme: 'mailto',
    //         path: widget.data['pic_cluster_email'],
    //         queryParameters: {'subject': '[ONESMILE]'});
    //   }

    //   picClusterPhone =
    //       widget.data != null && widget.data['pic_cluster_phone'] != null
    //           ? widget.data['pic_cluster_phone']
    //           : '';
    // });
  }

  onTapMenu({String eventName = ''}) {
    // final Map<String, dynamic> eventValues = {
    //   "af_content_id": "11",
    //   "af_currency": "IDR",
    //   "af_revenue": "0"
    // };
    
    switch (eventName) {
      case "email":
        return launchUrlString(
            _emailLaunchUri.toString().replaceAll("+", "%20"));
      case "call":
        return launchUrlString("tel:$picClusterPhone");
      case "cs-whatsapp":
        return _launchWhatsappURL();
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ('widget.data');

    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Contact Us',
            style: Constants.textAppBar3,
          ),
        ),
        elevation: 0.2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var index = 0; index < customerCare.length; index++)
                    GestureDetector(
                      onTap: () {
                        //TODO
                        // Helper(context: context).pushToLogger(body: {
                        //   "event_name": "contact_us",
                        //   "event_values": {
                        //     "id": 0,
                        //     "type": "contact_us_menu",
                        //     "title": customerCare[index]['title'] ?? "",
                        //   }
                        // });
                        onTapMenu(eventName: customerCare[index]["eventName"]);
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          leading: Container(
                            height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.1,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF2F2F6)),
                            child: Center(
                              child: Image(
                                image:
                                    AssetImage(customerCare[index]['imageUrl']),
                                fit: BoxFit.contain,
                                height:
                                    MediaQuery.of(context).size.width * 0.075,
                                width:
                                    MediaQuery.of(context).size.width * 0.075,
                              ),
                            ),
                          ),
                          title: Text(customerCare[index]['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              )),
                          subtitle: Text(customerCare[index]['subtitle'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA1A4B2),
                              )),
                          trailing: const Icon(Icons.chevron_right),
                        ),
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
