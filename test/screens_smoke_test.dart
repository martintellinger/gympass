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
];

Future<void> _settle(WidgetTester tester) async {
  // Fixed pumps, not pumpAndSettle: some screens host repeating
  // animations (skeleton shimmer) that never settle by design.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 280));
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
