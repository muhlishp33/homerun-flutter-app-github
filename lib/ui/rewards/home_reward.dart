import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';
import 'package:intl/intl.dart';
import 'package:appid/ui/rewards/empty_state_loyalty.dart';
import 'package:appid/ui/rewards/front/card_beli_voucher.dart';
import 'package:appid/ui/rewards/front/card_search_voucher.dart';
import 'package:appid/ui/rewards/front/widget_voucher_saya.dart';
import 'package:appid/ui/rewards/page/shimmer_reward.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../component/widget/app_notification.dart';

class HomePageReward extends StatefulWidget {
  dynamic initialIndex;

  HomePageReward({this.initialIndex});
  @override
  State<HomePageReward> createState() => _HomePageRewardState();
}

class _HomePageRewardState extends State<HomePageReward>
    with SingleTickerProviderStateMixin {
  int posisinav = 0, posisivoucher = 0;
  bool loading = true;
  TabController? _tabController, tabControllerVoucher;
  HttpService http = HttpService();
  dynamic dataProfile;
  int startIndex = 0;
  List<dynamic> listData = [], listDataVoucherSaya = [];
  bool isEnd = false;
  bool isReady = false;
  String query = '';
  List misiSaya = [], listMisi = [];
  TextEditingController _voucherCode = TextEditingController();
  TextEditingController searchVoucher = new TextEditingController();
  String cariData = '';
  bool search = false;
  List searchView = [];
  bool loadingVoucher = false;
  bool refresh = false;
  bool loadingList = true, loadingVouchers = true, loadingMember = true;

  void handleTabSelection() {
    if (_tabController!.indexIsChanging ||
        _tabController!.index != _tabController!.previousIndex) {
      posisinav = _tabController!.index;
      setState(() {});
    }
  }

  void handleTabSelectionVoucher() {
    if (tabControllerVoucher!.indexIsChanging ||
        tabControllerVoucher!.index != tabControllerVoucher!.previousIndex) {
      posisivoucher = tabControllerVoucher!.index;
      setState(() {});
    }
  }

  claimData() {
    http.post('daily-login').then((value) {
      if (value['success']) {
        // setState(() {
        //   helper(context: context).alert(text: 'Berhasil klaim');
        // });

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Text(
                        "Berhasil Klaim",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        _getProfile();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
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
      } else {
        // helper(context: context).alert(text: value['msg'].toString());
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Text(
                        value['msg'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        _getProfile();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
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
    }).catchError((e) {
      Helper(context: context).alert(text: e.toString());
    });
  }

  List<dynamic> memberBenefits = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (refresh) {
      _getProfile();
      memberBenefit();
      _getData();
      _getDataVocuherSaya();
    }
  }

  void memberBenefit() {
    http.post("member-benefits").then((res) {
      // ("member-benefits = $res");

      if (res["success"]) {
        setState(() {
          memberBenefits = res["data"];
          loadingMember = false;
        });
      }
      if (res["success"] == false) {
        showAppNotification(
            context: context,
            title: 'gagal',
            desc: res["msg"].toString(),
            onSubmit: () {});
      }
    }).catchError((e) {
      showAppNotification(
          context: context,
          title: 'Gagal',
          desc: e.toString(),
          onSubmit: () {});
    });
  }

  tabKategori() {
    List<Tab> tabs = [];
    for (var i = 0; i < 2; i++) {
      tabs.add(Tab(
          child: Text('Aktif'
              // kategoriHub[i]['name'],
              )));
    }
    return tabs;
  }

  _getProfile() {
    http.post('profile').then((res) {
      if (res['success']) {
        setState(() {
          dataProfile = res['data'];
          loading = false;
        });
      }
      // ("profil = $dataProfile");
    }).catchError((e) {
      Helper(context: context).alert(
        text: e.toString(),
      );
    });
    http.post('loyalty-highlight').then((res) {
      if (res['success']) {
        setState(() {
          misiSaya = res['data'];
          loading = false;
        });
      }
      // ("profil = $dataProfile");
    }).catchError((e) {
      Helper(context: context).alert(
        text: e.toString(),
      );
    });
    http.post('loyalty-my-mission').then((res) {
      if (res['success']) {
        setState(() {
          listMisi = res['data'];
          loading = false;
        });
      }
      // ("profil = $dataProfile");
    }).catchError((e) {
      Helper(context: context).alert(
        text: e.toString(),
      );
    });
  }

  void allKategoriVoucher() {
    final node = FocusScope.of(context);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.999,
        maxChildSize: 1,
        minChildSize: 0.999,
        builder: (context, scrollController) => StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 60, left: 24, right: 24),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.arrow_back_ios)),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Voucher',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void viewBenefit(index, member) {
    final node = FocusScope.of(context);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.35,
        maxChildSize: 0.5,
        minChildSize: 0.35,
        builder: (context, scrollController) => StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 24, right: 24),
                        child: Container(
                          width: 28,
                          height: 4,
                          color: Color(0xffe5e5e5),
                        )),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Text(
                      'Manfaat Member $member',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: memberBenefits[index]['benefits'].length,
                      itemBuilder: (context, snap) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        '${memberBenefits[index]['benefits'][snap]['image_url']}',
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Color(0xffee6055),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: imageProvider,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/loader.gif',
                                      scale: 14,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffee6055),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.white,
                                              ),
                                            )),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          memberBenefits[index]['benefits']
                                              [snap]['name'],
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                            memberBenefits[index]['benefits']
                                                [snap]['descriptin'],
                                            style: TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _getDataVocuherSaya({bool isSearch = false}) async {
    var body = {
      "search": _voucherCode.text,
      "sf": listData.length,
      'tab': 'ACTIVE'
    };

    http.post('my-voucher-list', body: body).then((res) {
      if (res['success']) {
        setState(() {
          listDataVoucherSaya.addAll(res['data']);
          loadingVouchers = false;
        });
      }
    });
  }

  _getData({int limit = 10, bool isSearch = false}) async {
    if (isSearch) {
      setState(() {
        isReady = false;
      });
    }
    var body = {
      "sf": startIndex,
      "limit": limit,
      "type": null,
      "category": null,
      "query": query
    };
    ("body = $body");
    http.post('voucher-list', body: body).then((res) {
      ("res = ${res['data'].length}");
      if (res['success']) {
        setState(() {
          listData.addAll(res['data']);
          startIndex = startIndex + res['data'].length as int;
          loadingList = false;
        });
      }
      setState(() {
        isReady = true;
        if (res['data'].length == 0) {
          isEnd = true;
        }
      });
    }).catchError((e) {
      setState(() {
        isReady = true;
        isEnd = true;
      });
    });
  }

  getDataSearch() {
    var body = {
      "search": searchVoucher.text,
    };
    setState(() {
      loadingVoucher = true;
    });
    http.post('search-voucher', body: body).then((res) {
      if (res['success']) {
        setState(() {
          searchView = res['data'];
          loadingVoucher = false;
        });
      }
    });
  }

  Widget _profileSection({data, i}) {
    // ("data = ${data}");

    final double width = MediaQuery.of(context).size.width;

    return Container(
      width: width - 30,
      margin:
          EdgeInsets.fromLTRB((i == 1) ? 7.5 : 15, 15, (i == 1) ? 7.5 : 15, 0),
      child: InkWell(
        onTap: () {
          var tmp = data;
          tmp["index"] = i;
          Navigator.pushNamed(context, '/myBenefitPage', arguments: tmp);
        },
        child: Stack(
          children: [
            Container(
              child: CachedNetworkImage(
                imageUrl: data['image_card'].toString(),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                          colorFilter: ColorFilter.mode(
                              const Color(0x000000).withOpacity(0),
                              BlendMode.darken)),
                    ),
                  );
                },
                placeholder: (context, url) =>
                    Image.asset('assets/images/loader.gif'),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      data["label"].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            child: CachedNetworkImage(
                              imageUrl: data['image_coin'].toString(),
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.fill,
                                        colorFilter: ColorFilter.mode(
                                            const Color(0x000000)
                                                .withOpacity(0),
                                            BlendMode.darken)),
                                  ),
                                );
                              },
                              placeholder: (context, url) =>
                                  Image.asset('assets/images/loader.gif'),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        Container(
                          child: Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      data["label_balance"].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                      data['need_point_label'] is String
                                          ? data['need_point_label']
                                          : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Container(
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.5) *
                                                    (data["detail_rank"][
                                                            "member_current_progress"] /
                                                        100),
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: Colors.yellow,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      data["detail_rank"]["progress_label"],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 7),
                child: Text(
                  "View Benefits",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget EmptyState(BuildContext context) {
    return Column(
      children: [Image.asset('assets/images/loyalti/tickets.png')],
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfile();
    memberBenefit();
    _getData();
    _getDataVocuherSaya();
    _tabController = TabController(length: 2, vsync: this);
    _tabController?.addListener(handleTabSelection);
  }

  Widget searchVoucherView() {
    return loadingVoucher
        ? Center(
            child: Image.asset('assets/images/loader.gif',
                height: 100.0, width: 100),
          )
        : CardSearchVoucher(searchView);
  }

  Widget searchable() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  fillColor: Colors.grey[200],
                  hintText: 'Search Voucher'),
              controller: searchVoucher,
              onChanged: (value) {
                setState(() {
                  cariData = value;
                });
              },
              onFieldSubmitted: (value) {
                getDataSearch();
              },
            ),
          ),
          SizedBox(
            width: 24,
          ),
          InkWell(
            onTap: () {
              setState(() {
                search = false;
                cariData = '';
                searchVoucher.text = '';
                searchView = [];
              });
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Color(0xffee6055),
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  void _onRefresh() async {
    bool isRefresh1 = false;
    setState(() {
      loading = true;
      loadingList = true;
      loadingMember = true;
      loadingVouchers = true;
    });

    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _getProfile();
    memberBenefit();
    _getData();
    _getDataVocuherSaya();
    if (loading) {
      _refreshController.refreshCompleted();
    } else if (loading == false ||
        loadingList == false ||
        loadingMember == false ||
        loadingVouchers == false) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    (dataProfile);
    return WillPopScope(
      onWillPop: () {
        return widget.initialIndex != null
            ? Future.value(true)
            : Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: search
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: searchable(),
                )
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              widget.initialIndex != null
                                  ? new IconButton(
                                      icon: new Icon(Icons.chevron_left,
                                          size: 36, color: Colors.black),
                                      tooltip: "Kembali",
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    )
                                  : Container(),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Hadiah Saya',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (search == true) {
                                      search = false;
                                    } else {
                                      search = true;
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/riwayatPoinPage');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Image.asset(
                                    'assets/images/icon/transaction_minus.png',
                                    width: 24,
                                  ),
                                ),
                              )
                            ],
                          )
                        ]),
                  ),
                ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Color(0xffe5e5e5e5),
              )),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: search
            ? searchVoucherView()
            : loading && dataProfile == null
                ? ShimmerRewards()
                : SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            height: 186,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: memberBenefits.length,
                              itemBuilder: (context, snap) {
                                double right = 0.0;
                                if (memberBenefits[snap] ==
                                    memberBenefits.last) {
                                  right = 20.0;
                                } else {
                                  right = 0;
                                }
                                var label_member = memberBenefits[snap]['label']
                                    .split('Member')
                                    .first
                                    .split('One Smile')
                                    .last;
                                (label_member);
                                return Padding(
                                  padding:
                                      EdgeInsets.only(left: 20, right: right),
                                  child: InkWell(
                                    onTap: () {
                                      viewBenefit(snap, label_member);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.87,
                                      decoration: BoxDecoration(
                                        gradient: memberBenefits[snap]
                                                    ['label'] ==
                                                'Basic Member'
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.topRight,
                                                colors: [
                                                    Color(0xffed6868),
                                                    Color(0xffee6055),
                                                  ])
                                            : memberBenefits[snap]['label'] ==
                                                    'Silver Member'
                                                ? LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.topRight,
                                                    colors: [
                                                        Color(0xff8a9a9a),
                                                        Color(0xff9ba1ab),
                                                      ])
                                                : memberBenefits[snap]
                                                            ['label'] ==
                                                        'Gold Member'
                                                    ? LinearGradient(
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment.topLeft,
                                                        colors: [
                                                            Color(0xfff08f00),
                                                            Color(0xffe9672d),
                                                          ])
                                                    : RadialGradient(
                                                        focalRadius: 2,
                                                        center:
                                                            Alignment.topLeft,
                                                        focal: Alignment
                                                            .bottomLeft,
                                                        colors: [
                                                            Color(0xffee6055),
                                                            Color(0xfff08f00),
                                                            Color(0xffee6055),
                                                            Color(0xffee6055),
                                                          ]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .white)),
                                                      child: dataProfile !=
                                                                  null &&
                                                              dataProfile[
                                                                      'photo'] !=
                                                                  null &&
                                                              dataProfile[
                                                                      'photo'] !=
                                                                  ''
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              child: Image.network(
                                                                  '${dataProfile['photo']}'),
                                                            )
                                                          : CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      200],
                                                              radius: 50,
                                                              child: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .userAlt,
                                                                  color: Constants
                                                                      .redTheme),
                                                            ),
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Selamat siang,',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          dataProfile != null
                                                              ? '${dataProfile['nama']}'
                                                              : '',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white),
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: Image.asset(
                                                      'assets/images/icon/medal_basic.png'),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 19,
                                            ),
                                            Text(
                                              'Kamu adalah',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Member ${memberBenefits[snap]['label'].split('Member').first.split('One Smile').last}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                ),
                                                Text(
                                                  '${memberBenefits[snap]['need_point_label']}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 7,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.3),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width) *
                                                              (memberBenefits[snap]
                                                                          [
                                                                          "detail_rank"]
                                                                      [
                                                                      "member_current_progress"] /
                                                                  100),
                                                          height: 7,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Expanded(
                                            //   child: Container(
                                            //     margin: EdgeInsets.only(top: 8),
                                            //     child: Text(
                                            //       'Koleksi sebanyak ${memberBenefits[snap]['detail_rank']['progress_label'].split('points').first}poin sebelum 31 Desember 2021 untuk menjadi Member Silver.',
                                            //       //'data["detail_rank"]["progress_label"]',
                                            //       style: TextStyle(
                                            //         color: Colors.white,
                                            //         fontSize: 12,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                          ]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          offset: Offset(0, 4),
                                          blurRadius: 20,
                                          spreadRadius: 0)
                                    ]),
                                padding: const EdgeInsets.all(12),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: misiSaya.length,
                                  itemBuilder: (context, snap) {
                                    return Column(children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xffee6055)),
                                            padding: const EdgeInsets.all(6),
                                            child: Image.network(
                                                '${misiSaya[snap]['image_url']}'),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${misiSaya[snap]['label']}',
                                                  style: TextStyle(
                                                      color: Color(0xff828382),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Text(
                                                  '${misiSaya[snap]['caption_label']}',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                    ]);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Misi Saya',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  InkWell(
                                    onTap: listMisi.isEmpty
                                        ? () {}
                                        : () {
                                            Navigator.pushNamed(
                                              context,
                                              '/daftarMisi',
                                            );
                                          },
                                    child: Text(
                                      listMisi.isEmpty ? '' : 'Lihat Semua',
                                      style: TextStyle(
                                          color: Color(0xffee6055),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // WidgetMisi(listMisi),
                              listMisi.isEmpty
                                  ? EmptyStateLoyalty(
                                      'Anda tidak Memiliki Misi saat ini')
                                  : Container(
                                      height: 320,
                                      child: ListView.builder(
                                        itemCount: listMisi.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, snap) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/detailMisiPage',
                                                  arguments: listMisi[snap]
                                                      ['id']);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    height: 300,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: Color(
                                                                0xffe5e5e5))),
                                                    child: Stack(
                                                      children: [
                                                        Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              AspectRatio(
                                                                aspectRatio:
                                                                    16 / 6,
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      '${listMisi[snap]['image_url']}',
                                                                  imageBuilder:
                                                                      (context,
                                                                          imageProvider) {
                                                                    return Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(12),
                                                                            topRight: Radius.circular(12)),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              imageProvider,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Image.asset(
                                                                          'assets/images/loader.gif'),
                                                                  errorWidget: (context, url, error) => Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                          100,
                                                                      child: Icon(
                                                                          Icons
                                                                              .error)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${listMisi[snap]['header_label']}',
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w800,
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Dapatkan ${NumberFormat.currency(locale: 'id', decimalDigits: 0).format(listMisi[snap]['get_point']).split('IDR').last} Point',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 12),
                                                                        ),
                                                                        Text(
                                                                          '${listMisi[snap]['status_label'].toString()}',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 12),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 16,
                                                                    right: 16,
                                                                    bottom: 16),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height: 7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(7),
                                                                        color: Color(
                                                                            0xfff5f5f5),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: (MediaQuery.of(context).size.width *
                                                                              0.65) *
                                                                          (listMisi[snap]["progress"] /
                                                                              listMisi[snap]["total_progress"]),
                                                                      height: 7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(7),
                                                                        color: Color(
                                                                            0xffee6055),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 11,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (listMisi[snap]
                                                                            [
                                                                            'category'] ==
                                                                        'DAILY_LOGIN') {
                                                                      claimData();
                                                                    } else {
                                                                      if (listMisi[snap]
                                                                              [
                                                                              'path'] !=
                                                                          null) {
                                                                        // Helper(context: context).openPage(listMisi[snap]
                                                                        //     [
                                                                        //     'path']);
                                                                      }

                                                                      // Navigator.pushNamed(
                                                                      //   context,
                                                                      //   '/${dataMisi['path']}',
                                                                      // );
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        color: Color(
                                                                            0xffee6055)),
                                                                    child: Center(
                                                                        child: Text(
                                                                      '${listMisi[snap]['button_label']}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w800),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Voucher Saya',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/daftarVoucherSaya',
                                      );
                                    },
                                    child: Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                          color: Color(0xffee6055),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CardVoucherSaya(listDataVoucherSaya, 'ACTIVE'),
                              SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Klaim Voucher',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/daftarVoucher',
                                      );
                                    },
                                    child: Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                          color: Color(0xffee6055),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CardBeliVoucher(listData)
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
