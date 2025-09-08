import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'DermAI';

  // Colors
  static const Color primaryColor = Color(0xFF4F3C3F);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Disease labels
  static const List<String> diseaseLabels = [
    'Acne',
    'Athlete Foot',
    'Healthy',
    'Nail Fungus',
    'Ringworm',
  ];
  // Model Parameters
  static const int modelInputSize = 224;
  static const int modelChannels = 3;
}
// constants.dart placeholder