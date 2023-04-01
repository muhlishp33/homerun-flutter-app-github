import 'package:flutter/material.dart';
import 'package:appid/ui/main_menu.dart';

class EmptyStateLoyaltyFull extends StatelessWidget {
  dynamic type;
  EmptyStateLoyaltyFull(this.type);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Image.asset(
            'assets/images/loyalti/tickets.png',
            width: 54,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            this.type == 'ACTIVE'
                ? 'Anda tidak memiliki Voucher Aktif'
                : this.type == 'USED'
                    ? 'Semua voucher yang sudah Anda gunakan akan ditampilkan disini'
                    : this.type == 'EXPIRED'
                        ? 'Semua voucher yang sudah kedaluwarsa akan ditampilkan disini'
                        : '',
            textAlign: TextAlign.center,
            style: this.type == 'ACTIVE'
                ? TextStyle(fontWeight: FontWeight.w700, fontSize: 16)
                : TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xff828382)),
          ),
          SizedBox(
            height: 4,
          ),
          this.type != 'ACTIVE'
              ? Container()
              : Column(
                  children: [
                    Text('Ayo beli voucher dengan menekan tombol dibawah',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xff828382),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: (() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainMenuPage(
                                indexTab: 3,
                              ),
                            ));
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            color: Color(0xffee6055),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.only(
                            left: 20, right: 15, bottom: 12, top: 12),
                        child: Center(
                            child: Text(
                          'Beli Voucher',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        )),
                      ),
                    )
                  ],
                )
        ],
      ),
    );
  }
}
