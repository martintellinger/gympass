import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_toast.dart';

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
      return arg == null || '$arg'.isEmpty
          ? '/admin/add'
          : '/admin/add?id=$arg';
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
      // Note: no early return — a `back` can still carry a confirmation toast
      // (e.g. "changes saved" when popping an edit form).
    } else {
      final path = routeToPath(route, arg: arg);
      if (_tabRoutes.contains(route)) {
        context.go(path);
      } else {
        context.push(path);
      }
    }
    if (toast != null && toast.isNotEmpty) {
      final message = toast;
      // Defer so the new route is mounted before the toast slides in from top.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAppToast(context, message);
      });
    }
  };
}
