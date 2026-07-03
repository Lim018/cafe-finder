import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../widgets/profile_skeleton.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_typography.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) context.go('/login');
      },
      builder: (context, state) {
        if (state is AuthLoading) return const ProfileSkeleton();

        if (state is Authenticated) {
          final user = state.user;
          final cs = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Cover + avatar ─────────────────────────────────
                  _ProfileHeader(user: user),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.lg,
                        AppSpacing.xl, 0),
                    child: Column(
                      children: [
                        // ── Stats ──────────────────────────────────────
                        BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (_, favState) {
                            final favCount = favState is FavoritesLoaded
                                ? favState.favorites.length
                                : 0;
                            return Row(children: [
                              _StatCard(value: '$favCount', label: 'Favorit'),
                              const SizedBox(width: AppSpacing.sm),
                              // TODO: tambah field reviews_count di User entity / endpoint
                              const _StatCard(value: '–', label: 'Ulasan'),
                              const SizedBox(width: AppSpacing.sm),
                              const _StatCard(value: '–', label: 'Dikunjungi'),
                            ]);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Menu card ──────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: AppRadius.xlAll,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              _MenuTile(
                                icon: Icons.settings_outlined,
                                label: 'Pengaturan Akun',
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Fitur akan segera hadir')),
                                ),
                              ),
                              Divider(height: 1, color: cs.outlineVariant),

                              // Dark mode toggle
                              BlocBuilder<ThemeCubit, ThemeMode>(
                                builder: (context, mode) {
                                  return _ToggleTile(
                                    icon: Icons.dark_mode_outlined,
                                    label: 'Mode Gelap',
                                    value: mode == ThemeMode.dark,
                                    onChanged: (_) =>
                                        context.read<ThemeCubit>().toggle(),
                                  );
                                },
                              ),
                              Divider(height: 1, color: cs.outlineVariant),

                              _MenuTile(
                                icon: Icons.help_outline_rounded,
                                label: 'Bantuan & Dukungan',
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Fitur akan segera hadir')),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Logout ─────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.logout_rounded,
                                color: Theme.of(context).colorScheme.error),
                            label: Text('Keluar',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.4)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.lgAll),
                            ),
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.floatingNavHeight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Fallback — bisa terjadi saat initial
        return const ProfileSkeleton();
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final dynamic user; // User entity

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7A553C), Color(0xFF5A3E2B)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profil Saya',
                        style: AppTypography.textTheme.titleLarge
                            ?.copyWith(color: Colors.white)),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Avatar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: ClipOval(
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _DefaultAvatar(initial: user.name[0]),
                        )
                      : _DefaultAvatar(initial: user.name[0]),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(user.name,
                  style: AppTypography.textTheme.headlineMedium
                      ?.copyWith(color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(user.email,
                  style: AppTypography.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(user.role.toUpperCase(),
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String initial;
  const _DefaultAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.primaryContainer,
      child: Center(
        child: Text(initial.toUpperCase(),
            style: AppTypography.textTheme.displaySmall
                ?.copyWith(color: cs.onPrimaryContainer)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(children: [
          Text(value,
              style: AppTypography.textTheme.displaySmall
                  ?.copyWith(color: cs.primary, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label,
          style: AppTypography.textTheme.titleSmall?.copyWith(color: cs.onSurface)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: cs.onSurfaceVariant, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label,
          style: AppTypography.textTheme.titleSmall?.copyWith(color: cs.onSurface)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: cs.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    );
  }
}
