import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../utils/haptics.dart';

/// Navigation callback contract used by every screen — mirrors the prototype's
/// `onNav('routeKey')` / `onNav('routeKey', { toast })` convention.
typedef NavCb = void Function(String route, {Object? arg, String? toast});

/// Maps a prototype route key (+ optional arg) to a go_router location.
String routeToPath(String route, {Object? arg}) {
  switch (route) {
    // member
    case 'dashboard':
      return '/member/dashboard';
    case 'card':
      return '/member/card';
    case 'history':
      return '/member/history';
    case 'board':
      return '/member/board';
    case 'profile':
      return '/member/profile';
    case 'mmessages':
      return '/member/messages';
    case 'mthread':
      return '/member/thread/${arg ?? 'olda'}';
    case 'qr':
      return '/member/qr';
    case 'fault':
      return '/member/fault';
    // admin
    case 'admin':
      return '/admin';
    case 'list':
      return '/admin/list';
    case 'payments':
      return '/admin/payments';
    case 'messages':
      return '/admin/messages';
    case 'adminMore':
      return '/admin/more';
    case 'approval':
      return '/admin/approval';
    case 'addMember':
      return '/admin/add';
    case 'broadcast':
      return '/admin/broadcast';
    case 'excelImport':
      return '/admin/import';
    case 'detail':
      return '/admin/member/${arg ?? ''}';
    case 'thread':
      return '/admin/thread/${arg ?? ''}';
    default:
      return '/member/dashboard';
  }
}

/// Persistent tab destinations — switching between these *replaces* the stack
/// (`go`) so tabs never pile up on top of each other. Everything else is a
/// drill-in (`push`) so the hardware / on-screen back button can pop it.
const _tabRoutes = {
  'dashboard', 'mmessages', 'history', 'board', 'profile', // member
  'admin', 'list', 'payments', 'messages', 'adminMore', // admin
};

/// Builds the [NavCb] bound to a [BuildContext]; surfaces `toast` via a
/// SnackBar so prototype `onNav('x', { toast })` calls keep working.
NavCb navCb(BuildContext context) {
  return (String route, {Object? arg, String? toast}) {
    if (route == 'back') {
      if (context.canPop()) {
        context.pop();
      } else {
        // Nothing to pop (e.g. deep-linked / stack already replaced): fall
        // back to the persona's home tab instead of a dead button.
        final loc = GoRouterState.of(context).uri.path;
        context.go(loc.startsWith('/admin') ? '/admin' : '/member/dashboard');
      }
      return;
    }
    final path = routeToPath(route, arg: arg);
    if (_tabRoutes.contains(route)) {
      context.go(path);
    } else {
      context.push(path);
    }
    if (toast != null && toast.isNotEmpty) {
      // A surfaced toast almost always confirms a completed action — give it a
      // success haptic so the feedback is felt, not just seen.
      Haptics.success();
      final message = toast;
      // Defer so the new route is mounted before showing the toast.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: AppType.ui(
                  size: 14,
                  weight: FontWeight.w500,
                  color: T.text,
                ),
              ),
              backgroundColor: T.surface2,
              behavior: SnackBarBehavior.floating,
              elevation: 8,
              duration: const Duration(milliseconds: 2600),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.lg),
                side: BorderSide(color: T.border),
              ),
            ),
          );
      });
    }
  };
}
