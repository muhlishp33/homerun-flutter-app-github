import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:appid/component/widget/constants.dart';

// import 'package:appid/component/constants.dart';

class LoadingFallback extends StatelessWidget {
  const LoadingFallback(
      {required this.isLoading,
      required this.child,
      this.loadingLabel = '',
      Key? key})
      : super(key: key);

  final bool isLoading;
  final Widget child;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      color: Colors.black87,
      progressIndicator: LoadingOverlayWidget(label: loadingLabel),
      child: child,
    );
  }
}

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({required this.label, Key? key}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.transparent,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Constants.redTheme),
          ),
          const SizedBox(width: 10),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            child: Text(
              label != '' ? label : 'Mohon Tunggu ...',
            ),
          ),
        ],
      ),
    );
  }
}
