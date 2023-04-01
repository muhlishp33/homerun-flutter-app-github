import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/http_service.dart';
import 'package:appid/component/widget/LoadingOverlayWidget.dart';
import 'package:appid/component/widget/constants.dart';
import 'package:appid/helper/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KodeKontraktorPage extends StatefulWidget {
  const KodeKontraktorPage({Key? key}) : super(key: key);

  @override
  State<KodeKontraktorPage> createState() => _KodeKontraktorPageState();
}

class _KodeKontraktorPageState extends State<KodeKontraktorPage> {
  HttpService http = HttpService();
  dynamic _referralCode;
  List _listContractor = [];
  dynamic profile;
  bool isLoading = true;
  bool isLoadingProfile = true;

  showAlertDialog({index, id}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/warning-2.png',
                  width: 100,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Perhatian',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Anda ingin menghapus kontraktor ?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Constants.redTheme,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Center(
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        removeContractor(index: index, id: id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Constants.redTheme),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Center(
                          child: Text(
                            'Iya',
                            style: TextStyle(
                              color: Constants.redTheme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getReferralCode() {
    http.post('pic-contractor-referral').then(
      (res) async {
        if (res['success']) {
          _referralCode = await res['data'];
          isLoading = false;
          setState(() {});
        }
      },
    );
  }

  getProfile() {
    http.post('profile').then((res) async {
      if (res.toString() != null) {
        if (res['success'] == true) {
          setState(() {
            isLoadingProfile = false;
            profile = res['data'];
          });
        }
      }
    });
  }

  getListContractor() {
    http.post('list-contractor').then(
      (res) async {
        if (res['success']) {
          _listContractor = await res['data'];
          setState(() {});
        }
      },
    );
  }

  removeContractor({index, id}) {
    Map<String, dynamic> body = {
      'id': id,
    };
    http.post('remove-contractor', body: body).then(
      (res) async {
        isLoading = true;
        setState(() {});

        if (res['success']) {
          _listContractor.removeAt(index);
          Helper(context: context)
              .flushbar(msg: 'Kontraktor berhasil di hapus', success: true);
        } else {
          Helper(context: context).flushbar(msg: 'Kontraktor gagal di hapus');
        }
        Future.delayed(const Duration(milliseconds: 800), () {
          isLoading = false;
          setState(() {});
        });
      },
    ).catchError((error) => Helper(context: context).flushbar(msg: error));
  }

  copyQr(qrData) {
    Clipboard.setData(ClipboardData(text: qrData)).then(
      (value) => Helper(context: context)
          .flushbar(msg: 'Kode Qr berhasil disalin', success: true),
    );
  }

  getData() async {
    await getProfile();
    await getReferralCode();
    await getListContractor();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await getData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingFallback(
      isLoading: isLoading || isLoadingProfile,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        color: Colors.black,
        iconSize: 32,
        icon: const Icon(
          Icons.chevron_left,
        ),
      ),
      title: const Text(
        'Kode Kontraktor',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        _buildHeaderTitle(),
        _buildQrCode(),
        _buildContractorList(),
      ],
    );
  }

  Widget _buildHeaderTitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: const Text(
        'Kode Kontraktor',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderSubtitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text:
                  'Tunjukkan kode ini kepada kontraktor Anda. Kode akan diperbarui setiap 5 menit sekali. ',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: 'Pelajari lebih lanjut',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.redTheme,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => ('click'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCode() {
    var heigth = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    String cluster = '';
    String alamat = '';

    if (profile != null) {
      cluster = profile['cluster'];
      alamat = profile['alamat'];
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      width: double.infinity,
      height: heigth * 0.45,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Constants.redTheme,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Container(
                width: width * 0.4,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _referralCode == null
                        ? Container()
                        : QrImage(
                            data: _referralCode['reff'],
                            size: 140.0,
                            padding: const EdgeInsets.all(0),
                          ),
                    _referralCode == null
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _referralCode['reff'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              IconButton(
                                padding:  EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  copyQr(_referralCode['reff']);
                                },
                                icon: Image.asset(
                                  'assets/images/icon_copy.png',
                                  width: 24,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 18),
              child: Text(
                '$cluster\n $alamat',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewCode() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Row(
        children: [
          const Text(
            'Kode Anda akan kedaluwarsa dalam',
            maxLines: 1,
          ),
          const SizedBox(width: 8),
          const Text(
            '03:23',
            style: TextStyle(
              color: Constants.redTheme,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Perbarui',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.redTheme,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContractorList() {
    if (_listContractor.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semua Kontraktor',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                for (var i = 0; i < _listContractor.length; i++)
                  _buildListTile(
                    index: i,
                    data: _listContractor[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({int? index, dynamic data}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${data['child_name']}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${data['child_phone']}',
        style: const TextStyle(
          color: Color(0xff828382),
        ),
      ),
      trailing: IconButton(
        padding:   EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          showAlertDialog(index: index, id: data['val']);
        },
        icon: Image.asset(
          'assets/images/icon_profile_delete.png',
          width: 24,
        ),
      ),
    );
  }
}
