import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color background = Color(0xFFF7F4EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1F4D36);
  static const Color primaryPressed = Color(0xFF163A29);
  static const Color accent = Color(0xFF6F9A55);
  static const Color softGreenTint = Color(0xFFE8F0DD);
  static const Color text = Color(0xFF1A241E);
  static const Color secondaryText = Color(0xFF66705F);
  static const Color hairline = Color(0xFFE6E0D0);
  static const Color danger = Color(0xFFB3261E);
  static const Color cardShadow = Color(0x0F000000);
}

class AppText {
  static const TextStyle largeTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.1,
  );
  static const TextStyle title22 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.2,
  );
  static const TextStyle headline17 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.3,
  );
  static const TextStyle body15 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.45,
  );
  static const TextStyle caption12 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    height: 1.3,
  );
}

const double kRadiusCard = 14.0;
const double kRadiusField = 14.0;
const double kRadiusPill = 999.0;
const double kRadiusImageTile = 20.0;

class AppShadow {
  static const BoxShadow soft = BoxShadow(
    color: AppColors.cardShadow,
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  );
}

const double kPagePadding = 20.0;
