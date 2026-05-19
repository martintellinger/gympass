import 'package:flutter/widgets.dart';

import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Single source of truth for noticeboard post-type styling.
///
/// The colour *is* the meaning (red = closed, yellow = warning, green =
/// promo/fixed…), so the owner picks a post **type** in the composer — never
/// a free colour. Board screen and composer both read from here.
class BoardPostStyle {
  final Color color;
  final String icon;
  const BoardPostStyle(this.color, this.icon);
}

const Map<String, BoardPostStyle> _kBoardStyles = {
  'pinned': BoardPostStyle(T.accent, 'pin'),
  'outage': BoardPostStyle(T.error, 'tool'),
  'warning': BoardPostStyle(T.warn, 'alert'),
  'promo': BoardPostStyle(T.ok, 'tag'),
  'event': BoardPostStyle(T.event, 'calendar'),
  'fixed': BoardPostStyle(T.ok, 'check'),
  'info': BoardPostStyle(T.text2, 'megaphone'),
};

BoardPostStyle boardPostStyle(String type) =>
    _kBoardStyles[type] ?? _kBoardStyles['info']!;

/// Types the owner can choose in the composer. `info` first — it is the
/// default for a plain broadcast (brief §11).
const List<String> kComposablePostTypes = <String>[
  'info',
  'pinned',
  'outage',
  'warning',
  'promo',
  'event',
  'fixed',
];

String boardPostLabel(BuildContext context, String type) {
  final l = L.of(context);
  switch (type) {
    case 'pinned':
      return l.boardTypePinned;
    case 'outage':
      return l.boardTypeOutage;
    case 'warning':
      return l.boardTypeWarning;
    case 'promo':
      return l.boardTypePromo;
    case 'event':
      return l.boardTypeEvent;
    case 'fixed':
      return l.boardTypeFixed;
    case 'info':
    default:
      return l.boardTypeInfo;
  }
}
