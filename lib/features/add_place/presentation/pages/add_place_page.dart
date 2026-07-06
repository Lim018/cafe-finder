import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_typography.dart';
import '../../../../core/di/injection.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../data/datasources/add_place_remote_datasource.dart';
import '../cubit/add_place_cubit.dart';

class AddPlacePage extends StatelessWidget {
  const AddPlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddPlaceCubit>(),
      child: const _AddPlaceView(),
    );
  }
}

class _AddPlaceView extends StatefulWidget {
  const _AddPlaceView();

  @override
  State<_AddPlaceView> createState() => _AddPlaceViewState();
}

class _AddPlaceViewState extends State<_AddPlaceView> {
  static const _defaultCenter = LatLng(-7.2575, 112.7521); // Surabaya

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceMinCtrl = TextEditingController();
  final _priceMaxCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();

  final _mapController = MapController();

  Category? _category;
  LatLng _picked = _defaultCenter;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    // Ensure categories available for the dropdown.
    final cubit = context.read<CategoriesCubit>();
    if (cubit.state is! CategoriesLoaded) cubit.loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _districtCtrl.dispose();
    _descCtrl.dispose();
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _instagramCtrl.dispose();
    _mapsCtrl.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Layanan lokasi tidak aktif');
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak');
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() => _picked = target);
      _mapController.move(target, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  int? _parsePrice(String v) => v.trim().isEmpty ? null : int.tryParse(v.trim());

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }
    final payload = CreatePlacePayload(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      latitude: _picked.latitude,
      longitude: _picked.longitude,
      categoryId: _category!.id,
      description: _descCtrl.text,
      district: _districtCtrl.text,
      priceMin: _parsePrice(_priceMinCtrl.text),
      priceMax: _parsePrice(_priceMaxCtrl.text),
      phone: _phoneCtrl.text,
      websiteUrl: _websiteCtrl.text,
      instagramUrl: _instagramCtrl.text,
      googleMapsUrl: _mapsCtrl.text,
    );
    context.read<AddPlaceCubit>().submit(payload);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AddPlaceCubit, AddPlaceState>(
      listener: (context, state) {
        if (state.status == AddPlaceStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Lokasi berhasil dikirim. Menunggu persetujuan admin.'),
          ));
          context.pop();
        } else if (state.status == AddPlaceStatus.failure &&
            state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Tambah Lokasi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nama ────────────────────────────────────────────────
                  const _Label('Nama kafe *'),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Kopi Senja',
                      prefixIcon: Icon(Icons.storefront_outlined),
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Kategori ────────────────────────────────────────────
                  const _Label('Kategori *'),
                  BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      final cats = state is CategoriesLoaded
                          ? state.categories
                          : <Category>[];
                      return DropdownButtonFormField<Category>(
                        value: _category,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Pilih kategori',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: cats
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Lokasi peta ─────────────────────────────────────────
                  const _Label('Titik lokasi *'),
                  Text('Ketuk peta atau geser untuk menandai lokasi kafe.',
                      style: AppTypography.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  _LocationPicker(
                    controller: _mapController,
                    center: _picked,
                    onTap: (p) => setState(() => _picked = p),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_picked.latitude.toStringAsFixed(5)}, '
                          '${_picked.longitude.toStringAsFixed(5)}',
                          style: AppTypography.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _locating ? null : _useMyLocation,
                        icon: _locating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location_rounded, size: 18),
                        label: const Text('Lokasi saya'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Alamat ──────────────────────────────────────────────
                  const _Label('Alamat *'),
                  TextFormField(
                    controller: _addressCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Jl. Contoh No. 12',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Alamat wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Kecamatan ───────────────────────────────────────────
                  const _Label('Kecamatan / area'),
                  TextFormField(
                    controller: _districtCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Wonokromo',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Deskripsi ───────────────────────────────────────────
                  const _Label('Deskripsi'),
                  TextFormField(
                    controller: _descCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Suasana, menu andalan, dll.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Harga ───────────────────────────────────────────────
                  const _Label('Rentang harga (Rp)'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceMinCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(hintText: 'Min'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _priceMaxCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(hintText: 'Max'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Kontak ──────────────────────────────────────────────
                  const _Label('Telepon'),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '08xxxxxxxxxx',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _Label('Website'),
                  TextFormField(
                    controller: _websiteCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.language_outlined),
                    ),
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _Label('Instagram'),
                  TextFormField(
                    controller: _instagramCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://instagram.com/...',
                      prefixIcon: Icon(Icons.camera_alt_outlined),
                    ),
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _Label('Google Maps'),
                  TextFormField(
                    controller: _mapsCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://maps.google.com/...',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                    ),
                    validator: _urlValidator,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  BlocBuilder<AddPlaceCubit, AddPlaceState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Kirim Lokasi',
                        isLoading: state.status == AddPlaceStatus.submitting,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Lokasi baru akan ditinjau admin sebelum tampil publik.',
                    style: AppTypography.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _urlValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL tidak valid (harus diawali http/https)';
    }
    return null;
  }
}

class _LocationPicker extends StatelessWidget {
  final MapController controller;
  final LatLng center;
  final ValueChanged<LatLng> onTap;

  const _LocationPicker({
    required this.controller,
    required this.center,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            onTap: (_, point) => onTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.findcafe.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    'assets/logo/bean_marker_foreground.svg',
                    width: 44,
                    height: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text,
            style: AppTypography.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
