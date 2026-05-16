import '../../../core/store/models.dart';

/// One row as parsed from the migration spreadsheet (`seznam_clenu.xlsx`).
///
/// Only the columns the app cares about; everything else in the sheet is
/// ignored on purpose (the Excel stays the owner's control layer — we never
/// drop its columns, we just don't import what we don't model yet).
class ImportRow {
  final String name;
  final String email;
  final String phone;
  final String tariff; // Standard | Student
  final int monthlyPrice;
  final bool hasKey;

  const ImportRow({
    required this.name,
    required this.email,
    required this.phone,
    required this.tariff,
    required this.monthlyPrice,
    required this.hasKey,
  });
}

enum DiffKind {
  /// No member matches this row — a brand-new member.
  added,

  /// Matches an existing member, every mapped field already equal.
  unchanged,

  /// Matches, only non-protected fields differ (phone / key) — safe to apply.
  changed,

  /// Matches, a protected field (name, tariff, price) differs and both sides
  /// hold a real value — needs an explicit human decision, never auto-applied.
  conflict,
}

/// Identity + classification of a single import row against the live roster.
class DiffEntry {
  final ImportRow row;
  final Member? existing;
  final DiffKind kind;
  final List<String> changedFields;

  const DiffEntry({
    required this.row,
    required this.existing,
    required this.kind,
    required this.changedFields,
  });
}

String _normName(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _normEmail(String s) => s.trim().toLowerCase();

/// Pure diff used by the import wizard. Matching is e-mail first
/// (case-insensitive), then normalised full name as a fallback for rows
/// without an e-mail. Re-importing the same sheet yields all `unchanged`
/// (idempotent), so the Excel can stay in active use as a control layer.
List<DiffEntry> diffImport(List<ImportRow> rows, List<Member> current) {
  Member? findMatch(ImportRow r) {
    final email = _normEmail(r.email);
    if (email.isNotEmpty && email != '—') {
      for (final m in current) {
        if (_normEmail(m.email) == email) return m;
      }
    }
    final name = _normName(r.name);
    for (final m in current) {
      if (_normName(m.name) == name) return m;
    }
    return null;
  }

  // Protected fields differing on both sides ⇒ conflict (human decides).
  const protected = {'name', 'tariff', 'monthlyPrice'};

  return rows.map((r) {
    final m = findMatch(r);
    if (m == null) {
      return DiffEntry(
          row: r, existing: null, kind: DiffKind.added, changedFields: const []);
    }

    final changed = <String>[];
    if (_normName(m.name) != _normName(r.name)) changed.add('name');
    if (_normEmail(m.email) != _normEmail(r.email)) changed.add('email');
    if (m.phone.trim() != r.phone.trim()) changed.add('phone');
    if (m.tariff != r.tariff) changed.add('tariff');
    if ((m.monthlyPrice ?? 0) != r.monthlyPrice) changed.add('monthlyPrice');
    if (m.hasKey != r.hasKey) changed.add('hasKey');

    if (changed.isEmpty) {
      return DiffEntry(
          row: r,
          existing: m,
          kind: DiffKind.unchanged,
          changedFields: const []);
    }

    final hasProtectedClash = changed.any((f) => protected.contains(f));
    return DiffEntry(
      row: r,
      existing: m,
      kind: hasProtectedClash ? DiffKind.conflict : DiffKind.changed,
      changedFields: changed,
    );
  }).toList();
}

/// Headline counts for the confirm step.
class ImportSummary {
  final int added;
  final int changed;
  final int conflicts;
  final int unchanged;
  const ImportSummary(
      this.added, this.changed, this.conflicts, this.unchanged);

  factory ImportSummary.of(List<DiffEntry> entries) {
    var a = 0, c = 0, k = 0, u = 0;
    for (final e in entries) {
      switch (e.kind) {
        case DiffKind.added:
          a++;
        case DiffKind.changed:
          c++;
        case DiffKind.conflict:
          k++;
        case DiffKind.unchanged:
          u++;
      }
    }
    return ImportSummary(a, c, k, u);
  }
}
