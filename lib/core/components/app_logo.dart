import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand logo (Bean Marker) for in-app use.
///
/// [AppLogo.mark] renders the bean-marker pin with a transparent background —
/// drop it on any colored surface or inside a framed container.
///
/// [AppLogo.full] renders the master logo with its tan background tile.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.size,
    this.variant = AppLogoVariant.mark,
  });

  /// Transparent pin only — for placing over custom backgrounds/containers.
  const AppLogo.mark({super.key, required this.size})
      : variant = AppLogoVariant.mark;

  /// Full master logo including the tan background tile.
  const AppLogo.full({super.key, required this.size})
      : variant = AppLogoVariant.full;

  final double size;
  final AppLogoVariant variant;

  static const _markAsset = 'assets/logo/bean_marker_foreground.svg';
  static const _fullAsset = 'assets/logo/bean_marker_logo.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      variant == AppLogoVariant.mark ? _markAsset : _fullAsset,
      width: size,
      height: size,
    );
  }
}

enum AppLogoVariant { mark, full }
