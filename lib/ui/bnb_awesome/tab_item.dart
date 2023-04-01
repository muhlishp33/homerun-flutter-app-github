import 'package:flutter/material.dart';

class TabItem<T> {
  final T? icon;
  final String? title;
  final Widget? count;
  final String? key;
  final String? iconActiveAsset;
  final String? iconInactiveAsset;

  const TabItem({
    this.icon,
    this.title,
    this.count,
    this.key,
    this.iconActiveAsset,
    this.iconInactiveAsset,
  });
}
