// Formatting helpers — Czech conventions (store.jsx fmtTime/fmtRelDay,
// CLAUDE.md: "2 250 Kč" with space thousands, dates "23. 6. 2026").
import 'store/store.dart';

String fmtTime(DateTime d) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.hour)}:${p(d.minute)}';
}

String fmtRelDay(DateTime d, [DateTime? now]) {
  final n = now ?? kNow;
  final a = DateTime(d.year, d.month, d.day);
  final b = DateTime(n.year, n.month, n.day);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'dnes';
  if (diff == 1) return 'včera';
  if (diff < 7) return 'před $diff dny';
  return '${d.day}. ${d.month}.';
}

/// "2 250 Kč" — non-breaking-ish space as thousands separator.
String kc(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '$buf Kč';
}

String groupThousands(num n) {
  final s = n.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}
