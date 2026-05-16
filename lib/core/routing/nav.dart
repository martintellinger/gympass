import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    case 'detail':
      return '/admin/member/${arg ?? ''}';
    case 'thread':
      return '/admin/thread/${arg ?? ''}';
    default:
      return '/member/dashboard';
  }
}

/// Builds the [NavCb] bound to a [BuildContext]; surfaces `toast` via a
/// SnackBar so prototype `onNav('x', { toast })` calls keep working.
NavCb navCb(BuildContext context) {
  return (String route, {Object? arg, String? toast}) {
    if (route == 'back') {
      if (context.canPop()) context.pop();
      return;
    }
    context.go(routeToPath(route, arg: arg));
    if (toast != null && toast.isNotEmpty) {
      // Defer so the new route is mounted before showing the toast.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(SnackBar(content: Text(toast)));
      });
    }
  };
}
