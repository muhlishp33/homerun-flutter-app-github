// import 'dart:convert';
// import 'dart:developer';

// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as https;
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:localstorage/localstorage.dart';

String iconStar = 'assets/images/icon/new_design/Star-.png';
String verticalLine = 'assets/images/icon/new_design/vertical-line.png';

class Helper {
  Helper({required this.context});

  final BuildContext context;

  HttpService http = HttpService();

  launchURL(url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      if (url.contains("youtube")) {
        final regex = RegExp(r'.*\?v=(.+?)($|[\&])',
            caseSensitive: false, multiLine: false);
        if (regex.hasMatch(url)) {
          String videoId = regex.firstMatch(url)!.group(1) as String;
          ("videoId = $videoId");
          return Navigator.of(context)
              .pushNamed('/universalWebviewPage', arguments: videoId);
        } else {
          ("Cannot parse $url");
          return false;
        }
      }
      // ignore: deprecated_member_use
      return await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  dynamic getObjBannerLink(str) {
    var arrString = str.split('/');
    return {"type": arrString[0], "id": arrString[1]};
  }

  cekUri(String link, {bool pushToLog = false}) {
    // var deepLink = link.replaceAll("homerunapp://", "");
    // openPage(deepLink, pushToLog: pushToLog);
  }

  Widget flushbar({String? msg, bool success = false, Function? action}) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      message: msg,
      icon: Icon(
        success ? Icons.check_circle_outline : Icons.info_outline,
        size: 28.0,
        color: success ? Constants.green : Colors.red[300],
      ),
      duration: const Duration(seconds: 3),
    )..show(context).then((value) {
        if (action != null) {
          return action;
        }
      });
  }

/*
  openPage(String link, {dynamic data, bool pushToLog = false}) {
    var bannerLink = (link.contains("referrer")) ? link : link.toLowerCase();

    // if has id
    if (bannerLink.contains("/")) {
      var objDat = getObjBannerLink(bannerLink);

      bool isAppointment = isAppointmentType(objDat["type"]);
      String appointmentCreateType = isAppointmentCreateType(objDat["type"]);

      if (appointmentCreateType != 'unkown') {
        if (objDat["type"] == 'e-catalog' ||
            objDat["type"] == 'create-e-catalog') {
          toECatalog(appointmentType: appointmentCreateType, i: objDat["id"]);
        } else {
          toAppointmentCreatePage(appointmentCreateType, objDat["id"]);
        }
        return;
      } else if (isAppointment) {
        // buat entar detail

        // String navPath = getAppointmentDetailPagePath(bannerLink);
        // dynamic args = {
        //   "appointmentType": bannerLink
        // };
        // Navigator.of(context).pushNamed(navPath, arguments: args);
        // return;
      }
      if (pushToLog) {
        helper(context: context).pushToLogger(body: {
          "event_name": "push-notification",
          "event_values": {
            "id": objDat["id"],
            "type": objDat["type"],
            "title": bannerLink ?? "",
          }
        });
      }
      switch (objDat["type"]) {
        case "banner-detail":
          return toBannerDetailPage(objDat);
          break;
        case "news":
        case "berita":
          return toDetailNewsPage(objDat["id"]);
          break;
        case "news-digital-hub":
        case "berita-digital-hub":
          return toDetailNewsDigitalHubPage(objDat["id"]);
          break;
        case "digital-hub":
          return toDetailPartnerDigitalHubPage(objDat["id"]);
          break;
        case "produk":
        case "market":
          return toDetailProdukPage(objDat);
          break;
        case "forum":
        case "community":
          return toNewDetailForum(objDat["id"]);
          break;
        case "status-payment":
          return toFinishPaymentPage(objDat["id"]);
          break;
        case "voucher":
        case "loyalti":
        case "loyalty":
          return toDetailVoucherPage(objDat["id"]);
          break;
        case "around-me":
        case "city-guide":
          return toDetailCityGuidePage(objDat["id"]);
          break;
        // case "merchant":
        //   return toDetailMarketPage(objDat["id"]);
        //   break;
        case "voting-banner":
          return toVotingBanner(objDat["id"]);
          break;
        case "voting-form-banner":
          return toVotingFormBanner(objDat["id"]);
          break;
        case "merchant":
          return toDetailMarketPageNew(objDat["id"]);
        case "referrer":
          return setReferrrerData(objDat["id"]);
          break;
        case "document-request-chat":
          return toDocumentRequestChat(objDat);
          break;
        case "document-request":
          return toAppointmentTicket(objDat);
        case "onebsd":
          return toDetailSatuBSD(link);
          break;
      }
    } else {
      ("bannerLink = $bannerLink");
      if (pushToLog) {
        helper(context: context).pushToLogger(body: {
          "event_name": "push-notification",
          "event_values": {
            "id": "0",
            "type": "push-notification",
            "title": bannerLink ?? "",
          }
        });
      }
      if (isAppointmentType(bannerLink)) {
        String navPath = getAppointmentPagePath(bannerLink);
        dynamic args = {"appointmentType": bannerLink};
        Navigator.of(context).pushNamed(navPath, arguments: args);
        return;
      }

      switch (bannerLink) {
        case "resident-care":
        case "customer_care":
          Navigator.of(context).pushNamed('/customerCarePage');
          break;
        case "forum":
        case "community":
          return toForumPage();
          break;
        case "market":
        case "produk":
          return toMarketPage();
          break;
        case "resident_service":
        case "resident-service":
          return toResidentServicePage();
          break;
        case "ipl":
        case "billing":
          return toBillingPage();
          break;
        case "around-me":
        case "city-guide":
          return toCityGuidePage();
          break;
        case "profile":
          return toProfilePage();
          break;
        case "inbox":
          return Navigator.of(context).pushNamed('/inboxPage');
          break;
        case "news":
        case "berita":
        case "bulletin":
          return Navigator.of(context).pushNamed('/newsPage');
          break;
        case "voucher":
        case "loyalty":
        case "loyalti":
          return toLoyalty(link: bannerLink);
          break;
        case "emergency_number":
          return Navigator.of(context).pushNamed('/emergencyNumberPage');
          break;
        case "home":
          return Navigator.of(context).pushReplacementNamed('/mainMenuPage');
          break;
        case "document-permit":
          return Navigator.of(context)
              .pushReplacementNamed('/requestPermissionPage');
          break;
        case "facilities":
          return toFacilityBooking();
          break;
        case "puspitaloka":
          return toPuspitaLokaPage();
          break;
        case "survei":
          return toSurvey(languageCode: 'id');
          break;
        case "survey":
          return toSurvey(languageCode: 'en');
          break;
        case "post-survei":
          return toPostSurvey(languageCode: 'id');
          break;
        case "post-survey":
          return toPostSurvey(languageCode: 'en');
          break;
        case "beacon":
          return toBeacon();
          break;
        case "document-permission":
          return toRequestPermission();
          break;
        case "payment-web":
          return toPaymentWeb();
          break;
      }
    }
  }
*/
  pushToLogger({dynamic body}) async {
    http.post("logger-banner", body: body).then((res) {}).catchError((err) {});
  }

  // setReferrrerData(referrer) async {
  //   LocalStorage storage = new LocalStorage('homerunapp');
  //   storage.setItem("referrer", referrer);
  // }

  // setMemberChannelDownload(String value) async {
  //   LocalStorage storage = new LocalStorage('homerunapp');
  //   storage.setItem("member_channel_download", value);
  // }

  // toPaymentWeb() async {
  //   final LocalStorage storage = new LocalStorage('homerunapp');
  //   if (storage != null &&
  //       storage.getItem("authKey") != null &&
  //       storage.getItem("authKey") != "") {
  //     String url =
  //         "https://api.onesmile.digital/digital-product?X-Auth-Token=${storage.getItem("authKey")}";
  //     return openWebview(url: url);
  //   }
  // }

  // toBeacon() async {
  //   return Navigator.of(context).pushNamed(
  //     '/beaconPage',
  //   );
  // }

  // toSurvey({String languageCode}) async {
  //   return Navigator.of(context).pushNamed(
  //     '/surveyPage',
  //     arguments: languageCode,
  //   );
  // }

  // toPostSurvey({String languageCode}) async {
  //   return Navigator.of(context).pushNamed(
  //     '/postSurvey',
  //     arguments: languageCode,
  //   );
  // }

  // toRequestPermission() async {
  //   return Navigator.of(context).pushNamed('/requestPermissionPage');
  // }

  // void createRoomChat({String recepientId, dynamic msgData}) {
  //   final body = {"room_type": 5, "recipient_id": recepientId};
  //   http.post('generalmessagecreate', body: body).then((res) {
  //     ('cinta $res');
  //     if (res['success']) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => AppointmentConversationPage(
  //             roomId: res['response']['room_id'],
  //             receipentId: recepientId,
  //             data: msgData,
  //           ),
  //         ),
  //       );
  //     } else {}
  //   }).catchError((e) {});
  // }

  // toDocumentRequestChat(data) async {
  //   log('toDocumentRequestChat === ${data}');
  //   String receiptId = data['id'].toUpperCase();

  //   createRoomChat(
  //     recepientId: receiptId,
  //     msgData: {"content": ""},
  //   );
  // }

  // toAppointmentTicket(data) {
  //   log('toDocumentRequestTicket $data');
  //   var tmp = {
  //     'appointment_id': data['id'],
  //     'appointmentType': data['type'],
  //   };
  //   return Navigator.of(context).pushNamed(
  //     '/masterAppointmentDetailPage',
  //     arguments: tmp,
  //   );
  // }

  // toSurveyPoc2({languageCode}) async {
  //   String _languageCode = languageCode;

  //   Navigator.pushNamed(context, '/surveyGeneralPoc2',
  //       arguments: _languageCode);
  // }

  // toFacilityBooking() async {
  //   return Navigator.of(context).pushNamed('/facilityBookingPage');
  // }

  // toPuspitaLokaPage() async {
  //   return Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => FacilityBookingMainMenuPage(dataFacility: {
  //                 'client_type': 'FACILITY-PUSPITALOKA',
  //                 'name': 'Puspitaloka',
  //                 'code': 'facility-puspitaloka-manage',
  //               }, prefix: "facility/")));
  // }

  // Future openGmaps(double latitude, double longitude) async {
  //   String googleUrl =
  //       'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  //   if (await canLaunch(googleUrl)) {
  //     await launch(googleUrl);
  //   } else {
  //     throw 'Could not open the map.';
  //   }
  // }

  // toBannerDetailPage(data) async {
  //   ("masuk sini = $data");
  //   return Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BannerDetailPage(
  //         data: data,
  //       ),
  //     ),
  //   );
  // }

  // toPdfViewerPage(data) async {
  //   return Navigator.of(context)
  //       .pushNamed('/pdfViewerPage', arguments: data)
  //       .then((value) {});
  // }

  // toLoyalty({String link, bool backToHome = false, initialIndex = 0}) async {
  //   var bannerLink = link.toString().toLowerCase();
  //   if (bannerLink.contains("/")) {
  //     var objDat = getObjBannerLink(bannerLink);
  //     dynamic data;
  //     http.post("voucher-detail", body: {"code": objDat['id']}).then((res) {
  //       if (res['success']) {
  //         data = res['data'];
  //         toDetailLoyaltyPage(data: data);
  //       }
  //     });
  //   } else {
  //     return Navigator.of(context).pushReplacement(MaterialPageRoute(
  //         builder: (context) => MainMenuPage(
  //               indexTab: 3,
  //             )));
  //   }
  // }

  // toDetailLoyaltyPage({bool backToHome = false, dynamic data}) async {
  //   var tmpData = {"data": data, "from_page": "loyalti"};
  //   Navigator.of(context)
  //       .pushNamed('/voucherDetailPage', arguments: tmpData)
  //       .then((value) {});
  // }

  // toLoyaltyPage({bool backToHome = true}) async {
  //   return Navigator.of(context).pushNamed('/loyalty').then((value) {
  //     if (backToHome) return toMainMenuPage();
  //   });
  // }

  // toVoucherPage({initialIndex = 0, bool backToHome = false}) {
  //   return Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => HomePageReward(initialIndex: initialIndex)),
  //   );
  // }

  // toMainMenuPage() async {
  //   return Navigator.of(context).pushReplacementNamed("/mainMenuPage");
  // }

  // toDetailForum(data) async {
  //   // var newData = Forum(
  //   //     id: data['id'],
  //   //     judul: data['judul'],
  //   //     isi: data['isi'],
  //   //     gbr: data['gbr'],
  //   //     cluster: data['cluster'],
  //   //     kategori: data['kategori'],
  //   //     tgl: data['tgl'],
  //   //     tgl2: data['tgl2'],
  //   //     pinned: data['pinned'],
  //   //     edit: data['edit'],
  //   //     komentar: data['komentar']);
  //   // return Navigator.of(context)
  //   //     .pushNamed('/detailforumPage', arguments: newData);
  //   ('data com ke dtail: $data');
  //   Navigator.of(context)
  //       .pushNamed('/detailThreadCommunityPage', arguments: data);
  // }

  toFinishPaymentPage(id) {
    var data = {"id": id};
    return Navigator.pushNamed(context, '/selesaiBayarUniLinkPage',
        arguments: data);
  }

  toVotingBanner(id) async {
    return Navigator.of(context).pushNamed(
      '/votingBannerPage',
      arguments: id,
    );
  }

  toVotingFormBanner(id) async {
    return Navigator.of(context).pushNamed(
      '/votingFormBannerPage',
      arguments: id,
    );
  }

  toDetailVoucherPage(id) async {
    bool status = false;
    dynamic data;
    await http.post('voucher-detail', body: {"id": id}).then((res) {
      if (res['success']) {
        status = true;
        data = res['data'];
      }
    });
    if (status) {
      var tmpData = {"data": data, "from_page": "loyalti"};
      return Navigator.of(context)
          .pushNamed('/voucherDetailPage', arguments: tmpData)
          .then((value) {});
    }
    return status;
  }

  toDetailPartnerDigitalHubPage(id) async {
    bool status = false;
    dynamic data;

    await http
        .post('getdigitalhubbusinessdirectory', body: {'id': id}).then((res) {
      if (res['success']) {
        status = true;
        data = res['msg'];
      }
    });
    if (status) {
      return Navigator.of(context)
          .pushNamed('/detailPartnerPageHub', arguments: data)
          .then((value) {});
    }
    return status;
  }

  toNewDetailForum(id) async {
    bool status = false;
    dynamic data;
    await http.post('getforumdetail', body: {"id": id}).then((res) {
      if (res['success']) {
        status = true;
        data = res['msg'];
      }
    });
    if (status) {
      return Navigator.of(context)
          .pushNamed('/detailThreadCommunityPage', arguments: data);
    }
    return status;
  }

  // toECatalog({String appointmentType, String i}) {
  //   return http.post('gethome').then((res) {
  //     if (res.toString() != null) {
  //       if (res['success'] == true) {
  //         String ipl = '';
  //         ipl = res['msg']['ipl'];
  //         if (ipl != null && ipl != "") {
  //           return toAppointmentCreatePage(appointmentType, i);
  //         }
  //         return Alert(
  //           style: AlertStyle(
  //             isCloseButton: true,
  //           ),
  //           context: context,
  //           //type: AlertType.,
  //           title: "Oops!",
  //           content: Column(
  //             children: [
  //               Text(
  //                 "Silahkan aktivasi IPL atau Gabung Keluarga untuk bisa mengakses menu ini",
  //                 style: TextStyle(fontSize: 18),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //           buttons: [
  //             DialogButton(
  //               child: Text(
  //                 "Aktivasi",
  //                 style: TextStyle(color: Colors.white, fontSize: 12),
  //               ),
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 final res =
  //                     await Navigator.of(context).pushNamed('/aktivasiiplPage');
  //                 if (res != null) {
  //                   ipl = res;
  //                 }
  //               },
  //               color: Colors.red,
  //             ),
  //             DialogButton(
  //               padding: const EdgeInsets.symmetric(vertical: 6),
  //               child: Text(
  //                 "Gabung",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Colors.white, fontSize: 12),
  //               ),
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 await Navigator.pushNamed(context, '/gabungKeluargaPage');
  //               },
  //               color: Colors.red,
  //             ),
  //           ],
  //         ).show();
  //       } else {
  //         Navigator.pushReplacementNamed(context, '/loginPage');
  //       }
  //     }
  //   });
  // }

  // toAppointmentCreatePage(String appointmentType, String i) {
  //   int id = int.parse(i);
  //   String _endpointPrefix = getAppointmentEndpointPrefix(appointmentType);
  //   String navPath = getAppointmentCreatePagePath(appointmentType);

  //   http.post(_endpointPrefix + 'get-service-appointment').then((res) {
  //     ('DEEP-LINK res service $res');

  //     if (res['success'] == true) {
  //       List data = res['data'];
  //       dynamic objSelected;

  //       for (var i = 0; i < data.length; i++) {
  //         if (data[i]['id'] == id) {
  //           objSelected = data[i];
  //         }
  //       }
  //       if (objSelected != null) {
  //         Navigator.of(context).pushNamed(navPath, arguments: {
  //           // ...res['data'][0],
  //           ...objSelected,
  //           'appointmentType': appointmentType,
  //         });
  //       }
  //     }
  //   }).catchError((err) {
  //     ('DEEP-LINK err service $err');
  //   });
  // }

  // toDetailNewsPage(id) async {
  //   await http.post('getnews',
  //       body: {"sf": 0, "search": "", "tags": "", "id": id}).then((res) {
  //     if (res.toString() != null) {
  //       if (res['success'] == true) {
  //         if (res['msg'].length > 0) {
  //           var data = res['msg'] as List;
  //           data = data.map((rawPost) {
  //             ('rawPost10 $rawPost');
  //             return News(
  //               judul: rawPost['judul'],
  //               isi: rawPost['isi'],
  //               tgl: rawPost['tgl'],
  //               link: rawPost['link'],
  //               author: rawPost['author'],
  //               editor: rawPost['editor'],
  //               tag: rawPost['tag'],
  //               isi2: rawPost['isi2'],
  //               last: rawPost['last'],
  //               photo: rawPost['photo'],
  //               photo2: rawPost['photo2'],
  //               photo3: rawPost['photo3'],
  //               totalLike: rawPost['total_like'],
  //               totalComment: rawPost['total_comment'],
  //             );
  //           }).toList();
  //           Navigator.of(context)
  //               .pushNamed('/detailnewsPage', arguments: data[0]);
  //         }
  //       }
  //     }
  //   });
  // }

  // toDetailNewsDigitalHubPage(id) async {
  //   http.post('digital-hub-getnews',
  //       body: {"sf": 0, "search": "", "tags": "", "id": id}).then((res) {
  //     if (res.toString() != null) {
  //       if (res['success'] == true) {
  //         if (res['msg'].length > 0) {
  //           var data = res['msg'] as List;
  //           data = data.map((rawPost) {
  //             // ('rawPost $rawPost');
  //             return News(
  //                 judul: rawPost['judul'],
  //                 isi: rawPost['isi'],
  //                 tgl: rawPost['tgl'],
  //                 link: rawPost['link'],
  //                 author: rawPost['author'],
  //                 editor: rawPost['editor'],
  //                 tag: rawPost['tag'],
  //                 isi2: rawPost['isi2'],
  //                 last: rawPost['last'],
  //                 photo: rawPost['photo'],
  //                 photo2: rawPost['photo2'],
  //                 photo3: rawPost['photo3']);
  //           }).toList();
  //           Navigator.of(context)
  //               .pushNamed('/detailhubnewsPage', arguments: data[0]);
  //         }
  //       }
  //     }
  //   });
  // }

  // toProfilePage() async {
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //       builder: (context) => MainMenuPage(
  //             indexTab: 4,
  //           )));
  // }

  toCityGuidePage() async {
    Navigator.of(context).pushNamed('/buisinessdirectoryPage');
  }

  // toDetailCityGuidePage(id) async {
  //   await http
  //       .post('getbusinessdirectory', body: {"id": id, "sf": 0}).then((res) {
  //     if (res['success'] && res['msg'].length > 0) {
  //       final data = BusinessDirectory(
  //         id: res['msg'][0]['id'],
  //         nama: res['msg'][0]['nama'],
  //         desk: res['msg'][0]['desk'],
  //         kategori: res['msg'][0]['kategori'],
  //         hari: res['msg'][0]['hari'],
  //         jam: res['msg'][0]['jam'],
  //         alamat: res['msg'][0]['alamat'],
  //         telepon: res['msg'][0]['telepon'],
  //         long: res['msg'][0]['long'],
  //         lat: res['msg'][0]['lat'],
  //         status: res['msg'][0]['status'],
  //         desk2: res['msg'][0]['desk2'],
  //         tgl: res['msg'][0]['tgl'],
  //         gbr: res['msg'][0]['gbr'],
  //         keterangan_buka: res['msg'][0]['keterangan_buka'],
  //         sosmed: res['msg'][0]['sosmed'],
  //         sosmed_instagram: res['msg'][0]['sosmed_instagram'],
  //         sosmed_twitter: res['msg'][0]['sosmed_twitter'],
  //         sosmed_facebook: res['msg'][0]['sosmed_facebook'],
  //         sosmed_youtube: res['msg'][0]['sosmed_youtube'],
  //         shareLink: res['msg'][0]['share_link'],
  //       );
  //       return Navigator.of(context)
  //           .pushNamed('/detailbusinessdirectoryPage', arguments: data);
  //     }
  //   });
  // }

  toMarketPage() async {
    Navigator.of(context).pushNamed('/mainMenuMarket');
    // Navigator.of(context).pushNamed('/newMarket2Page');
    // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Market2MainMenu()));
  }

  // Future getHome() {
  //   return http.post('gethome').then((res) {
  //     if (res['success'] == true) {
  //       setInstanceString("homeData", json.encode(res['msg']));
  //     }
  //   });
  // }

  // Future alertIpl() {
  //   return Alert(
  //     style: AlertStyle(
  //       isCloseButton: true,
  //     ),
  //     context: context,
  //     //type: AlertType.,
  //     title: "Oops!",
  //     content: Column(
  //       children: [
  //         Text(
  //           "Silahkan aktivasi IPL atau Gabung Keluarga untuk bisa mengakses menu ini",
  //           style: TextStyle(fontSize: 18),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //     buttons: [
  //       DialogButton(
  //         child: Text(
  //           "Aktivasi",
  //           style: TextStyle(color: Colors.white, fontSize: 12),
  //         ),
  //         onPressed: () async {
  //           Navigator.of(context).pop();
  //           final res =
  //               await Navigator.of(context).pushNamed('/aktivasiiplPage');
  //           if (res != null) {
  //             getHome();
  //             // ipl = res;
  //           }
  //         },
  //         color: Colors.red,
  //       ),
  //       DialogButton(
  //         padding: const EdgeInsets.symmetric(vertical: 6),
  //         child: Text(
  //           "Gabung",
  //           textAlign: TextAlign.center,
  //           style: TextStyle(color: Colors.white, fontSize: 12),
  //         ),
  //         onPressed: () async {
  //           Navigator.of(context).pop();
  //           await Navigator.pushNamed(context, '/gabungKeluargaPage');
  //         },
  //         color: Colors.red,
  //       ),
  //     ],
  //   ).show();
  // }

  // toResidentServicePage() async {
  //   dynamic homeData;
  //   String ipl;
  //   Future getHomeData = getInstanceString('homeData');
  //   getHomeData.then((value) {
  //     if (value != null) {
  //       homeData = json.decode(value);
  //       ipl = homeData["ipl"];
  //       ("ipl = $ipl");
  //       if (ipl == null || ipl == "") {
  //         return alertIpl();
  //       }
  //       Navigator.of(context).pushNamed('/residentServicePage');
  //     }
  //   });
  // }

  // toBillingPage() async {
  //   dynamic profile;
  //   await http.post('profile').then((res) {
  //     if (res['success']) {
  //       profile = res['data'];
  //     }
  //   }).catchError((e) {});
  //   if (profile != null && profile['cluster_joined'] == true) {
  //     return toResidentServicePage();
  //   }
  //   return Navigator.of(context).pushNamed('/iplMainPage');
  // }

  toForumPage() async {
    Navigator.of(context).pushNamed('/communityPage');
  }

  toSatuBsdPage() async {
    Navigator.of(context).pushNamed('/facilitySatuBSD');
  }

  Future alert({
    // ignore: prefer_equal_for_default_values
    text: "",
  }) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    return Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> share({
    title: 'Example share',
    text: 'Example share text',
    linkUrl: 'https://flutter.dev/',
    chooserTitle: 'Example Chooser Title',
  }) async {
    await FlutterShare.share(
      title: title,
      text: text,
      linkUrl: linkUrl,
      chooserTitle: chooserTitle,
    );
  }

  Future viewPhoto({url, heroTag}) async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                size: 36,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Hero(
            tag: heroTag,
            child: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: PhotoView(
                imageProvider: NetworkImage(url),
                loadingBuilder: (context, event) {
                  if (event == null) {
                    return const Center(
                      child: Text("Loading"),
                    );
                  }

                  final value = event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? event.cumulativeBytesLoaded);

                  final percentage = (100 * value).floor();
                  return Center(
                    child: Text("$percentage%"),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // toDetailProdukPage(objDat) async {
  //   dynamic dat = {
  //     'produk_id': objDat['id'],
  //     'banner_link': true,
  //   };
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => BlocProvider<DetailprodukBloc>(
  //         create: (context) => DetailprodukBloc(dat),
  //         child: DetailProdukPageNew(data: dat),
  //       ),
  //     ),
  //   );
  // }

}
