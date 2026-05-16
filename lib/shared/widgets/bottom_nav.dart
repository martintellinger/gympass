import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import 'app_icon.dart';

class NavItem {
  final String icon;
  final String label;
  final int? badge;
  const NavItem({required this.icon, required this.label, this.badge});
}

/// BottomNav — shared.jsx BottomNav. Frosted bar, paddingTop 10/bottom 28,
/// borderTop 1px, items space-around, active = accent icon + lighter label.
class BottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int active;
  final ValueChanged<int>? onItemClick;

  const BottomNav({
    super.key,
    required this.items,
    required this.active,
    this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 28, left: 8, right: 8),
          decoration: const BoxDecoration(
            color: Color(0xEB0F0F10), // rgba(15,15,16,0.92)
            border: Border(top: BorderSide(color: T.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final it = items[i];
              final isActive = i == active;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onItemClick == null ? null : () => onItemClick!(i),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AppIcon(
                            it.icon,
                            size: 22,
                            color: isActive ? T.accent : T.text3,
                          ),
                          if (it.badge != null && it.badge! > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 16),
                                height: 16,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: T.error,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: T.bg, width: 2),
                                ),
                                child: Text(
                                  it.badge! > 9 ? '9+' : '${it.badge}',
                                  style: AppType.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        it.label,
                        style: AppType.ui(
                          size: 10.5,
                          weight: FontWeight.w500,
                          color: isActive ? T.text : T.text3,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

const memberNavRoutes = ['dashboard', 'card', 'history', 'board', 'profile'];

class MemberBottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<String>? onNav;
  const MemberBottomNav({super.key, required this.active, this.onNav});

  @override
  Widget build(BuildContext context) => BottomNav(
        active: active,
        onItemClick: onNav == null ? null : (i) => onNav!(memberNavRoutes[i]),
        items: const [
          NavItem(icon: 'home', label: 'Domů'),
          NavItem(icon: 'card', label: 'Karta'),
          NavItem(icon: 'history', label: 'Historie'),
          NavItem(icon: 'board', label: 'Nástěnka'),
          NavItem(icon: 'user', label: 'Profil'),
        ],
      );
}

const adminNavRoutes = ['admin', 'list', 'payments', 'messages', 'adminMore'];

class AdminBottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<String>? onNav;
  final int unread;
  const AdminBottomNav(
      {super.key, required this.active, this.onNav, this.unread = 0});

  @override
  Widget build(BuildContext context) => BottomNav(
        active: active,
        onItemClick: onNav == null ? null : (i) => onNav!(adminNavRoutes[i]),
        items: [
          const NavItem(icon: 'home', label: 'Přehled'),
          const NavItem(icon: 'user', label: 'Členové'),
          const NavItem(icon: 'cash', label: 'Platby'),
          NavItem(icon: 'message', label: 'Zprávy', badge: unread),
          const NavItem(icon: 'more', label: 'Více'),
        ],
      );
}
