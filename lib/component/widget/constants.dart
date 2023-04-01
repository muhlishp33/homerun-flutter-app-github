import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class Constants {
  /// [appName] nama project aplikasi
  static const String appName = "HomeRun";
  static const String localstorage = "homerunapp";
  static String avatarURL =
      'https://onesmile.sinarmasland.com/api/img/photo/avatar.png';
  static List<String> listGuestUsername = ["mhp", "guest"];

  static String mixpanelApiKey = '8335447cb03f9a2501ed6bf9aa85c951';
  static String mixpanelProjectToken = 'aae7f28af91c0105edc6952342989c33';
  static bool mixpanelOptOutTrackingDefault = false;

  static Color blue = Colors.blue[800]!;
  static const Color green = Colors.green;
  static Color greyContent = Colors.grey[300]!;
  static const Color redTheme = Color(0xFF7210FF);
  static const Color redThemeUltraLight = Color(0xFFE6E3F2);
  static const Color colorSecondary = Color(0xFFFFBF43);
  static const Color colorError = Color(0xFFE02B1D);
  static const Color colorFormInput = Color(0xFFF2F6FC);
  static const Color colorPlaceholder = Color(0xFFC4C4C4);
  static const Color colorCaption = Color(0xFF979797);
  static const Color colorWhite = Colors.white;
  static const Color colorBorder = Color.fromRGBO(236, 236, 236, 1.0);
  static const Color colorStarRating = Color.fromRGBO(236, 225, 10, 1.0);
  static const Color colorInfoTitle = Color.fromRGBO(170, 170, 170, 1.0);
  static const Color colorBackground = Color.fromRGBO(237, 237, 237, 1.0);
  static const Color colorTitle = Color(0xFF1C1D1D);
  static const Color colorText = Color(0xFF212121);

  /// [textInfoDetail] untuk informasi detail
  static TextStyle textInfoDetail =
      TextStyle(color: Colors.grey[600], fontSize: 13);

  /// [textContext] ukuran default text untuk Content
  static TextStyle textContent =
      TextStyle(fontSize: 12, color: Colors.grey[700]);

  /// [textSubTitle] ukuran default text untuk SubTitle
  static const TextStyle textSubTitle = TextStyle(
      fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);

  /// [textTitle] ukuran default text untuk Title
  static const TextStyle textTitle =
      TextStyle(color: Colors.black87, fontWeight: FontWeight.w800);

  /// [textLabelForm] ukuran default text untuk textLabelForm
  static const TextStyle textLabelForm = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// [textTabIsSelected] ukuran default text untuk textTabIsSelected
  static const TextStyle textTabIsSelected = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  /// [textTab] ukuran default text untuk textTab
  static TextStyle textTab =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  /// [textErrorForm] ukuran default text untuk textErrorForm
  static TextStyle textErrorForm = const TextStyle(fontSize: 12, color: Colors.red);

  /// [textInputNumber] ukuran default text untuk Content
  static TextStyle textInputNumber =
      const TextStyle(color: Colors.grey, fontSize: 12);

  /// [textTabs] text tabs
  static TextStyle textTabs =
      TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold);
  static TextStyle textAvenirRegular = const TextStyle();
  static TextStyle textAvenirBold = const TextStyle(
    fontWeight: FontWeight.bold,
  );
  static TextStyle textAppBar3 = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.black,
  );
  static TextStyle textSubhead =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle textButton =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle textSubtitle =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle textOverline =
      const TextStyle(fontSize: 10, fontWeight: FontWeight.w400);
  static TextStyle textCaption =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static bool cekstatuscancelpembeli(int status) {
    if (status == 0 || status == 1) {
      // || status == 2
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatuscancelpenjual(int status) {
    // if (status == 2) {
    //   return true;
    // } else {
    //   return false;
    // }
    return false;
  }

  static bool cekstatussampaipembeli(int status) {
    if (status == 3 || status == 4) {
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatusbayarpembeli(int status) {
    if (status == 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatuskonfirmasipenjual(int status) {
    if (status == 2) {
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatuspickuporder(int status) {
    if (status == 3) {
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatusdikirim(int status) {
    if (status == 4) {
      return true;
    } else {
      return false;
    }
  }

  static bool cekstatuskirimpenjual(int status) {
    if (status == 3) {
      return true;
    } else {
      return false;
    }
  }

  // static Color warnastatus(int status) {
  //   if (status == 5) {
  //     return Colors.green[200];
  //   } else if (status == 6 || status == 7 || status == 8) {
  //     return Colors.red[200];
  //   } else if (status == 4) {
  //     return Colors.blue[200];
  //   } else if (status == 3) {
  //     return Colors.orange[200];
  //   } else if (status == 2) {
  //     return Colors.orange[200];
  //   } else if (status == 1) {
  //     return Colors.orange[200];
  //   } else {
  //     return Colors.grey[200];
  //   }
  // }

  // static Color warnastatustext(int status) {
  //   if (status == 5) {
  //     return Colors.green[700];
  //   } else if (status == 6 || status == 7 || status == 8) {
  //     return Colors.red[700];
  //   } else if (status == 4) {
  //     return Colors.blue[700];
  //   } else if (status == 3) {
  //     return Colors.orange[700];
  //   } else if (status == 2) {
  //     return Colors.orange[700];
  //   } else if (status == 1) {
  //     return Colors.orange[700];
  //   } else {
  //     return Colors.grey[700];
  //   }
  // }
}
