import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';

class CustomDropdownBox extends StatefulWidget {
  const CustomDropdownBox({
    Key? key,
    this.enabled = true,
    @required this.data,
    @required this.value,
    this.keyValue = "",
    this.keyLabel = "",
    this.placeholder = "",
    this.errorLabel = "",
    @required this.onChanged,
  }) : super(key: key);

  final bool enabled;
  final List? data;
  final dynamic value;
  final String keyValue;
  final String keyLabel;
  final String placeholder;
  final String errorLabel;
  final Function? onChanged;

  @override
  CustomDropdownBoxState createState() => CustomDropdownBoxState();
}

class CustomDropdownBoxState extends State<CustomDropdownBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onPress() {
    showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (BuildContext context) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.data!.map((item) {
                  bool isSelected = widget.value == item[widget.keyValue];

                  return GestureDetector(
                    onTap: () {
                      widget.onChanged!(item[widget.keyValue]);
                      Navigator.of(context).pop();
                    },
                    child: Card(
                      elevation: 1,
                      color: isSelected ? Constants.redTheme : Constants.colorFormInput,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        alignment: Alignment.bottomLeft,
                        child: Text(item[widget.keyLabel],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dynamic selected;
    if (widget.data!.isNotEmpty && widget.value != null) {
      selected = widget.data!.firstWhere((e) => widget.value == e[widget.keyValue], orElse: () => null);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 9),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.placeholder,
            style: const TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),
        ListTile(
          dense: true,
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.all(0),
          title: Card(
            elevation: 0,
            margin: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () {
                if (widget.enabled) onPress();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Constants.colorFormInput,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selected != null
                            ? selected[widget.keyLabel].toString()
                            :
                            // widget.placeholder,
                            'Select',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: widget.enabled ? Constants.colorText : Colors.black38,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: widget.enabled ? Colors.black : Colors.black38,
                    )
                  ],
                ),
              ),
            ),
          ),
          subtitle: widget.errorLabel == ''
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  // margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.errorLabel,
                    style: const TextStyle(color: Constants.redTheme),
                  ))
              : Container(),
        ),
      ],
    );
  }
}
