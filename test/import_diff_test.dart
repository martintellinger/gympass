import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/store/models.dart';
import 'package:bytfit_klub/features/admin/excel_import/import_diff.dart';

Member _m({
  String id = 'a1',
  String name = 'Pavel Novák',
  String email = 'pavel@email.cz',
  String phone = '+420 111 222 333',
  String tariff = 'Standard',
  int? price = 750,
  bool hasKey = true,
}) =>
    Member(
      id: id,
      name: name,
      phone: phone,
      email: email,
      state: 'ok',
      daysNum: 30,
      tariff: tariff,
      hasKey: hasKey,
      joined: '9 · 2025',
      expiresAt: '14. 8. 2026',
      monthlyPrice: price,
    );

ImportRow _r({
  String name = 'Pavel Novák',
  String email = 'pavel@email.cz',
  String phone = '+420 111 222 333',
  String tariff = 'Standard',
  int price = 750,
  bool hasKey = true,
}) =>
    ImportRow(
      name: name,
      email: email,
      phone: phone,
      tariff: tariff,
      monthlyPrice: price,
      hasKey: hasKey,
    );

void main() {
  group('diffImport', () {
    test('an unmatched row is added', () {
      final out = diffImport([_r(email: 'new@x.cz', name: 'Nový Člen')], []);
      expect(out.single.kind, DiffKind.added);
      expect(out.single.existing, isNull);
    });

    test('identical row is unchanged (re-import is idempotent)', () {
      final out = diffImport([_r()], [_m()]);
      expect(out.single.kind, DiffKind.unchanged);
      expect(out.single.changedFields, isEmpty);
    });

    test('non-protected field difference is a safe change', () {
      final out = diffImport([_r(phone: '+420 999 999 999')], [_m()]);
      expect(out.single.kind, DiffKind.changed);
      expect(out.single.changedFields, contains('phone'));
    });

    test('key flip alone is a safe change, not a conflict', () {
      final out = diffImport([_r(hasKey: false)], [_m()]);
      expect(out.single.kind, DiffKind.changed);
      expect(out.single.changedFields, ['hasKey']);
    });

    test('protected field difference (tariff) is a conflict', () {
      final out = diffImport([_r(tariff: 'Student', price: 500)], [_m()]);
      expect(out.single.kind, DiffKind.conflict);
      expect(out.single.changedFields, containsAll(['tariff', 'monthlyPrice']));
    });

    test('matches by e-mail case-insensitively', () {
      final out = diffImport(
          [_r(email: 'PAVEL@EMAIL.CZ', phone: 'x')], [_m()]);
      expect(out.single.kind, DiffKind.changed);
      expect(out.single.existing, isNotNull);
    });

    test('falls back to normalised name when e-mail is empty', () {
      final out = diffImport(
        [_r(email: '', name: '  pavel   novák ', phone: 'x')],
        [_m()],
      );
      expect(out.single.existing, isNotNull);
      expect(out.single.kind, DiffKind.changed);
    });

    test('summary tallies every category', () {
      final entries = diffImport(
        [
          _r(), // unchanged
          _r(email: 'b@x.cz', name: 'B', phone: 'p'), // added
          _r(email: 'c@x.cz', name: 'C', tariff: 'Student', price: 500),
        ],
        [_m(), _m(id: 'c', email: 'c@x.cz', name: 'C')],
      );
      final s = ImportSummary.of(entries);
      expect(s.unchanged, 1);
      expect(s.added, 1);
      expect(s.conflicts, 1);
    });
  });
}
