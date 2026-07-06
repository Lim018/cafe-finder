import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/map_bloc.dart';
import '../../domain/entities/route_step.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_typography.dart';

// ─── Travel modes ────────────────────────────────────────────────────────────

enum TravelMode { walk, bike, motor, car }

extension TravelModeX on TravelMode {
  String get label => switch (this) {
        TravelMode.walk => 'Jalan Kaki',
        TravelMode.bike => 'Sepeda',
        TravelMode.motor => 'Motor',
        TravelMode.car => 'Mobil',
      };

  IconData get icon => switch (this) {
        TravelMode.walk => Icons.directions_walk_rounded,
        TravelMode.bike => Icons.directions_bike_rounded,
        TravelMode.motor => Icons.two_wheeler_rounded,
        TravelMode.car => Icons.directions_car_rounded,
      };

  // Average speeds (km/h) used to estimate ETA when OSRM only gives us the
  // driving duration. Car uses the real OSRM duration.
  double get speedKmh => switch (this) {
        TravelMode.walk => 5,
        TravelMode.bike => 15,
        TravelMode.motor => 40,
        TravelMode.car => 50,
      };

  String get gmapsTravelMode => switch (this) {
        TravelMode.walk => 'walking',
        TravelMode.bike => 'bicycling',
        TravelMode.motor => 'driving',
        TravelMode.car => 'driving',
      };
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _darkCard = Color(0xFF2E2620);

double _modeDurationS(TravelMode m, double distanceM, double carDurationS) {
  if (m == TravelMode.car && carDurationS > 0) return carDurationS;
  final km = distanceM / 1000;
  return km / m.speedKmh * 3600;
}

String formatDistance(double m) => m >= 1000
    ? '${(m / 1000).toStringAsFixed(1)} km'
    : '${m.round()} m';

String formatDuration(double s) {
  if (s >= 3600) return '${(s / 3600).toStringAsFixed(1)} jam';
  if (s >= 60) return '${(s / 60).round()} mnt';
  return '< 1 mnt';
}

String _modifierText(String? mod) => switch (mod) {
      'left' => 'kiri',
      'right' => 'kanan',
      'slight left' => 'agak kiri',
      'slight right' => 'agak kanan',
      'sharp left' => 'tajam kiri',
      'sharp right' => 'tajam kanan',
      'straight' => 'lurus',
      'uturn' => 'putar balik',
      _ => '',
    };

String stepInstruction(RouteStep s) {
  final road = s.roadName.isNotEmpty ? s.roadName : 'jalan tanpa nama';
  switch (s.maneuverType) {
    case 'depart':
      return 'Mulai perjalanan ke ${s.roadName.isNotEmpty ? s.roadName : 'tujuan'}';
    case 'arrive':
      return 'Tiba di tujuan';
    case 'roundabout':
    case 'rotary':
      return 'Masuk bundaran';
    case 'exit roundabout':
    case 'exit rotary':
      return 'Keluar bundaran ke $road';
    case 'turn':
      return 'Belok ${_modifierText(s.maneuverModifier)} ke $road';
    case 'end of road':
      return 'Belok ${_modifierText(s.maneuverModifier)} ke $road';
    case 'fork':
      return 'Ambil ${_modifierText(s.maneuverModifier)} ke $road';
    case 'merge':
      return 'Bergabung ke $road';
    case 'on ramp':
      return 'Masuk jalur ke $road';
    case 'off ramp':
      return 'Ambil jalur keluar ke $road';
    case 'new name':
    case 'continue':
    default:
      return 'Lanjutkan ke $road';
  }
}

({IconData icon, Color color}) stepVisual(RouteStep s) {
  const blueGrey = Color(0xFF5B6B7A);
  const green = Color(0xFF3E7C4F);
  const brown = Color(0xFF7A553C);
  switch (s.maneuverType) {
    case 'depart':
      return (icon: Icons.my_location_rounded, color: _darkCard);
    case 'arrive':
      return (icon: Icons.flag_rounded, color: green);
    case 'roundabout':
    case 'rotary':
    case 'exit roundabout':
    case 'exit rotary':
      return (icon: Icons.roundabout_left_rounded, color: green);
    case 'turn':
    case 'end of road':
      final left = (s.maneuverModifier ?? '').contains('left');
      return (
        icon: left ? Icons.turn_left_rounded : Icons.turn_right_rounded,
        color: blueGrey
      );
    case 'uturn':
      return (icon: Icons.u_turn_left_rounded, color: blueGrey);
    default:
      return (icon: Icons.straight_rounded, color: brown);
  }
}

Future<void> _launchGmaps(
    LatLng? origin, LatLng dest, TravelMode mode) async {
  final params = <String>[
    'api=1',
    if (origin != null) 'origin=${origin.latitude},${origin.longitude}',
    'destination=${dest.latitude},${dest.longitude}',
    'travelmode=${mode.gmapsTravelMode}',
  ];
  final uri = Uri.parse('https://www.google.com/maps/dir/?${params.join('&')}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

// ─── Public entry ────────────────────────────────────────────────────────────

void showDirectionsSheet(BuildContext context) {
  final mapBloc = context.read<MapBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true, // draw above the shell's floating nav bar
    showDragHandle: false, // we render our own handle
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    // Provide the (global) MapBloc to the root-navigator sheet explicitly.
    builder: (_) => BlocProvider.value(
      value: mapBloc,
      child: const _DirectionsSheet(),
    ),
  );
}

/// Snapshot of the routing data the sheets need, read live from [MapState].
class _RouteData {
  final LatLng? origin;
  final LatLng? destination;
  final String placeName;
  final double distanceM;
  final double carDurationS;
  final List<RouteStep> steps;
  final bool loading;

  const _RouteData({
    required this.origin,
    required this.destination,
    required this.placeName,
    required this.distanceM,
    required this.carDurationS,
    required this.steps,
    required this.loading,
  });

  factory _RouteData.from(MapState s) {
    final p = s.selectedPlace;
    return _RouteData(
      origin: s.currentLocation,
      destination: p != null ? LatLng(p.latitude, p.longitude) : null,
      placeName: p?.name ?? '',
      distanceM: s.routeDistanceM,
      carDurationS: s.routeDurationS,
      steps: s.routeSteps,
      // Route still being fetched: place selected but no geometry yet.
      loading: p != null && s.routeDistanceM == 0 && s.routeSteps.isEmpty,
    );
  }
}

// ─── Shared bits ─────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(Icons.auto_awesome_rounded, size: 14, color: cs.primary),
      const SizedBox(width: 6),
      Text(text.toUpperCase(),
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          )),
    ]);
  }
}

class _ModeCard extends StatelessWidget {
  final TravelMode mode;
  final bool selected;
  final String eta;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.eta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : cs.onSurface;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? _darkCard : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? _darkCard : cs.outlineVariant),
          ),
          child: Column(children: [
            Icon(mode.icon, color: fg, size: 24),
            const SizedBox(height: 6),
            Text(mode.label,
                style: AppTypography.textTheme.labelSmall
                    ?.copyWith(color: fg, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(eta,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? Colors.white70
                        : cs.onSurfaceVariant,
                    fontSize: 10)),
          ]),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final TravelMode selected;
  final double distanceM;
  final double carDurationS;
  final ValueChanged<TravelMode> onSelect;

  const _ModeSelector({
    required this.selected,
    required this.distanceM,
    required this.carDurationS,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in TravelMode.values) ...[
          _ModeCard(
            mode: m,
            selected: m == selected,
            eta: formatDuration(_modeDurationS(m, distanceM, carDurationS)),
            onTap: () => onSelect(m),
          ),
          if (m != TravelMode.values.last)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

// ─── Primary directions sheet ────────────────────────────────────────────────

class _DirectionsSheet extends StatefulWidget {
  const _DirectionsSheet();

  @override
  State<_DirectionsSheet> createState() => _DirectionsSheetState();
}

class _DirectionsSheetState extends State<_DirectionsSheet> {
  TravelMode _mode = TravelMode.car;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final data = _RouteData.from(state);
        final eta = _modeDurationS(_mode, data.distanceM, data.carDurationS);
        final ready = !data.loading && data.steps.isNotEmpty;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl + MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _Handle()),
                const SizedBox(height: AppSpacing.sm),

                const _SectionLabel('Pilih Moda'),
                const SizedBox(height: AppSpacing.md),
                _ModeSelector(
                  selected: _mode,
                  distanceM: data.distanceM,
                  carDurationS: data.carDurationS,
                  onSelect: (m) => setState(() => _mode = m),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Stats
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(children: [
                    _Stat(
                        icon: Icons.straighten_rounded,
                        label: 'Jarak',
                        value: data.loading ? '…' : formatDistance(data.distanceM)),
                    _StatDivider(),
                    _Stat(
                        icon: Icons.schedule_rounded,
                        label: 'Estimasi',
                        value: data.loading ? '…' : formatDuration(eta)),
                    _StatDivider(),
                    _Stat(
                        icon: Icons.alt_route_rounded,
                        label: 'Langkah',
                        value: data.loading ? '…' : '${data.steps.length}',
                        valueColor: const Color(0xFF3E7C4F)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.xl),

                const _SectionLabel('Pilih Navigasi'),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  // Google Maps
                  Expanded(
                    flex: 3,
                    child: _NavButton(
                      dark: true,
                      icon: _mode.icon,
                      title: 'Google Maps',
                      subtitle: 'Mode ${_mode.label}',
                      onTap: data.destination == null
                          ? null
                          : () => _launchGmaps(
                              data.origin, data.destination!, _mode),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Petunjuk
                  Expanded(
                    flex: 2,
                    child: _NavButton(
                      dark: false,
                      icon: Icons.turn_right_rounded,
                      title: 'Petunjuk',
                      subtitle:
                          data.loading ? 'memuat…' : '${data.steps.length} langkah',
                      onTap: !ready
                          ? null
                          : () {
                              Navigator.pop(context);
                              _showStepsSheet(context, _mode);
                            },
                    ),
                  ),
                ]),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    _mode == TravelMode.walk || _mode == TravelMode.bike
                        ? 'Estimasi ${_mode.label.toLowerCase()} berdasarkan rute jalan · bisa berbeda dari kondisi nyata'
                        : 'Google Maps untuk navigasi langsung · Petunjuk untuk panduan arah',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStepsSheet(BuildContext context, TravelMode mode) {
    final mapBloc = context.read<MapBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => BlocProvider.value(
        value: mapBloc,
        child: _StepsSheet(initialMode: mode),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(height: 6),
        Text(label.toUpperCase(),
            style: AppTypography.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.textTheme.titleMedium?.copyWith(
                color: valueColor ?? cs.onSurface,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 44,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

class _NavButton extends StatelessWidget {
  final bool dark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _NavButton({
    required this.dark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = dark ? _darkCard : cs.primaryContainer;
    final fg = dark ? Colors.white : cs.onPrimaryContainer;
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (dark ? Colors.white : Colors.black).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: fg.withOpacity(0.8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: fg, size: 18),
          ]),
        ),
      ),
    );
  }
}

// ─── Turn-by-turn steps sheet ────────────────────────────────────────────────

class _StepsSheet extends StatefulWidget {
  final TravelMode initialMode;

  const _StepsSheet({required this.initialMode});

  @override
  State<_StepsSheet> createState() => _StepsSheetState();
}

class _StepsSheetState extends State<_StepsSheet> {
  late TravelMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final data = _RouteData.from(state);
        final eta = _modeDurationS(_mode, data.distanceM, data.carDurationS);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollCtrl) {
            return Column(
              children: [
                const _Handle(),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_mode.icon, color: cs.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Petunjuk Arah',
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(color: cs.onSurface)),
                          Text(
                              '${_mode.label} · ${formatDistance(data.distanceM)} · ${formatDuration(eta)}',
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Icon(Icons.close_rounded,
                            color: cs.onSurfaceVariant, size: 20),
                      ),
                    ),
                  ]),
                ),
                // Mode selector
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _ModeSelector(
                    selected: _mode,
                    distanceM: data.distanceM,
                    carDurationS: data.carDurationS,
                    onSelect: (m) => setState(() => _mode = m),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Origin → destination
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Icon(Icons.my_location_rounded,
                          size: 16, color: cs.primary),
                      const SizedBox(width: 6),
                      Text('Lokasi Anda',
                          style: AppTypography.textTheme.labelMedium
                              ?.copyWith(color: cs.onSurface)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16, color: cs.onSurfaceVariant),
                      const Spacer(),
                      Flexible(
                        child: Text(data.placeName,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                // Steps
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    itemCount: data.steps.length,
                    itemBuilder: (_, i) => _StepTile(
                      step: data.steps[i],
                      isLast: i == data.steps.length - 1,
                    ),
                  ),
                ),
                // Start real-time nav
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.lg + MediaQuery.of(context).padding.bottom),
                  child: GestureDetector(
                    onTap: data.destination == null
                        ? null
                        : () =>
                            _launchGmaps(data.origin, data.destination!, _mode),
                    child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _darkCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_mode.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mulai Navigasi Real-Time',
                              style: AppTypography.textTheme.titleSmall
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                          Text('Beralih ke Google Maps · ${_mode.label}',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ]),
                ),
              ),
            ),
          ],
        );
      },
    );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final RouteStep step;
  final bool isLast;

  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vis = stepVisual(step);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: vis.color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(vis.icon, color: Colors.white, size: 22),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: cs.outlineVariant,
                ),
              ),
          ]),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stepInstruction(step),
                      style: AppTypography.textTheme.titleSmall
                          ?.copyWith(color: cs.onSurface, height: 1.25)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    _Chip(
                        icon: Icons.straighten_rounded,
                        text: formatDistance(step.distanceM)),
                    const SizedBox(width: AppSpacing.sm),
                    _Chip(
                        icon: Icons.schedule_rounded,
                        text: formatDuration(step.durationS)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: AppTypography.textTheme.labelSmall
                ?.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}
