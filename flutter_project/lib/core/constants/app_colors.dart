import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFF9D97FF);

  // Secondary
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryDark = Color(0xFFCC3355);

  // Background
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252545);
  static const Color cardBg = Color(0xFF1E1E35);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textHint = Color(0xFF6B6B8A);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // Subject Colors
  static const List<Color> subjectColors = [
    Color(0xFF6C63FF), // Math - Purple
    Color(0xFF00BCD4), // Physics - Cyan
    Color(0xFF4CAF50), // Chemistry - Green
    Color(0xFFFF9800), // Science - Orange
    Color(0xFFE91E63), // French - Pink
    Color(0xFF9C27B0), // Arabic - Deep Purple
    Color(0xFF2196F3), // English - Blue
    Color(0xFFFF5722), // History - Deep Orange
  ];

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E35), Color(0xFF252545)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
