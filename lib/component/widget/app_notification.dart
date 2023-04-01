import 'package:flutter/material.dart';
import 'package:appid/component/widget/constants.dart';

// ====== EXAMPLE ======
// showAppNotification(context: context, title: 'Berhasil');

showAppNotification<T>(
    {@required BuildContext? context,
    String title = 'Congratulations!',
    String desc = '',
    String textBtn = 'Ok, Got it!',
    Function? onSubmit}) {
  showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppNotification(
          title: title,
          description: desc,
          onSubmit: onSubmit,
          textBtn: textBtn,
        );
      });
}

class AppNotification extends StatefulWidget {
  final String title, description, textBtn;
  final Image? img;
  final Function? onSubmit;

  const AppNotification({
    Key? key,
    this.title = '',
    this.description = '',
    this.textBtn = '',
    this.img,
    this.onSubmit,
  }) : super(key: key);

  @override
  AppNotificationState createState() => AppNotificationState();
}

class AppNotificationState extends State<AppNotification> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    double width = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // boxShadow: const [
              //   BoxShadow(
              //       color: Constants.colorTitle,
              //       offset: Offset(0, 3),
              //       blurRadius: 3),
              // ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Image.asset('assets/images/state/success-popup.png', width: width * 0.33,),
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Constants.redTheme),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.description,
                style: const TextStyle(fontSize: 18, color: Color(0xFF585670)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();

                    if (widget.onSubmit != null) {
                      widget.onSubmit!();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Constants.redTheme,
                      borderRadius: BorderRadius.circular(120)
                    ),
                    child: Center(
                      child: Text(widget.textBtn,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Constants.colorWhite)),
                    ),
                  )),
            ],
          ),
        ),
        // Positioned(
        //   left: 16,
        //   right: 16,
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     radius: 35,
        //     child: ClipRRect(
        //         borderRadius: const BorderRadius.all(Radius.circular(35)),
        //         child: Image.asset("assets/images/state/success-popup.png")),
        //   ),
        // ),
      ],
    );
  }
}
