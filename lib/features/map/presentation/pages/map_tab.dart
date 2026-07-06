import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../widgets/map_skeleton.dart';
import '../../../places/domain/entities/place.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(InitializeMap());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state.status == MapStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == MapStatus.initial ||
            state.status == MapStatus.loading) {
          return const MapSkeleton();
        }

        final center =
            state.currentLocation ?? const LatLng(-6.200000, 106.816666);

        return Stack(
          children: [
            // ── Map ───────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14.0,
                onTap: (_, __) =>
                    context.read<MapBloc>().add(ClearSelectedPlace()),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.cafe_finder',
                ),

                // Route polyline
                if (state.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: state.routePoints,
                        strokeWidth: 4.0,
                        color: cs.primary,
                      ),
                    ],
                  ),

                // Place markers
                MarkerLayer(
                  markers: state.places.map((p) {
                    final isSelected = state.selectedPlace?.id == p.id;
                    return Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: isSelected ? 60 : 48,
                      height: isSelected ? 68 : 54,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () =>
                            context.read<MapBloc>().add(SelectPlaceMarker(p)),
                        child: _CafeMarker(isSelected: isSelected),
                      ),
                    );
                  }).toList(),
                ),

                // User location marker
                if (state.currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: state.currentLocation!,
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade600,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.withOpacity(0.35),
                                  blurRadius: 10,
                                  spreadRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // ── Search overlay ────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Cari di area ini…',
                      style: AppTypography.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
            ),

            // ── Controls ──────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              right: AppSpacing.lg,
              child: Column(children: [
                _MapControlBtn(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    if (state.currentLocation != null) {
                      _mapCtrl.move(state.currentLocation!, 15.0);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _ZoomControls(
                  onZoomIn: () => _mapCtrl.move(
                      _mapCtrl.camera.center, _mapCtrl.camera.zoom + 1),
                  onZoomOut: () => _mapCtrl.move(
                      _mapCtrl.camera.center, _mapCtrl.camera.zoom - 1),
                ),
              ]),
            ),

            // ── Selected place mini card ───────────────────────────────
            if (state.selectedPlace != null)
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.floatingNavHeight + AppSpacing.sm,
                child: _MiniPlaceCard(
                  place: state.selectedPlace!,
                  onTap: () =>
                      context.push('/place/${state.selectedPlace!.id}'),
                  onClose: () =>
                      context.read<MapBloc>().add(ClearSelectedPlace()),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _CafeMarker extends StatelessWidget {
  final bool isSelected;
  const _CafeMarker({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final badge = isSelected ? 52.0 : 42.0;
    final radius = badge * 0.34;
    final borderColor = isSelected ? AppTheme.primary : Colors.white;
    final borderWidth = isSelected ? 3.0 : 2.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded-square badge with the logo.
        Container(
          width: badge,
          height: badge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - borderWidth),
            child: SvgPicture.asset(
              'assets/logo/bean_marker_logo.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Tapered tail pointing to the location.
        Transform.translate(
          offset: const Offset(0, -1),
          child: CustomPaint(
            size: Size(isSelected ? 16 : 14, isSelected ? 11 : 9),
            painter: _MarkerTailPainter(borderColor),
          ),
        ),
      ],
    );
  }
}

class _MarkerTailPainter extends CustomPainter {
  final Color color;
  const _MarkerTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Cone with slightly concave sides tapering to a point at the bottom.
    final path = ui.Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.15,
          size.width * 0.5, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.28), 2, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkerTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: cs.primary),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 46,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        GestureDetector(
          onTap: onZoomIn,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Icon(Icons.add_rounded, color: cs.primary),
          ),
        ),
        GestureDetector(
          onTap: onZoomOut,
          child: SizedBox(
            height: 44,
            child: Icon(Icons.remove_rounded, color: cs.primary),
          ),
        ),
      ]),
    );
  }
}

class _MiniPlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _MiniPlaceCard({
    required this.place,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: AppRadius.xxlAll,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xxlAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            // Photo
            ClipRRect(
              borderRadius: AppRadius.lgAll,
              child: Container(
                width: 76,
                height: 76,
                color: cs.primaryContainer,
                child: place.photoUrl != null
                    ? Image.network(place.photoUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.local_cafe_rounded, color: cs.primary))
                    : Icon(Icons.local_cafe_rounded, color: cs.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.star_rounded,
                        size: 14, color: AppTheme.starColor),
                    const SizedBox(width: 3),
                    Text(place.avgRating.toStringAsFixed(1),
                        style: AppTypography.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                    if (place.district != null) ...[
                      Text(' · ',
                          style: AppTypography.textTheme.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      Text(place.district!,
                          style: AppTypography.textTheme.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Lihat detail',
                          style: AppTypography.textTheme.labelSmall
                              ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 13, color: cs.onPrimary),
                    ]),
                  ),
                ],
              ),
            ),
            // Close
            IconButton(
              icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
              onPressed: onClose,
            ),
          ]),
        ),
      ),
    );
  }
}
