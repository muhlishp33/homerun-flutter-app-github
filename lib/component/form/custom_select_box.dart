import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';

class CustomSelectBox extends StatefulWidget {
  const CustomSelectBox({
    Key? key,
    this.controllerName,
    this.hintText = '',
    this.enabled = true,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.isHasHint = true,
    this.placeholder = "",
    this.onChangeText,
    this.mapData,
    this.onMapDataChanged,
    this.borderRadius,
    this.borderColor,
    this.inputColor,
  }) : super(key: key);

  final TextEditingController? controllerName;
  final String hintText;
  final String placeholder;
  final bool enabled;
  final bool isRequired;
  final bool isHasHint;

  final TextInputType keyboardType;
  final Function? onChangeText;
  final dynamic mapData;
  final Function? onMapDataChanged;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? inputColor;

  @override
  CustomSelectBoxState createState() => CustomSelectBoxState();
}

class CustomSelectBoxState extends State<CustomSelectBox> {
  @override
  void initState() {
    textListener();
    super.initState();
  }

  void textListener() {
    widget.controllerName?.addListener(() {
      if (widget.onChangeText != null && widget.controllerName!.text != '') {
        widget.onChangeText!();
      }
    });
  }

  @override
  void dispose() {
    widget.controllerName?.removeListener(textListener);
    // widget.controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (widget.isHasHint)
            Container(
              padding: const EdgeInsets.only(bottom: 9),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.hintText,
                style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
              ),
            ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: widget.inputColor ?? Constants.colorFormInput,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.borderColor ?? Constants.colorFormInput,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.placeholder,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: widget.borderColor ?? Colors.black38,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}
