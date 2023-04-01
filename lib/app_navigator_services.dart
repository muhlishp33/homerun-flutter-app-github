// This is only to give rough overview of the structure of the fix.

// allow usage of navigator without context if the need arise
import 'package:flutter/material.dart';

abstract class AppNavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // static Future<dynamic>? appPushNamed(String routeName) {
  //   log('route by navigatorKey: $routeName');
  //   return AppNavigatorService.navigatorKey.currentState?.pushNamed(routeName);
  // }

  // static Future<dynamic>? appPushReplacementNamed(String routeName) {
  //   log('route by navigatorKey: $routeName');
  //   return AppNavigatorService.navigatorKey.currentState?.pushReplacementNamed(routeName);
  // }

  // static void appPop() {
  //   log('route by navigatorKey pop');
  //   return AppNavigatorService.navigatorKey.currentState?.pop();
  // }
}