import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bytfit_klub/app.dart';
import 'package:bytfit_klub/features/auth/application/auth_notifier.dart';

void main() {
  setUp(authNotifier.debugUseMock);
  testWidgets('extend membership opens QR payment', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BytFitApp()));
    await tester.pumpAndSettle();

    // Persona picker -> open as member
    await tester.tap(find.text('Otevřít jako člen'));
    await tester.pumpAndSettle();

    // On dashboard, tap "Prodloužit členství"
    final extend = find.text('Prodloužit členství');
    expect(extend, findsOneWidget, reason: 'dashboard CTA not found');
    await tester.tap(extend);
    await tester.pumpAndSettle();

    // QR screen should now be visible
    expect(find.text('Zaplatil jsem'), findsOneWidget,
        reason: 'QR payment screen did not open');
  });
}
