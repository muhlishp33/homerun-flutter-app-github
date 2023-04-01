import 'dart:developer';

import 'package:appid/component/widget/constants.dart';
import 'package:appid/ui/bnb_awesome/inspired.dart';
import 'package:appid/ui/bnb_awesome/transition_container.dart';
import 'package:flutter/material.dart';

import 'chip_style.dart';
import 'count_style.dart';
import 'tab_item.dart';
import 'build_icon.dart';

class BottomBarInspiredOutside extends StatefulWidget {
  final List<TabItem> items;

  final double? height;
  final Color backgroundColor;
  final double? elevation;
  final bool fixed;
  final int indexSelected;
  final Function(int index)? onTap;
  final Color color;
  final Color colorSelected;
  final double iconSize;
  final TextStyle? titleStyle;
  final CountStyle? countStyle;
  final ChipStyle? chipStyle;
  final List<BoxShadow>? boxShadow;
  final double? top;
  final bool animated;
  final bool isAnimated;
  final Duration? duration;
  final Curve? curve;
  final double? sizeInside;
  final double? padTop;
  final double? padbottom;
  final double? pad;
  final double radius;
  final int? fixedIndex;
  final double? curveSize;

  const BottomBarInspiredOutside({
    Key? key,
    required this.items,
    required this.backgroundColor,
    required this.color,
    required this.colorSelected,
    this.height = 45,
    this.elevation,
    this.fixed = false,
    this.indexSelected = 0,
    this.onTap,
    this.iconSize = 21,
    this.titleStyle,
    this.countStyle,
    this.chipStyle,
    this.boxShadow,
    this.top,
    this.animated = true,
    this.duration,
    this.curve,
    this.sizeInside = 48,
    this.isAnimated = true,
    this.padTop = 12,
    this.padbottom = 12,
    this.pad = 4,
    this.radius = 0,
    this.fixedIndex = 0,
    this.curveSize,
  }) : super(key: key);

  @override
  _BottomBarInspiredOutsideState createState() => _BottomBarInspiredOutsideState();
}

class _BottomBarInspiredOutsideState extends State<BottomBarInspiredOutside> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Constants.redThemeUltraLight,
      //       offset: Offset(0, 0.5),
      //       blurRadius: 0.5),
      //   ],
      // ),
      child: Inspired(
        height: widget.height!,
        count: widget.items.length,
        background: widget.backgroundColor,
        fixed: widget.fixed,
        elevation: widget.elevation,
        animated: widget.animated,
        isAnimated: widget.animated,
        pad: widget.pad,
        padTop: widget.padTop,
        padbottom: widget.padbottom,
        radius: widget.radius,
        fixedIndex: widget.fixedIndex,
        itemBuilder: (_, int index, bool active) => buildItem(
          context,
          item: widget.items[index],
          index: index,
          isSelected: index == widget.indexSelected,
        ),
        initialActive: widget.indexSelected,
        iconChip: (int index) => widget.items[index].icon,
        onTap: widget.onTap,
        // chipStyle: widget.chipStyle ? const ChipStyle(notchSmoothness: NotchSmoothness.sharpEdge),
        curveSize: 70,
        top: widget.top ?? -28,
        containerSize: 56,
        itemStyle: ItemStyle.circle,
      ),
    );
  }

  Widget buildItem(
    BuildContext context, {
    required TabItem item,
    required int index,
    bool isSelected = false,
  }) {
    Color itemColor() {
      if (widget.fixed) {
        return isSelected ? widget.chipStyle!.background! : widget.color;
      }
      return isSelected ? widget.colorSelected : widget.color;
    }

    if (widget.fixed ? widget.fixedIndex == index : isSelected) {
      if (widget.animated) {
        return TransitionContainer.scale(
          data: index,
          duration: widget.duration ?? const Duration(milliseconds: 350),
          curve: widget.curve ?? Curves.easeInOut,
          child: buildContentItem(item, itemColor(), widget.iconSize, widget.sizeInside!, isSelected),
        );
      }
      return buildContentItem(item, itemColor(), widget.iconSize, widget.sizeInside!, isSelected);
    }
    return Container(
      padding: EdgeInsets.only(bottom: widget.padbottom!, top: widget.padTop!),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BuildIcon(
          //   item: item,
          //   iconColor: itemColor(),
          //   iconSize: widget.iconSize,
          //   countStyle: widget.countStyle,
          // ),
          Container(
            child: Image.asset(
              isSelected ? item.iconActiveAsset! : item.iconInactiveAsset!,
              height: widget.iconSize,
              width: widget.iconSize,
            ),
          ),
          SizedBox(
            height: widget.padbottom!,
          ),
          Text(
            item.title!,
            style: const TextStyle().merge(widget.titleStyle).copyWith(
              color: itemColor(),
              fontSize: 12.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget buildContentItem(TabItem item, Color itemColor, double iconSize, double sizeInside, bool isSelected) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: sizeInside,
              height: sizeInside,
              decoration: BoxDecoration(
                color: Constants.redTheme,
                shape: BoxShape.circle
              ),
              alignment: Alignment.center,
              // child: BuildIcon(
              //   item: item,
              //   iconColor: widget.fixed ? widget.colorSelected : itemColor,
              //   iconSize: iconSize,
              //   countStyle: widget.countStyle,
              // ),
              child: Container(
                child: Image.asset(
                  item.iconActiveAsset!,
                  height: widget.iconSize,
                  width: widget.iconSize,
                  color: Constants.colorWhite,
                ),
              ),
            ),
          ],
        ),

        Positioned(
          bottom: widget.padbottom! + 4.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.title!,
                style: const TextStyle().merge(widget.titleStyle).copyWith(
                  color: Constants.redTheme,
                  fontSize: 12.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    );
  }
}
