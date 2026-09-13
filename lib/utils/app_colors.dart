import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  static const mainAppColorBlue = Color(0xFF679CE3);
  static const screenBgColor = Color(0xFFF1F6FA);


  static const backgroundColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0062E6), Color(0xFF002F93)],
  );
}
