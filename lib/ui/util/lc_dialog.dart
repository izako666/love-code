import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/ui/theme.dart';

Future<T?> showLcDialog<T>(
    {String? title,
    String? desc,
    Widget? body,
    double? width,
    double? height,
    List<Widget> actions = const [],
    double radius = 16,
    bool barrierDismissible = false}) {
  return Get.dialog<T?>(
      barrierDismissible: barrierDismissible,
      LcDialog(
          title: title,
          desc: desc,
          body: body,
          actions: actions,
          radius: radius,
          width: width,
          height: height));
}

class LcDialog extends StatelessWidget {
  LcDialog(
      {super.key,
      this.title,
      this.desc,
      this.body,
      this.actions = const [],
      this.radius = 16,
      this.width,
      this.height});
  final String? title;
  final String? desc;
  final Widget? body;
  final List<Widget> actions;
  final double radius;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: width ?? 0.6.sw,
        height: height ?? 0.5.sh,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, primaryColor],
                stops: [0.9, 1])),
        child: Column(
          children: [
            const SizedBox(height: 32),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              )
            ],
            const SizedBox(
              height: 32,
            ),
            if (desc != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  desc!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (body != null) ...[body!],
            if (body == null) ...[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actions,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
