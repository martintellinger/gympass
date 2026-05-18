import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_profile.dart';

/// Thin wrapper over Supabase Auth + the `members` profile lookup.
///
/// Registration does **not** insert the `members` row from the client — RLS
/// only lets admins write `members`. Instead `signUp` carries the form fields
/// as user metadata and a Postgres trigger (`handle_new_user`, see
/// `docs/backend/setup.sql`) creates the `pending` member row. This keeps the
/// client trivial and the security boundary in the database.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Session? get currentSession => _auth.currentSession;

  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// Registration gate (/goal): true iff an unclaimed roster row matches the
  /// name (case/diacritics/order-insensitive — server-side `roster_find_match`
  /// RPC). Returns only a boolean; no roster PII reaches the client.
  Future<bool> rosterMatch({
    required String firstName,
    required String lastName,
  }) async {
    final res = await _client.rpc('roster_find_match', params: {
      'p_first': firstName.trim(),
      'p_last': lastName.trim(),
    });
    return res == true;
  }

  /// Creates the auth user with the name + contact as metadata. The DB
  /// trigger `handle_new_user` then CLAIMS the matching roster row (links
  /// auth user, fills e-mail/phone, sets status `pending` for Olda to
  /// confirm). Tariff / student verification / deposit are handled by the
  /// owner at approval (brief §4.1), not collected here.
  ///
  /// Returns true when a session was issued immediately; false when Supabase
  /// requires e-mail confirmation first (project setting).
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
      },
    );
    return res.session != null;
  }

  Future<void> signOut() => _auth.signOut();

  /// The caller's `members` row, or null if it doesn't exist yet (trigger
  /// hasn't run, or e-mail not confirmed so there is no user yet).
  Future<AppProfile?> fetchProfile() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('members')
        .select('id, first_name, last_name, email, role, status')
        .eq('auth_user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return AppProfile.fromRow(row);
  }
}
