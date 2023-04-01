import 'package:flutter/material.dart';

Color colorFromHex<T>(
  String colorHex,
) {
  // if (colorHex.isEmpty) return Colors.black;
  String regColor = colorHex.replaceAll(RegExp(r'#'), '');
  return Color(int.parse('0xFF$regColor'));
}