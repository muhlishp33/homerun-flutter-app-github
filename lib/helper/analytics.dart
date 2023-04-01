import 'dart:developer';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:appid/component/shared_preferences.dart';
import 'package:appid/component/widget/constants.dart';

class AuthEventName {}

class ResidentServiceEventName {
  static String banner = 'resident-banner';
  static String ipl = 'resident-ipl';
  static String residentBilling = 'resident-billing';
  static String contactManagement = 'resident-contact';
  static String clubHouse = 'resident-club-house';
  static String visitor = 'resident-visitor';
  static String rtrw = 'resident-rtrw';
  static String citizenDocument = 'resident-citizen-document';
  static String forum = 'resident-forum';
  static String clusterComplain = 'resident-complain';
}

class CustomerCareEventName {
  static String banner = 'cs-banner';
  static String appointment = 'cs-drive-thru';
  static String ticketing = 'cs-ticketing';
  static String handOver = 'cs-hand-over';
  static String documentRequest = 'cs-document-request';
  static String openWhatsapp = 'cs-whatsapp';
  static String contactUs = 'cs-contact';
  static String emergencyNumber = 'cs-emergency';
}

Future<void> pushMixPanel<T>({
  required String eventName,
  required Map<String, dynamic> eventValues,
}) async {
  // if (await AppTrackingTransparency.trackingAuthorizationStatus ==
  //         TrackingStatus.authorized ||
  //     await AppTrackingTransparency.trackingAuthorizationStatus ==
  //         TrackingStatus.notDetermined) {
  //   // Show a custom explainer dialog before the system dialog
  //   Mixpanel mixpanel = await Mixpanel.init(
  //     Constants.mixpanelProjectToken,
  //     optOutTrackingDefault: Constants.mixpanelOptOutTrackingDefault,
  //     trackAutomaticEvents: false,
  //   );

  //   String uid = await getInstanceString('uid');
  //   String name = await getInstanceString('nama');
  //   String email = await getInstanceString('email');

  //   if (uid == '') uid = '0';

  //   mixpanel.identify(uid);
  //   mixpanel.getPeople().set('Name', name);
  //   if (email != '') {
  //     mixpanel.getPeople().set('Email', email);
  //   }
  //   mixpanel.track(eventName, properties: eventValues);

  //   log('mixpanel >> uid: $uid, name: $name, email: $email}');
  // }
}

Future<bool> pushAppsFlyer<T>({
  required String eventName,
  required Map<String, dynamic> eventValues,
}) async {
  // if (await AppTrackingTransparency.trackingAuthorizationStatus ==
  //         TrackingStatus.authorized ||
  //     await AppTrackingTransparency.trackingAuthorizationStatus ==
  //         TrackingStatus.notDetermined) {
  //   // Show a custom explainer dialog before the system dialog
  //   bool result = false;

  //   result = (await AppsflyerSdk(Constants.appsflyerOptions)
  //       .logEvent(eventName, eventValues))!;
  //   log('appsflyer >> event: $eventName, result: $result');
  //   return result ? true : false;
  // }
  return false;
}
