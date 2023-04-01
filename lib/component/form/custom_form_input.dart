import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appid/component/widget/constants.dart';

enum OutlineBorderFrom { all, bottom }

class FormInput extends StatelessWidget {
  const FormInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.isError = false,
    this.isEnable = true,
    this.isReadOnly = false,
    this.isRequired = false,
    this.hintTextRequired = false,
    this.isDigitOnly = false,
    this.isFirstInput = false,
    this.lengthChar = 250,
    this.leftMargin = 0,
    this.contentPaddingHorizontal = 15,
    this.labelPaddingTop = 0,
    this.labelPaddingBottom = 0,
    this.maxLines = 1,
    this.errorText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.outLineBorderForm = OutlineBorderFrom.bottom,
    this.keyboardType = TextInputType.text,
  });

  /// [labelText] text diatas from input
  final String? labelText;

  final Function(String)? onChanged;

  /// [hintText] text didalam from input
  final String? hintText;

  /// [controller] variabel input
  final TextEditingController? controller;

  /// [obscureText] property untuk type password atau bukan
  final bool obscureText;

  /// [isError] property jika ingin menampilkan error
  final bool isError;

  /// [errorText] text yang keluar jika value error / salah
  final String errorText;

  /// [prefixIcon] memunculkan icon di sebelah kiri from input
  final Widget? prefixIcon;

  /// [suffixIcon] memunculkan icon di sebelah kanan from input
  final Widget? suffixIcon;

  final OutlineBorderFrom outLineBorderForm;

  /// [keyboardType]
  final TextInputType? keyboardType;

  /// [maxLines]
  final int maxLines;

  /// [isEnable]
  final bool isEnable;

  /// [isReadOnly]
  final bool isReadOnly;

  /// [isRequired]
  final bool isRequired;

  /// [isRequired]
  final bool hintTextRequired;

  /// [isRequired]
  final bool isDigitOnly;

  /// [isRequired]
  final bool isFirstInput;

  /// [leftMargin]
  final double leftMargin;

  /// [contentPaddingHorizontal]
  final double contentPaddingHorizontal;

  /// [labelPaddingTop]
  final double labelPaddingTop;

  /// [labelPaddingBottom]
  final double labelPaddingBottom;

  /// [lengthChar]
  final int lengthChar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: leftMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                left: 0.0, top: (isFirstInput) ? 15 : 0, bottom: 0),
            child: (isRequired)
                ? Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                                text: labelText,
                                style: Constants.textLabelForm),
                            const TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                      Padding(
                          padding:   EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.01)),
                    ],
                  )
                : (labelText != null)
                    ? Container(
                        padding:   EdgeInsets.fromLTRB(
                            0, labelPaddingTop, 0, labelPaddingBottom),
                        child: Text(
                          labelText!,
                          style: Constants.textLabelForm,
                        ),
                      )
                    : (hintTextRequired)
                        ? const Text(
                            'Required',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontFamily: "Poppins"),
                          )
                        : Padding(
                            padding:  EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.01)),
          ),
          TextFormField(
            enabled: isEnable,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            obscureText: obscureText,
            controller: controller,
            maxLines: maxLines,
            inputFormatters: [
              LengthLimitingTextInputFormatter(lengthChar),
              if (isDigitOnly) FilteringTextInputFormatter.digitsOnly
            ],
            cursorColor: Colors.black54,
            style: const TextStyle(
              color: Colors.black54,
              //fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
              //fontStyle: FontStyle.italic,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: 15, horizontal: contentPaddingHorizontal),
              border: (outLineBorderForm == OutlineBorderFrom.all)
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.black87))
                  : (outLineBorderForm == OutlineBorderFrom.bottom)
                      ? const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87))
                      : InputBorder.none,
              focusedBorder: (outLineBorderForm == OutlineBorderFrom.all)
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1))
                  : (outLineBorderForm == OutlineBorderFrom.bottom)
                      ? const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1))
                      : InputBorder.none,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15.0,
                color: Colors.black54,
                fontFamily: "Poppins",
                //fontStyle: FontStyle.italic,
              ),
              // errorText: errorText,
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding:
                // (!hintTextRequired)
                //     ?
                const EdgeInsets.all(5.0),
            // : EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: (isError)
                ? Text(
                    errorText,
                    style: Constants.textErrorForm,
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
