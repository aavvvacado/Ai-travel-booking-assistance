import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Travel Editorial Palette
  static const Color background = Color(0xFFF8FAFC); // Warm Off-White / Light Slate
  static const Color surface = Color(0xFFFFFFFF);    // Crisp White Card
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);     // Subtle Border
  static const Color borderFocused = Color(0xFF2563EB);

  // Accents
  static const Color primary = Color(0xFF0F172A); // Deep Slate / Midnight Navy
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color accent = Color(0xFF2563EB);   // Royal Blue Primary CTA
  static const Color success = Color(0xFF059669);  // Emerald Success
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color iosRed = Color(0xFFEF4444);  // Red Accent

  // Text Tokens
  static const Color textPrimary = Color(0xFF0F172A);   // Deep Charcoal Text
  static const Color textSecondary = Color(0xFF475569); // Muted Gray Text
  static const Color textMuted = Color(0xFF94A3B8);     // Light Secondary

  // Chat Elements
  static const Color userBubble = Color(0xFF0F172A);    // Dark Charcoal User Pill
  static const Color aiText = Color(0xFF0F172A);        // Plain Text Assistant

  // Status Indicators
  static const Color recordingGlow = Color(0xFFEF4444);
  static const Color listeningPulse = Color(0xFF2563EB);
}
