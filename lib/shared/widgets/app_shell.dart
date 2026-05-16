import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/store/store.dart';
import '../../core/theme/tokens.dart';
import 'bottom_nav.dart';

/// Persistent tab shell. The [StatefulNavigationShell] keeps every branch
/// mounted (indexedStack), so screen state survives tab switches and the
/// bar below is built exactly once for the lifetime of the shell — it never
/// rebuilds or re-blurs when you change tabs (only [currentIndex] changes).
class MemberShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MemberShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemberBottomNav(
              active: navigationShell.currentIndex,
              bottomInset: inset,
              onIndex: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inset = MediaQuery.of(context).viewPadding.bottom;
    final unread = ref.watch(storeProvider).totalUnread();
    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdminBottomNav(
              active: navigationShell.currentIndex,
              unread: unread,
              bottomInset: inset,
              onIndex: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
