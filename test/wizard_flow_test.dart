import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/app.dart';
import 'package:bytfit_klub/core/routing/router.dart';
import 'package:bytfit_klub/core/store/store.dart';

void main() {
  testWidgets('Excel import wizard: pick → parse → mapping → diff → done',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final store = container.read(storeProvider);
    final rosterBefore = store.members.length;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BytFitApp(),
      ),
    );
    appRouter.go('/admin/import');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 1 — pick the file.
    expect(find.text('Vybrat soubor (.xlsx)'), findsOneWidget);
    await tester.tap(find.text('Vybrat soubor (.xlsx)'));
    await tester.pump(); // enter parsing (skeleton)

    // Step 1b — parsing has a deliberate ~1.4 s delay; advance past it.
    await tester.pump(const Duration(milliseconds: 1600));

    // Step 2 — mapping preview.
    expect(find.text('Pokračovat na rozdíl'), findsOneWidget);
    await tester.tap(find.text('Pokračovat na rozdíl'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 3 — diff. The apply CTA is an ICU-plural label; match its stem.
    final applyBtn = find.textContaining('Importovat');
    expect(applyBtn, findsOneWidget);
    await tester.tap(applyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 4 — done, and the store actually grew (synthetic sheet adds 2).
    expect(find.text('Hotovo'), findsOneWidget);
    expect(find.text('Zavřít'), findsOneWidget);
    expect(store.members.length, greaterThan(rosterBefore));
  });
}
