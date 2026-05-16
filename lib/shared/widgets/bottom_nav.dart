import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'app_icon.dart';

class NavItem {
  final String icon;
  final String label;
  final int? badge;
  const NavItem({required this.icon, required this.label, this.badge});
}

/// BottomNav — persistent iOS 26 "liquid glass" tab bar.
///
/// Lives in the app shell and is never rebuilt on tab switch; only [active]
/// changes. Heavy backdrop blur + saturation, a soft capsule that slides
/// between slots, and a spring scale on the active icon. The bottom inset is
/// safe-area aware (passed by the shell), not a hardcoded value.
class BottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int active;
  final ValueChanged<int>? onItemClick;

  /// Safe-area bottom inset supplied by the shell (MediaQuery viewPadding).
  final double bottomInset;

  const BottomNav({
    super.key,
    required this.items,
    required this.active,
    this.onItemClick,
    this.bottomInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    // iOS 26: bar floats above the home indicator with a real safe-area gap.
    final bottomPad = (bottomInset > 0 ? bottomInset : 16).toDouble();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: bottomPad, left: 10, right: 10),
          decoration: BoxDecoration(
            // Translucent "glass" — lets blurred content show through.
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC141416), Color(0xF20F0F10)],
            ),
            border: const Border(top: BorderSide(color: T.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final n = items.length;
              final slotW = c.maxWidth / n;
              const capsuleH = 40.0;
              final capsuleW = slotW.clamp(48.0, 76.0);

              return SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Sliding "liquid glass" capsule behind the active tab ──
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      left: active * slotW + (slotW - capsuleW) / 2,
                      top: 0,
                      child: Container(
                        width: capsuleW,
                        height: capsuleH,
                        decoration: BoxDecoration(
                          color: T.accentSoft,
                          borderRadius: BorderRadius.circular(capsuleH / 2),
                          border: Border.all(
                            color: T.accent.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(n, (i) {
                        final it = items[i];
                        final isActive = i == active;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onItemClick == null
                                ? null
                                : () => onItemClick!(i),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutBack,
                              scale: isActive ? 1.06 : 1.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                            constraints: const BoxConstraints(
                                                minWidth: 16),
                                            height: 16,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: T.error,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: T.bg, width: 2),
                                            ),
                                            child: Text(
                                              it.badge! > 9
                                                  ? '9+'
                                                  : '${it.badge}',
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
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

const memberNavRoutes = ['dashboard', 'card', 'history', 'board', 'profile'];

class MemberBottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<int>? onIndex;
  final double bottomInset;
  const MemberBottomNav({
    super.key,
    required this.active,
    this.onIndex,
    this.bottomInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return BottomNav(
      active: active,
      bottomInset: bottomInset,
      onItemClick: onIndex,
      items: [
        NavItem(icon: 'home', label: l.navHome),
        NavItem(icon: 'card', label: l.navCard),
        NavItem(icon: 'history', label: l.navHistory),
        NavItem(icon: 'board', label: l.navBoard),
        NavItem(icon: 'user', label: l.navProfile),
      ],
    );
  }
}

const adminNavRoutes = ['admin', 'list', 'payments', 'messages', 'adminMore'];

class AdminBottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<int>? onIndex;
  final int unread;
  final double bottomInset;
  const AdminBottomNav({
    super.key,
    required this.active,
    this.onIndex,
    this.unread = 0,
    this.bottomInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return BottomNav(
      active: active,
      bottomInset: bottomInset,
      onItemClick: onIndex,
      items: [
        NavItem(icon: 'home', label: l.navOverview),
        NavItem(icon: 'user', label: l.navMembers),
        NavItem(icon: 'cash', label: l.navPayments),
        NavItem(icon: 'message', label: l.navMessages, badge: unread),
        NavItem(icon: 'more', label: l.navMore),
      ],
    );
  }
}
