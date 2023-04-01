import 'package:appid/component/widget/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppointmentDatePicker extends StatefulWidget {
  AppointmentDatePicker({
    Key? key,
    required this.controller,
    required this.onTap,
    required this.placeholder,
    this.errorLabel = '',

    // date params
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
  }) : super(key: key);

  final TextEditingController controller;
  final Function onTap;
  final String placeholder;
  final String errorLabel;

  // date params
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate? selectableDayPredicate;

  _AppointmentDatePickerState createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.initialDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectableDayPredicate: widget.selectableDayPredicate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Constants.redThemeUltraLight,
                onPrimary: Constants.redTheme,
                onSurface: Constants.colorTitle,
              ),
              useMaterial3: true,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Constants.redTheme,
                ),
              ),
            ),
            child: child!,
          );
        },
    );

    if (picked != null) {
      widget.onTap(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 9),
          alignment: Alignment.centerLeft,
          child: Text(widget.placeholder,
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Container(
            // margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: (
              Card(
                elevation: 0,
                margin: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.colorFormInput,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextFormField(
                    readOnly: true,
                    controller: widget.controller,
                    onTap: () {
                      _selectDate(context);
                    },
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Poppins-Regular'
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: new Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                        size: 16,
                      ),
                      hintText: widget.controller.text != '' ? widget.controller.text : 'Select',
                      hintStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Constants.colorFormInput,
                          width: 0.5,
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Constants.colorFormInput,
                          width: 0.5
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Constants.colorFormInput,
                          width: 0.5
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
              )
            ),
          ),
          subtitle: widget.errorLabel is String ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(widget.errorLabel,
              style: TextStyle(color: Constants.redTheme),
            )
          ) : null,
        ),
      ],
    );
  }
}
