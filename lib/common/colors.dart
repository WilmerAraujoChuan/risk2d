import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromRGBO(241, 132, 179, 1);
  static const Color secondary = Color.fromRGBO(255, 228, 240, 1);
  static const Color background = Color.fromRGBO(255, 245, 248, 1);
  static const Color textPrimary = Color.fromRGBO(64, 50, 56, 1);
  static const Color textSecondary = Color.fromRGBO(118, 100, 106, 1);
  static const Color success = Color.fromRGBO(130, 215, 177, 1);
  static const Color error = Color.fromRGBO(255, 105, 122, 1);
  static const Color border = Color.fromRGBO(230, 201, 210, 1);

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color.fromRGBO(255, 184, 207, 1), primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
