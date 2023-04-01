import 'dart:developer';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

Future<bool> pushGALogEvent<T>({
  required String eventName,
  required Map<String, dynamic> eventValues,
}) async {
  if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.authorized ||
      await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    // FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    await analytics.logEvent(
      name: eventName,
      parameters: eventValues,
    );
    // log('firebase analytics logEvent: $eventName');
    return true;
  }
  return false;
}

Future<bool> pushGASignUp<T>({
  String method = 'email',
}) async {
  if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.authorized ||
      await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    // FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    await analytics.logSignUp(
      signUpMethod: method
    );
    // log('firebase analytics logSignUp: $method');
    return true;
  }
  return false;
}

Future<bool> pushGALogin<T>({
  String method = 'email',
}) async {
  if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.authorized ||
      await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    // FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    await analytics.logLogin(
      loginMethod: method
    );
    // log('firebase analytics logLogin: $method');
    return true;
  }
  return false;
}