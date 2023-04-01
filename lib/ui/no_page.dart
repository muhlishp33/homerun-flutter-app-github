import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/widget/constants.dart';

class NoPage extends StatelessWidget {
  const NoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('', style: Constants.textAppBar3),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text('Page Not Found', style: Constants.textAppBar3),
              margin: EdgeInsets.only(bottom: 12),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/splashScreen');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Constants.redTheme,
                  borderRadius: BorderRadius.circular(120),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text('To First Page',
                    style: TextStyle(color: Constants.colorWhite),
                  )
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
