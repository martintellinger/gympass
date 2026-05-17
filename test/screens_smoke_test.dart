import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/app.dart';
import 'package:bytfit_klub/core/routing/router.dart';
import 'package:bytfit_klub/core/theme/app_theme.dart';

/// Every navigable destination — the 18 prototype screens plus the
/// push-above sub-pages (incl. parametrised detail/thread).
const _routes = <String>[
  '/',
  '/member/dashboard',
  '/member/card',
  '/member/history',
  '/member/board',
  '/member/profile',
  '/member/qr',
  '/member/fault',
  '/admin',
  '/admin/list',
  '/admin/payments',
  '/admin/messages',
  '/admin/more',
  '/admin/approval',
  '/admin/add',
  '/admin/broadcast',
  '/admin/import',
  '/admin/member/pavel',
  '/admin/thread/david',
  '/member/messages',
  '/member/thread/olda',
  '/member/thread/eva',
];

Future<void> _settle(WidgetTester tester) async {
  // Settle fully so the previous route's StatefulShellRoute subtree is
  // disposed before the next builds (avoids a transient duplicate of the
  // shell's GlobalKey). No listed route hosts a perpetual animation —
  // the skeleton shimmer only runs inside the wizard's parsing step,
  // which a plain navigation never triggers — so this terminates.
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 16));
}

void main() {
  for (final locale in const ['cs', 'en']) {
    for (final mode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets('renders every screen — $locale / ${mode.name}',
          (tester) async {
        // Render at an iPhone-class surface — this is a phone app; the
        // default 800×600 desktop surface is not a target device.
        await tester.binding.setSurfaceSize(const Size(402, 874));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const BytFitApp(),
          ),
        );
        container.read(localeProvider.notifier).set(Locale(locale));
        container.read(themeModeProvider.notifier).set(mode);
        await _settle(tester);

        for (final route in _routes) {
          // Reset to the persona root (no StatefulShellRoute) between each
          // destination so the previous shell fully tears down before the
          // next builds — otherwise rapid go() between a push sub-page and a
          // shell tab momentarily duplicates the shell's GlobalKey (a test
          // artifact of driving one global router, not a product bug).
          appRouter.go('/');
          await _settle(tester);
          appRouter.go(route);
          await _settle(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: 'route $route threw in $locale/${mode.name}',
          );
        }
      });
    }
  }
}
