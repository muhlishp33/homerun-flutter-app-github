import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';

class CustomSelectMap extends StatefulWidget {
  const CustomSelectMap({
    Key? key,
    this.controllerName,
    this.hintText = '',
    this.enabled = true,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.isHasHint = true,
    this.placeholder = "",
    this.fullAddress = '',
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
  final String fullAddress;
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
  CustomSelectMapState createState() => CustomSelectMapState();
}

class CustomSelectMapState extends State<CustomSelectMap> {
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
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (widget.isHasHint)
            Container(
              padding: const EdgeInsets.only(bottom: 9),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.hintText,
                style: const TextStyle(
                    fontSize: 13.0, fontWeight: FontWeight.w500),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/universalMapPage', arguments: widget.mapData)
                  .then((value) {
                if (value != null) {
                  // widget.controllerName.text = value;
                  widget.onMapDataChanged!(value);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.inputColor ?? Constants.colorFormInput,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                border: Border.all(
                  color:
                      widget.borderColor ?? Constants.colorFormInput,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    child: AspectRatio(
                      aspectRatio: 11 / 5,
                      child: Image.asset('assets/images/home/select-map.png')
                    ),
                  ),
                  SizedBox(height: 12,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: EdgeInsets.only(right: 8),
                        child: Image.asset(
                          'assets/images/icon/location.png'
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.fullAddress,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Constants.colorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2,),
                  Container(
                    child: InkWell(
                      child: Text(
                        widget.mapData != null ? 'Edit' : 'Choose From Map',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Constants.redTheme),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
