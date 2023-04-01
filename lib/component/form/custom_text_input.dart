import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:appid/component/widget/constants.dart';

class CustomTextInput extends StatefulWidget {
  const CustomTextInput({
    Key? key,
    required this.controllerName,
    this.hintText = '',
    required this.enabled,
    this.isRequired = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefix = const SizedBox(),
    this.errorText = '',
    this.errorTextWidget = const SizedBox(),
    this.suffixIcon = const SizedBox(),
    this.inputColor = Constants.colorFormInput,
    this.textColor = Constants.colorText,
    this.isObsecure = false,
    this.isHasHint = true,
    this.isPrice = false,
    this.placeholder = 'Masukan',
    required this.onChangeText,
    required this.onTap,
    this.borderColor = Constants.colorFormInput,
    required this.onEditingComplete,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controllerName;
  final String hintText;
  final String placeholder;
  final bool enabled;
  final bool isRequired;
  final bool isObsecure;
  final bool isHasHint;
  final bool isPrice;
  final int maxLines;
  final int minLines;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Widget prefix;
  final String errorText;
  final Widget suffixIcon;
  final Widget? errorTextWidget;
  final Color inputColor;
  final Color borderColor;
  final Color textColor;
  final Function onChangeText;
  final Function onTap;
  final Function onEditingComplete;

  @override
  CustomTextInputState createState() => CustomTextInputState();
}

class CustomTextInputState extends State<CustomTextInput> {
  @override
  void initState() {
    textListener();
    super.initState();
  }

  void textListener() {
    widget.controllerName.addListener(() {
      if (widget.controllerName.text != '') {
        widget.onChangeText();
      }
    });
  }

  @override
  void dispose() {
    widget.controllerName.removeListener(textListener);
    // widget.controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isHasHint)
          Container(
            padding: const EdgeInsets.only(bottom: 9),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.hintText,
              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
            ),
          ),
        Container(
          child: ListTile(
            minVerticalPadding: 0.0,
            contentPadding: EdgeInsets.all(0.0),
            title: Card(
              margin: const EdgeInsets.all(0.0),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: TextFormField(
                focusNode: widget.focusNode,
                textInputAction: widget.textInputAction,
                minLines: widget.minLines,
                inputFormatters: [
                  if (widget.isPrice)
                    CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 0,
                    ),
                ],
                controller: widget.controllerName,
                onTap: () {
                  widget.onTap();
                },
                onEditingComplete: () {
                  widget.onEditingComplete();
                },
                enabled: widget.enabled,
                obscureText: widget.isObsecure,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: widget.textColor,
                ),
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                    isDense: true, //remove default padding
                    fillColor: widget.inputColor,
                    filled: true, // activate bg color
                    // hintText: widget.hintText,
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                      color: Constants.colorPlaceholder,
                    ),
                    prefix: widget.prefix,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: Constants.colorBorder, width: 0.5)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: Constants.colorBorder, width: 0.5)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Constants.redTheme, width: 0.5),
                    ),
                    suffixIcon: widget.suffixIcon),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            subtitle: widget.errorTextWidget is Widget
                ? widget.errorTextWidget
                : widget.errorText != '' ?
                  Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.errorText,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Constants.redTheme,
                      ),
                    ),
                  ) : null,
          ),
        ),
      ],
    );
  }
}
