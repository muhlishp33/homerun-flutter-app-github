import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';

// ===== EXAMPLE =====
// Padding(
//   padding: const EdgeInsets.all(8.0),
//   child: ButtonView(
//     label: 'Hello',
//     outline: false,
//     loading: fale,
//     onTap: () {},
//   ),
// ),

class ButtonView extends StatelessWidget {
  const ButtonView(
      {this.onTap,
      this.label = '',
      this.outline = false,
      this.loading = false,
      this.disabled = false,
      super.key});

  final Function? onTap;
  final String label;
  final bool outline;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          if (loading || disabled) {
            return;
          }

          onTap!();
        },
        child: Container(
          decoration: BoxDecoration(
            color: disabled
                ? Constants.greyContent
                : outline
                    ? Colors.white
                    : Constants.redTheme,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: disabled || !outline
                  ? Colors.transparent
                  : Constants.redTheme,
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //       color: Colors.grey[400], spreadRadius: 1, blurRadius: 2)
            // ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            outline ? Constants.redTheme : Colors.white),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                          fontSize: 16,
                          color: outline ? Constants.redTheme : Colors.white,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
