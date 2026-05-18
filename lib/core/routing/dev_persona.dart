import 'package:flutter/foundation.dart';

/// Which persona the dev picker chose, when the Supabase backend is off
/// (the in-memory preview). Stands in for `AppProfile.isAdmin` so the router
/// role guard can keep an owner out of the member shell and vice versa even
/// without real auth. `null` = nothing picked yet (at the picker).
///
/// Values: `'owner'` | `'member'` | `null`.
final ValueNotifier<String?> devPersona = ValueNotifier<String?>(null);
