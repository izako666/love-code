import 'package:flutter/material.dart';

Future<T?> showIzBottomSheet<T>({
  required BuildContext context,
  double borderRadius = 32,
  required Widget child,
  double? height,
  double? width,
  Color backgroundColor = Colors.transparent,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool goBack = false,
}) {
  // this should use the appbar for bottomsheets by deafult and the appbar should be build in a way wher eit can have 3 values backbutton, centertext and right a action

  return showModalBottomSheet(
      context: context,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      constraints: BoxConstraints(
        maxHeight: height ?? MediaQuery.of(context).size.height * 0.7,
        maxWidth: width ?? MediaQuery.of(context).size.width,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      builder: (context) {
        return child;
      });
}
