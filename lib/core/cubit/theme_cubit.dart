import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages ThemeMode (light / dark).
/// Provide di atas MaterialApp di main.dart, lalu consume dengan:
///
/// ```dart
/// // main.dart
/// BlocBuilder<ThemeCubit, ThemeMode>(
///   builder: (context, mode) => MaterialApp(
///     themeMode: mode,
///     theme: AppTheme.lightTheme,
///     darkTheme: AppTheme.darkTheme,
///     ...
///   ),
/// )
/// ```
///
/// Di ProfileTab, gunakan:
/// ```dart
/// context.read<ThemeCubit>().toggle();
/// final isDark = context.watch<ThemeCubit>().isDark;
/// ```
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  bool get isDark => state == ThemeMode.dark;

  void toggle() => emit(isDark ? ThemeMode.light : ThemeMode.dark);

  void setMode(ThemeMode mode) => emit(mode);
}
