import 'package:flutter/material.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/ui/rewards/all/card_misi_all.dart';

class MisiPage extends StatefulWidget {
  const MisiPage({super.key});

  @override
  State<MisiPage> createState() => _MisiPageState();
}

class _MisiPageState extends State<MisiPage>
    with SingleTickerProviderStateMixin {
  int posisinav = 0, posisivoucher = 0;
  bool loading = true;
  TabController? _tabController, tabControllerVoucher;
  HttpService http = HttpService();
  List kategori = [
    {
      'type': ['ACTIVE', 'HISTORY'],
      'name': ['Aktif', 'Selesai']
    }
  ];

  // void _callGetKategori() {
  //   for (var i = 0; i < kategori[0]['type'].length; i++) {}
  // }

  void handleTabSelection() {
    if (_tabController!.indexIsChanging ||
        _tabController!.index != _tabController!.previousIndex) {
      posisinav = _tabController!.index;
      setState(() {});
    }
  }

  tabKategori() {
    List<Tab> tabs = [];

    for (var j = 0; j < kategori[0]['name'].length; j++) {
      tabs.add(Tab(child: Text(kategori[0]['name'][j])));
    }

    return tabs;
  }

  viewKategori() {
    List<Widget> view = [];
    for (var i = 0; i < kategori[0]['type'].length; i++) {
      view.add(
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CardMisiAll(kategori[0]['type'][i]),
            //child: AllPartnerWidget(id: kategoriHub[i]['id']),
          ),
        ),
      );
    }
    return view;
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: kategori[0]['name'].length, vsync: this);
    _tabController?.addListener(handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    (kategori[0]['name'][1]);
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: false,
          title: const Text(
            'Misi Saya',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          )),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: TabBar(
                labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
                labelColor: const Color(0xffee6055),
                indicatorPadding: const EdgeInsets.only(left: 24, right: 24),
                indicatorColor: const Color(0xffee6055),
                unselectedLabelColor: const Color(0xffd9d9d9),
                unselectedLabelStyle: const TextStyle(
                    color: Color(0xffb2b2b2),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
                controller: _tabController,
                tabs: 2 > 0 ? tabKategori() : []
                //kategoriHub.length > 0 ? tabKategori() : [],
                ),
          ),
          Flexible(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: TabBarView(
                  controller: _tabController,
                  children: 2 > 0
                      // kategoriHub.length > 0
                      ? viewKategori()
                      : [
                          // SingleChildScrollView(child: gridAllPartner()),
                        ]),
            ),
          ),
        ],
      ),
    );
  }
}
