import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/app.dart';
import 'package:bytfit_klub/core/routing/router.dart';
import 'package:bytfit_klub/core/routing/dev_persona.dart';
import 'package:bytfit_klub/features/auth/application/auth_notifier.dart';

/// Role separation (defense in depth). Reproduces the reported bug: an owner
/// proklikal admin flow and landed in the member app. With the guard, a
/// cross-role destination bounces back to the actor's own home.
void main() {
  String loc() =>
      appRouter.routeInformationProvider.value.uri.toString();

  // Fixed pumps — some screens host perpetual animations, so pumpAndSettle
  // would hang (same reason the smoke suite avoids it).
  Future<void> settle(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 320));
  }

  Future<void> boot(WidgetTester t, String persona) async {
    await t.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(const ProviderScope(child: BytFitApp()));
    await settle(t);
    devPersona.value = persona;
    appRouter.go(persona == 'owner' ? '/admin' : '/member/dashboard');
    await settle(t);
  }

  setUp(() {
    // Force the in-memory preview path (no Supabase) so role separation is
    // driven by the dev persona — the documented widget-test seam.
    authNotifier.debugUseMock();
    devPersona.value = null;
  });
  tearDown(() => devPersona.value = null);

  testWidgets('owner is bounced out of the member shell back to /admin',
      (tester) async {
    await boot(tester, 'owner');

    appRouter.go('/member/board'); // the old "Více → Nástěnka" leak
    await settle(tester);
    expect(loc(), '/admin', reason: 'owner must not enter the member shell');

    appRouter.go('/member/profile');
    await settle(tester);
    expect(loc(), '/admin');
  });

  testWidgets('owner KEEPS pushed member tools (qr extend)', (tester) async {
    await boot(tester, 'owner');
    appRouter.go('/member/qr'); // pushed tool, not a shell tab
    await settle(tester);
    expect(loc(), '/member/qr');
  });

  testWidgets('member cannot reach any admin screen', (tester) async {
    await boot(tester, 'member');
    for (final admin in const [
      '/admin',
      '/admin/list',
      '/admin/payments',
      '/admin/board',
      '/admin/member/pavel',
    ]) {
      appRouter.go(admin);
      await settle(tester);
      expect(loc(), '/member/dashboard',
          reason: 'member must not reach $admin');
    }
  });
}
