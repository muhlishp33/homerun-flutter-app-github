import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:appid/ui/auth_login/otp_confirm.dart';
import 'package:appid/ui/services/service_order_confirmation.dart';
import 'package:appid/ui/services/service_order_detail.dart';
import 'package:appid/ui/services/service_order_payment.dart';
import 'package:appid/ui/services/service_order_review.dart';
import 'package:appid/ui/services/service_order_result.dart';
import 'package:appid/ui/services/services.dart';
import 'package:appid/ui/universal_map.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:appid/ui/customer_care/contact_us.dart';
import 'package:appid/ui/customer_care/revamp/customer_care_revamp.dart';
import 'package:appid/ui/inbox/notification.dart';
import 'package:appid/ui/inbox/notification_detail.dart';

import 'package:appid/ui/profil/alamat/add_address.dart';
import 'package:appid/ui/profil/aktivasi_ipl.dart';
import 'package:appid/ui/profil/aktivasi_kontraktor.dart';
import 'package:appid/ui/profil/alamat/daftar_alamat_page.dart';
import 'package:appid/ui/profil/atur_kode_keluarga.dart';
import 'package:appid/ui/profil/change_email.dart';
import 'package:appid/ui/profil/change_nomor_hp.dart';
import 'package:appid/ui/profil/change_password.dart';
import 'package:appid/ui/profil/edit_profil1.dart';
import 'package:appid/ui/profil/info_profil1.dart';
import 'package:appid/ui/profil/kode_kontraktor.dart';
import 'package:appid/ui/profil/kode_referral.dart';
import 'package:appid/ui/profil/tambah_akun.dart';
import 'package:appid/ui/profil/tenants.dart';
import 'package:appid/ui/transaksi/data_tranksaksi.dart';
import 'package:appid/ui/transaksi/detail_transaksi.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:appid/component/Theme.dart';
import 'package:appid/helper/analytics.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/auth_login/forgot_password.dart';
import 'package:appid/ui/auth_login/login1.dart';
import 'package:appid/ui/auth_login/login_otp.dart';
import 'package:appid/ui/auth_login/register.dart';
import 'package:appid/ui/auth_login/syarat_ketentuan.dart';
import 'package:appid/ui/auth_login/faq.dart';
import 'package:appid/ui/inbox/detail_inbox.dart';
import 'package:appid/ui/inbox/inbox.dart';
import 'package:appid/ui/main_menu.dart';
import 'package:appid/ui/no_page.dart';
import 'package:appid/ui/onboarding.dart';
import 'package:appid/ui/splash_static.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails =
    const NotificationAppLaunchDetails(true);

class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: TargetPlatform.iOS == defaultTargetPlatform ? null : 'homerunapp',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppTrackingTransparency.requestTrackingAuthorization();

  notificationAppLaunchDetails = (await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails())!;

  // Wait for dialog popping animation
  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    didReceiveLocalNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload));
  }

  void selectNotification(String? payload) async {
    log('notification payload: $payload');
    selectNotificationSubject.add(payload!);
  }

  String navigationActionId = 'id_3';

  notificationAppLaunchDetails = (await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails())!;
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: initializationSettingsDarwin);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationSubject.add(notificationResponse.payload ?? '');
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationSubject.add(notificationResponse.payload ?? '');
          }
          break;
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _notificationsEnabled = false;
  dynamic notificationDetail;
  AppsflyerSdk? _appsflyerSdk;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKeys = GlobalKey<NavigatorState>();
  Future<void> _isAndroidPermissionGranted() async {
    if (TargetPlatform.android == defaultTargetPlatform) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (TargetPlatform.iOS == defaultTargetPlatform || TargetPlatform.macOS == defaultTargetPlatform) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (TargetPlatform.android == defaultTargetPlatform) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      log('receivedNotification $receivedNotification');
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      log('notificationDetail $notificationDetail');
      if (notificationDetail != null) {
        handleDeepLink(notificationDetail);
      }
      // await navigatorKey.currentState.pushNamed('/soonPage');
    });
  }

  bool checkTitleNotif(RemoteMessage message) {
    bool isValidNotif = false;

    if (
        // Platform.isAndroid &&
        message.notification != null && message.notification?.title != null) {
      isValidNotif = true;
      // } else if (Platform.isIOS &&
      //     message['aps'] != null &&
      //     message['aps']['alert'] != null &&
      //     message['aps']['alert']['title'] != null) {
      //   isValidNotif = true;
    }

    return isValidNotif;
  }

  Future<void> _showNotification(RemoteMessage data) async {
    String imgBitMapIOS = '';
    String imgBitMapAndroid = '@mipmap/ic_launcher';

    // if (Platform.isIOS && data.notification.apple.imageUrl != null) {
    //   _imgBitMapIOS = await _downloadAndSaveFile(
    //       data.notification.apple.imageUrl, 'imgNotif.png');
    // }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'one-smile-12f3f', //data.notification.android.channelId,
      'One Smile',
      channelDescription: 'OS Notification',
      icon: imgBitMapAndroid,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      largeIcon: DrawableResourceAndroidBitmap(imgBitMapAndroid),
    );

    var iOSPlatformChannelSpecifics = imgBitMapIOS == ''
        ? const DarwinNotificationDetails()
        : DarwinNotificationDetails(attachments: <DarwinNotificationAttachment>[
            DarwinNotificationAttachment(imgBitMapIOS)
          ]);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // if (Platform.isIOS) {
    //   await flutterLocalNotificationsPlugin.show(
    //       0,
    //       data['aps']['alert']['title'],
    //       data['aps']['alert']['body'],
    //       platformChannelSpecifics,
    //       payload: '');
    // }

    // if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.show(
      data.notification.hashCode,
      data.notification?.title,
      data.notification?.body,
      platformChannelSpecifics,
      // payload: ''
    );
    // }
  }

  void fcmInitialize() async {
    // final permissionIOS = await _fcm.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));

    final permissionIOS = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        sound: true);

    if (permissionIOS.authorizationStatus == AuthorizationStatus.authorized ||
        permissionIOS.authorizationStatus == AuthorizationStatus.provisional ||
        TargetPlatform.android == defaultTargetPlatform) {

      // _fcm.getToken().then((token) {
      //   log("firebase token: $token");
      //   setInstanceString('tokenFcm', token ?? '');
      //   if (Platform.isAndroid || Platform.isIOS) {
      //     // ios need apns token
      //     _appsflyerSdk?.updateServerUninstallToken(token ?? '');
      //   }
      // });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        bool isValidNotif = checkTitleNotif(message);

        // const String eventName = "notification-received";
        // final Map<String, dynamic> eventValues = {
        //   "af_content_id": "20",
        //   "af_currency": "IDR",
        //   "af_revenue": "0",
        // };

        log('isValidNotif $isValidNotif');

        if (isValidNotif) {
          _showNotification(message);
          setState(() {
            notificationDetail = message;
          });
        }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        log("onLaunch: $message");
        bool isValidNotif = checkTitleNotif(message);

        // const String eventName = "notification-view";
        // final Map<String, dynamic> eventValues = {
        //   "af_content_id": "21",
        //   "af_currency": "IDR",
        //   "af_revenue": "0",
        // };

        if (isValidNotif) {
          Timer(const Duration(seconds: 4), () {
            handleDeepLink(message);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    fcmInitialize();
  }

  @override
  void dispose() {
    super.dispose();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
  }

  void handleDeepLink(RemoteMessage message) async {
    String link = 'onesmile://${message.data['path']}';
    // String link = Platform.isAndroid
    //     ? 'onesmile://' + message.data['path']
    //     : 'onesmile://' + message['path'];
    log("link ================> ${message.data['path'] == 'None'}");
    if (message.data['path'] != "None") {
      // final String eventName = "push-notif ${message.data['path']}";
      // final Map<String, dynamic> eventValues = {
      //   "af_content_id": "0",
      //   "af_currency": "IDR",
      //   "af_revenue": "0"
      // };

      // const String mixpanelName = "push-notif";
      // final Map<String, dynamic> mixpanelValues = {
      //   'path': message.data['path'],
      //   'title': "PUSH_NOTIF",
      // };
    }
    Helper(context: navigatorKey.currentContext!).cekUri(link, pushToLog: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: navigatorKeys,
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeNotifier>(context).currentThemeData,
      initialRoute: '/splashScreen',
      routes: routes,
      onGenerateRoute: _generateRoute,
      navigatorKey: navigatorKey,
    );
  }

  dynamic routes = {
    '/': (BuildContext context) => const NoPage(),
    '/splashScreen': (BuildContext context) => const SplashStatic(),
    '/onboarding': (BuildContext context) => const OnBoarding(),
    '/loginPage': (BuildContext context) => const LoginOtpPage(),
  };

  Route _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // FIRST PAGE
      case '/splashScreen':
        return MaterialPageRoute(builder: (context) => const SplashStatic());
      case '/loginPassPage':
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case '/register2Page':
        return MaterialPageRoute(
            builder: (context) => Register2Page(settings.arguments));
      case '/otpConfirmPage':
        return MaterialPageRoute(
            builder: (context) => OtpConfirmPage(settings.arguments));
      case '/forgotpasswordPage':
        return MaterialPageRoute(
            builder: (context) => const ForgotpasswordPage());
      case '/syaratKetentuanPage':
        return MaterialPageRoute(
            builder: (context) => const SyaratKetentuanPage());
      case '/faqPage':
        return MaterialPageRoute(
            builder: (context) => const FaqPage());
      //Profile
      case '/changePasswordPage':
        return MaterialPageRoute(
            builder: (context) => ChangePasswordPage(settings.arguments));
      // map
      case '/universalMapPage':
        return MaterialPageRoute(
            builder: (context) => UniversalMapPage(settings.arguments));
      
      // inbox
      case '/inboxPage':
        return MaterialPageRoute(builder: (context) => const InboxPage());
      case '/detailInboxPage':
        return MaterialPageRoute(
            builder: (context) => DetailInboxPage(settings.arguments));

      // transaction
      case '/dataTransaksiPage':
        return MaterialPageRoute(
            builder: (context) => const DataTransaksiPage());
      case '/detailTransactionPage':
        return MaterialPageRoute(
            builder: (context) => DetailTransactionPage(settings.arguments));
      // home
      case '/mainMenuPage':
        return MaterialPageRoute(builder: (context) => MainMenuPage());
      // info profile
      case '/infoProfilPage':
        return MaterialPageRoute(
            builder: (context) => InfoProfilPage(settings.arguments));
      case '/editProfilPage':
        return MaterialPageRoute(
            builder: (context) => EditProfilPage(settings.arguments));
      case '/changeNoHp':
        return MaterialPageRoute(
            builder: (context) => const ChangeNoHandponePage());
      case '/changeEmail':
        return MaterialPageRoute(builder: (context) => const ChangeEmailPage());
      case '/daftarAlamatPage':
        return MaterialPageRoute(
            builder: (context) => const DaftarAlamatPage());
      case '/aktivasiiplPage':
        return MaterialPageRoute(builder: (context) => const AktivasiiplPage());
      case '/aktivasiKontraktor':
        return MaterialPageRoute(
            builder: (context) => const AktivasiKontraktor());
      case '/kodeKontraktorPage':
        return MaterialPageRoute(
            builder: (context) => const KodeKontraktorPage());

      // customer care
      case '/customerCarePage':
        return MaterialPageRoute(
            builder: (context) => CustomeCareRevPage(settings.arguments));
      case '/contactUsPage':
        return MaterialPageRoute(
            builder: (context) => ContactUsPage(settings
                .arguments)); //CustomerCareRevPage // CustomerCarePage);

      // daftar alamat
      case '/addAddressPage':
        return MaterialPageRoute(builder: (context) => AddAddressPage(settings.arguments));

      // ipl
      case '/tambahAkunPage':
        return MaterialPageRoute(
            builder: (context) => TambahAkunPage(settings.arguments));

      // notification
      case '/notificationPage':
        return MaterialPageRoute(
            builder: (context) => const NotificationPage());
      case '/notificationDetailPage':
        return MaterialPageRoute(
            builder: (context) => NotificationDetailPage(settings.arguments));

      // keluarga
      case '/kodeReferralPage':
        return MaterialPageRoute(
            builder: (context) => KodeReferralPage(settings.arguments));
      case '/aturKodeKeluargaPage':
        return MaterialPageRoute(
            builder: (context) => AturKodeKeluargaPage(settings.arguments));

      // pengurus
      case '/tenantsPage':
        return MaterialPageRoute(
            builder: (context) => TenantsPage(settings.arguments));

      // services
      case '/servicesPage':
        return MaterialPageRoute(
            builder: (context) => ServicesPage(settings.arguments));
      case '/serviceOrderConfirmationPage':
        return MaterialPageRoute(
            builder: (context) => ServiceOrderConfirmationPage(settings.arguments));
      case '/serviceOrderDetailPage':
        return MaterialPageRoute(
            builder: (context) => ServiceOrderDetailPage(settings.arguments));
      case '/serviceOrderPaymentPage':
        return MaterialPageRoute(
            builder: (context) => ServiceOrderPaymentPage(settings.arguments));
      case '/serviceOrderResultPage':
        return MaterialPageRoute(
            builder: (context) => const ServiceOrderResultPage());
      case '/serviceOrderReviewPage':
        return MaterialPageRoute(
            builder: (context) => ServiceOrderReviewPage(settings.arguments));

      default:
        return MaterialPageRoute(builder: (context) => const NoPage());
    }
  }
}
