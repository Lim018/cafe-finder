import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale berbasis Poppins — Material 3 type system.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displayMedium: GoogleFonts.poppins(
            fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineLarge: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        headlineMedium: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        headlineSmall: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.04),
        labelSmall: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.06),
      );
}
