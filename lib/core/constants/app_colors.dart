import 'package:flutter/material.dart';

/// Professional Material 3 SaaS color system tailored for library management
class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Navy
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Blue
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Slate
  static const Color secondary = Color(0xFF0D9488); // Deep Teal
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFF59E0B); // Warm Amber

  // Surfaces & Backgrounds - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean Slate Canvas
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Surfaces & Backgrounds - Dark Mode
  static const Color backgroundDark = Color(0xFF0B1120); // Darker navy-tinted canvas
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF334155);

  // Typography
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB); // Blue
  static const Color infoLight = Color(0xFFEFF6FF);

  // Sidebar Specific Colors
  static const Color sidebarBgLight = Color(0xFF0F172A); // Modern dark sidebar even in light mode
  static const Color sidebarActiveLight = Color(0xFF2563EB);
  static const Color sidebarTextLight = Color(0xFF94A3B8);
  static const Color sidebarTextActiveLight = Color(0xFFFFFFFF);
}
