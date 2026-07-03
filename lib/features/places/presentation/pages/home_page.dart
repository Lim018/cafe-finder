import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/config/app_typography.dart';

class HomePage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomePage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(Icons.format_list_bulleted_outlined, Icons.format_list_bulleted, 'Daftar'),
    _NavItem(Icons.map_outlined, Icons.map_rounded, 'Peta'),
    _NavItem(Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favorit'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg,
          AppSpacing.floatingNavBottomInset + bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.32),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final item = _items[i];
              return _NavBarItem(
                icon: active ? item.activeIcon : item.icon,
                label: item.label,
                isActive: active,
                primaryColor: cs.primary,
                inactiveColor: cs.onSurfaceVariant,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color primaryColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon, required this.label, required this.isActive,
    required this.primaryColor, required this.inactiveColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, key: ValueKey(isActive),
                color: isActive ? primaryColor : inactiveColor, size: 26),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isActive ? primaryColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              )),
        ]),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
