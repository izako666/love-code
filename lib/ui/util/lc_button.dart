import 'package:flutter/material.dart';
import 'package:love_code/ui/theme.dart';

class LcButton extends StatelessWidget {
  const LcButton({
    super.key,
    this.width = 256,
    this.height = 64,
    this.radius = 32,
    this.shadowColor = buttonColor,
    this.primaryColor = buttonColorDark,
    this.onPressed,
    required this.text,
    this.style,
  });
  final double width;
  final double height;
  final double radius;
  final Color shadowColor;
  final Color primaryColor;
  final Function()? onPressed;
  final String text;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withAlpha(50),
              blurRadius: 4,
              spreadRadius: 4,
              blurStyle: BlurStyle.solid,
            ),
            BoxShadow(
              color: primaryColor,
              spreadRadius: 1,
              blurRadius: 5,
              blurStyle: BlurStyle.inner,
            )
          ]),
      child: TextButton(
        onPressed: onPressed,
        child:
            Text(text, style: style ?? Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
