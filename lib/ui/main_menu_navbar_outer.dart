import 'package:appid/component/widget/constants.dart';
import 'package:flutter/material.dart';
import 'package:appid/ui/bnb_awesome/navbar_inspired_outside.dart';
import 'package:appid/ui/bnb_awesome/inspired.dart';
import 'package:appid/ui/bnb_awesome/tab_item.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/api/api_profile.dart';

import 'package:appid/ui/home/home4.dart';
import 'package:appid/ui/profil/profil1.dart';
import 'package:appid/ui/activity/activity.dart';
import 'package:appid/ui/subscription/subscription.dart';

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
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();
  dynamic profile;
  HttpService http = HttpService();
  ApiProfile apiProfile = ApiProfile();

  List<TabItem> items = [
    TabItem(
      iconActiveAsset: iconHomeActive,
      iconInactiveAsset: iconHome,
      title: 'Home',
    ),
    TabItem(
      iconActiveAsset: iconMyRewardActive,
      iconInactiveAsset: iconMyReward,
      title: 'Activity',
    ),
    TabItem(
      iconActiveAsset: iconInboxActive,
      iconInactiveAsset: iconInbox,
      title: 'Subscription',
    ),
    TabItem(
      iconActiveAsset: iconProfileActive,
      iconInactiveAsset: iconProfile,
      title: 'Account',
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: listBottomPage[_selectedIndex],
      bottomNavigationBar: Container(
        child: BottomBarInspiredOutside(
          items: items,
          backgroundColor: Constants.colorWhite,
          color: Constants.colorCaption,
          colorSelected: Constants.colorWhite,
          indexSelected: _selectedIndex,
          onTap: (int index) => setState(() {
            _selectedIndex = index;
          }),
          top: -38,
          animated: true,
          radius: 16.0,
        ),
      ),
    );
  }
}