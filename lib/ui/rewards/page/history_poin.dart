import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:appid/helper/helper.dart';
import 'package:appid/ui/rewards/page/history_widget.dart';

import '../../../component/http_service.dart';

class RiwayatPoin extends StatefulWidget {
  const RiwayatPoin({super.key});

  @override
  State<RiwayatPoin> createState() => _RiwayatPoinState();
}

class _RiwayatPoinState extends State<RiwayatPoin>
    with SingleTickerProviderStateMixin {
  int posisinav = 0, posisivoucher = 0;
  HttpService http = HttpService();
  TabController? _tabController, tabControllerVoucher;
  List dataPoin = [];
  List kategori = [
    {
      'type': ['GETTING_POINT', 'USING_POINT'],
      'name': ['Didapatkan', 'Digunakan']
    }
  ];

  void handleTabSelection() {
    if (_tabController!.indexIsChanging ||
        _tabController!.index != _tabController!.previousIndex) {
      posisinav = _tabController!.index;
      setState(() {
        getData();
      });
    }
  }

  tabKategori() {
    List<Tab> tabs = [];

    for (var j = 0; j < kategori[0]['name'].length; j++) {
      tabs.add(Tab(child: Text(kategori[0]['name'][j])));
    }

    return tabs;
  }

  getData() {
    http.post('loyalti-history',
        body: {'tab': kategori[0]['type'][posisinav]}).then((res) {
      if (res['success']) {
        setState(() {
          dataPoin = res['data'];
        });
      }
      // ("profil = $dataProfile");
    }).catchError((e) {
      Helper(context: context).alert(
        text: e.toString(),
      );
    });
  }

  viewKategori() {
    List<Widget> view = [];
    for (var i = 0; i < kategori[0]['type'].length; i++) {
      // getData(kategori[0]['type'][i]);

      view.add(
        Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: LazyLoadScrollView(
                  onEndOfPage: getData,
                  child: ListView(children: [HistoryWidget(dataPoin)]))
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
    getData();
    _tabController =
        TabController(length: kategori[0]['name'].length, vsync: this);
    _tabController?.addListener(handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Riwayat Poin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      indicatorPadding:
                          const EdgeInsets.only(left: 24, right: 24),
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
          ),
        ],
      ),
    );
  }
}
