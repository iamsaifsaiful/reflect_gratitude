import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<NavItem> navItems = [
  NavItem('Today', Icons.home_outlined, Icons.home_rounded),
  NavItem('Journal', Icons.menu_book_outlined, Icons.menu_book_rounded),
  NavItem('Progress', Icons.bar_chart_rounded, Icons.bar_chart_rounded),
  NavItem('Calendar', Icons.calendar_today_outlined, Icons.calendar_today_rounded),
];

/// Cream tab bar with a hairline top border. The active tab is terracotta.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          child: Row(
            children: [
              for (var i = 0; i < navItems.length; i++)
                Expanded(
                  child: _NavButton(item: navItems[i], active: i == index, onTap: () => onSelect(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, required this.onTap});

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.terracotta : AppColors.faint;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? item.activeIcon : item.icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppText.body(11, weight: active ? FontWeight.w800 : FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
