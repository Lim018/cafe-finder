import 'package:flutter/material.dart';

/// Centralized border-radius tokens.
class AppRadius {
  AppRadius._();

  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double pill = 999.0;

  static BorderRadius get smAll  => BorderRadius.circular(sm);
  static BorderRadius get mdAll  => BorderRadius.circular(md);
  static BorderRadius get lgAll  => BorderRadius.circular(lg);
  static BorderRadius get xlAll  => BorderRadius.circular(xl);
  static BorderRadius get xxlAll => BorderRadius.circular(xxl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}
