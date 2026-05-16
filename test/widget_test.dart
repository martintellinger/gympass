import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bytfit_klub/app.dart';

void main() {
  testWidgets('app boots to persona picker', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BytFitApp()));
    await tester.pump();
    expect(find.text('BýtFit Klub'), findsOneWidget);
  });
}
