import 'package:flutter/material.dart';

const textColor = Color(0xFFc8c7c2);
const backgroundColor = Color(0xFF151519);
const primaryColor = Color(0xFFfd4040);
const primaryFgColor = Color(0xFF151519);
const secondaryColor = Color(0xFFc4c4c4);
const secondaryFgColor = Color(0xFF151519);
const accentColor = Color(0xFFff9b9b);
const accentFgColor = Color(0xFF151519);
const buttonColor = Color(0XFF9C0000);
const buttonColorDark = Color(0XFF4D0000);
const hintColor = Color(0XFFFFD700);
const colorScheme = ColorScheme(
  brightness: Brightness.dark,
  surface: backgroundColor,
  onSurface: textColor,
  primary: primaryColor,
  onPrimary: primaryFgColor,
  secondary: secondaryColor,
  onSecondary: secondaryFgColor,
  tertiary: accentColor,
  onTertiary: accentFgColor,
  error: Brightness.dark == Brightness.light ? Color(0xffB3261E) : Color(0xffF2B8B5),
  onError: Brightness.dark == Brightness.light ? Color(0xffFFFFFF) : Color(0xff601410),
);

TextTheme textTheme = TextTheme(
  headlineLarge: const TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: textColor, fontFamily: "PT Serif"),
  headlineMedium: const TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w600, color: textColor, fontFamily: "PT Serif"),
  headlineSmall: const TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w600, color: textColor, fontFamily: "PT Serif"),
  titleLarge: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: textColor, fontFamily: "PT Serif"),
  titleMedium: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: textColor, fontFamily: "PT Serif"),
  titleSmall: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: textColor, fontFamily: "PT Serif"),
  bodyLarge: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: textColor, fontFamily: "Red Hat Text"),
  bodyMedium: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: textColor, fontFamily: "Red Hat Text"),
  bodySmall: const TextStyle()
      .copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.5), fontFamily: "Red Hat Text"),
  labelLarge: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: textColor),
  labelMedium: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: textColor.withOpacity(0.5)),
);

class AppTheme {
  static ThemeData theme = ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    useMaterial3: true,
  );
}
