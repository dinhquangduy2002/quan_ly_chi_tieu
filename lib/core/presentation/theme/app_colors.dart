// File: lib/core/presentation/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Ocean Color Palette
  static const primary = Color(0xFF3BBAC4);       // Teal blue - màu chính
  static const primaryDark = Color(0xFF345DA8);   // Dark blue - màu đậm
  static const primaryLight = Color(0xFF4BB4DE);  // Light blue - màu sáng
  static const accent = Color(0xFFEFDBCB);        // Sand beige - màu accent

  // Màu nền
  static const background = Color(0xFFF8FBFD);    // Very light blue background
  static const surface = Colors.white;            // White surface
  static const cardBackground = Colors.white;     // White cards

  // Màu text
  static const textPrimary = Color(0xFF2C3E50);   // Dark blue-gray
  static const textSecondary = Color(0xFF546E7A); // Medium blue-gray
  static const textLight = Color(0xFF90A4AE);     // Light blue-gray

  // Màu border & divider
  static const border = Color(0xFFE3F2FD);        // Very light blue border
  static const divider = Color(0xFFE1F5FE);       // Light blue divider

  // Màu state
  static const success = Color(0xFF4CAF50);       // Green
  static const warning = Color(0xFFFF9800);       // Orange
  static const error = Color(0xFFF44336);         // Red

  // Bottom Navigation
  static const bottomNavBackground = Colors.white;
  static const bottomNavSelected = Color(0xFF3BBAC4);    // Teal blue
  static const bottomNavUnselected = Color(0xFF90A4AE);  // Light blue-gray
}