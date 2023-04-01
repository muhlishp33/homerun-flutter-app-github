import 'package:flutter/material.dart';

class EmptyStateLoyalty extends StatelessWidget {
  dynamic title;
  EmptyStateLoyalty(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Image.asset(
            'assets/images/loyalti/tickets.png',
            width: 54,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            this.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
