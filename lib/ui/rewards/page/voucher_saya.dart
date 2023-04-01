import 'package:flutter/material.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/ui/rewards/all/card_all_voucher.dart';

class VoucherSayaPage extends StatefulWidget {
  const VoucherSayaPage({super.key});

  @override
  State<VoucherSayaPage> createState() => _VoucherSayaPageState();
}

class _VoucherSayaPageState extends State<VoucherSayaPage>
    with SingleTickerProviderStateMixin {
  int posisinav = 0, posisivoucher = 0;
  bool loading = true;
  TabController? _tabController, tabControllerVoucher;
  HttpService http = HttpService();

  List kategori = [
    {
      'type': ['ACTIVE', 'USED', 'EXPIRED'],
      'name': ['Aktif', 'Digunakan', 'Kedaluwarsa']
    }
  ];

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
            child: CardAllVoucherSaya(kategori[0]['type'][i]),
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
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: false,
          title: const Text(
            'Voucher Saya',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          )),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: TabBar(
                labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
                labelColor: const Color(0xffee6055),
                indicatorColor: const Color(0xffee6055),
                unselectedLabelColor: const Color(0xffd9d9d9),
                unselectedLabelStyle: const TextStyle(
                    color: Color(0xffb2b2b2),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins'),
                controller: _tabController,
                tabs: 3 > 0 ? tabKategori() : []
                //kategoriHub.length > 0 ? tabKategori() : [],
                ),
          ),
          Flexible(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: TabBarView(
                  controller: _tabController,
                  children: 3 > 0
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
