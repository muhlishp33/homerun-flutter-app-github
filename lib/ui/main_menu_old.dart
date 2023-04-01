import 'dart:developer';

import 'package:appid/ui/activity/activity.dart';
import 'package:appid/ui/subscription/subscription.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/component/shared_preferences.dart';
// import 'package:appid/component/widget/AppNotification.dart';
import 'package:appid/helper/analytics.dart';
// import 'package:appid/ui/home/home4.dart';
// import 'package:appid/ui/profil/modal_qr_code.dart';
// import 'package:appid/ui/profil/profil1.dart';
// import 'package:appid/ui/marketplace/my_reward.dart';
// import 'package:appid/ui/profil/qrcode_scanner.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/ui/home/home4.dart';
import 'package:appid/ui/profil/profil1.dart';
import 'package:appid/ui/inbox/inbox.dart';
import 'package:appid/ui/rewards/home_reward.dart';
import 'package:flutter/services.dart';
// import 'package:appid/ui/rewards/home_reward.dart';
import 'package:appid/api/api_profile.dart';

String iconHome = 'assets/images/nav-bottom/home.png';
String iconHomeActive = 'assets/images/nav-bottom/home_active.png';

String iconInbox = 'assets/images/nav-bottom/subscription.png';
String iconInboxActive = 'assets/images/nav-bottom/subscription_active.png';

String iconMyReward = 'assets/images/nav-bottom/activity.png';
String iconMyRewardActive = 'assets/images/nav-bottom/activity_active.png';

String iconProfile = 'assets/images/nav-bottom/profile.png';
String iconProfileActive = 'assets/images/nav-bottom/profile_active.png';

final List<Widget> listBottomPage = [
  const HomePage(),
  const ActivityPage(),
  const SubscriptionPage(),
  const ProfilPage(),
];

class MainMenuPage extends StatefulWidget {
  final int indexTab;

  const MainMenuPage({super.key, this.indexTab = 0});

  @override
  MainMenuPageState createState() => MainMenuPageState();
}

class MainMenuPageState extends State<MainMenuPage> {
  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();
  dynamic profile;
  HttpService http = HttpService();
  ApiProfile apiProfile = ApiProfile();

  // int inboxCount = 0;

  @override
  void initState() {
    if (widget.indexTab != null && widget.indexTab != 0) {
      setState(() {
        _selectedIndex = widget.indexTab;
      });
    }
    
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // home exclude
    if (index != 0) {
      // log('index page = $index');
      await apiProfile.fetchProfile();
    }
    
    // dynamic objBubble = await getInstanceJson('bubble');

    // setState(() {
    //   inboxCount =
    //     objBubble['notification'] != null
    //     && objBubble['notification'] is int ? objBubble['notification'] : objBubble['notification'] is String ? objBubble['notification'] : 0; 
    // });
  }

  Widget widgetGuidedMenu() {
    const double menusHeight = 55.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: Constants.colorBorder, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: menusHeight, width: menusHeight),
          SizedBox(key: keyButton3, height: menusHeight, width: menusHeight),
          const SizedBox(height: menusHeight, width: menusHeight),
          SizedBox(key: keyButton5, height: menusHeight, width: menusHeight),
          const SizedBox(height: menusHeight, width: menusHeight),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 104.0,
          child: BottomNavigationBar(
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(color: Constants.redTheme),
            selectedItemColor: Constants.redTheme,
            // backgroundColor: Colors.red,
            type: BottomNavigationBarType.fixed,
            elevation: 0.0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              // Home
              BottomNavigationBarItem(
                icon: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Image.asset(
                    _selectedIndex == 0 ? iconHomeActive : iconHome,
                    height: 24,
                  ),
                ),
                label: 'Home',
              ),

              // Activity
              BottomNavigationBarItem(
                icon: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Image.asset(
                    _selectedIndex == 1
                        ? iconMyRewardActive
                        : iconMyReward,
                    height: 24,
                  ),
                ),
                label: 'Activity',
              ),
              
              // Inbox
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Image.asset(
                        _selectedIndex == 2 ? iconInboxActive : iconInbox,
                        height: 24,
                      ),
                    ),
                    
                    // count notif
                    // if (inboxCount > 0) Positioned(
                    //   top: 0,
                    //   right: 0,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       vertical: 1.7,
                    //       horizontal: 3.4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: _selectedIndex == 2 ? Constants.colorSecondary : Constants.redTheme,
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Text(
                    //       inboxCount.toString(),
                    //       style: TextStyle(
                    //         color: _selectedIndex == 2 ? Constants.colorTitle : Constants.colorWhite,
                    //         fontSize: 8,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                label: 'Subscription',
              ),

              // Profile
              BottomNavigationBarItem(
                icon: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Image.asset(
                    _selectedIndex == 3 ? iconProfileActive : iconProfile,
                    height: 24,
                  ),
                ),
                label: 'Account',
              ),
            ],
          ),
        ),
        body: listBottomPage[_selectedIndex],
      ),
    );
  }
}
