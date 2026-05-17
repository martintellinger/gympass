import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/app.dart';
import 'package:bytfit_klub/core/store/store.dart';
import 'package:bytfit_klub/features/auth/application/auth_notifier.dart';

void main() {
  setUp(authNotifier.debugUseMock);
  testWidgets('member can open the messages tab and chat with Olda',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: BytFitApp()));
    await tester.pumpAndSettle();

    // Persona picker -> member
    await tester.tap(find.text('Otevřít jako člen'));
    await tester.pumpAndSettle();

    // The bottom nav now has a "Zprávy" tab instead of "Karta".
    expect(find.text('Karta'), findsNothing);
    final messagesTab = find.text('Zprávy');
    expect(messagesTab, findsOneWidget);
    await tester.tap(messagesTab);
    await tester.pumpAndSettle();

    // Inbox shows the owner conversation + a member↔member one (Eva).
    expect(find.text('Olda'), findsWidgets);
    expect(find.text('Eva Krátká'), findsOneWidget);

    // Open the Eva thread and send a message.
    await tester.tap(find.text('Eva Krátká'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tak jo, vidíme se tam.');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.text('Tak jo, vidíme se tam.'), findsOneWidget);
  });

  test('store: owner + peer threads share one member inbox', () {
    final s = GymStore();
    final inbox = s.memberInbox(kCurrentMemberId);
    // Owner row is always present; pavel also has peer threads with eva/adam.
    expect(inbox.any((c) => c.isOwner), isTrue);
    expect(inbox.where((c) => !c.isOwner).length, greaterThanOrEqualTo(2));

    s.memberSend(kCurrentMemberId, 'eva', 'Ahoj');
    final t = s.memberThread(kCurrentMemberId, 'eva');
    expect(t.last.mine, isTrue);
    expect(t.last.text, 'Ahoj');
  });
}
