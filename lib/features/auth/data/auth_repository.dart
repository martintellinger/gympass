import 'dart:typed_data';

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

  /// Creates the auth user. The `members` row + notification prefs are created
  /// by the DB trigger from the metadata below.
  ///
  /// Returns true when a session was issued immediately; false when Supabase
  /// requires e-mail confirmation first (project setting) — the UI then shows
  /// the "check your inbox" state.
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String tariffType, // 'standard' | 'student'
    Uint8List? studentProofBytes,
    String? studentProofName,
  }) async {
    String? proofUrl;
    if (tariffType == 'student' &&
        studentProofBytes != null &&
        studentProofName != null) {
      proofUrl = await _uploadStudentProof(
        email: email,
        bytes: studentProofBytes,
        fileName: studentProofName,
      );
    }

    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'tariff_type': tariffType,
        'student_proof_url': ?proofUrl,
      },
    );
    return res.session != null;
  }

  /// Best-effort upload to the public `student-proofs` bucket. A failed
  /// upload (e.g. bucket/policies not yet created) must not block
  /// registration — the owner can request the proof again at approval time
  /// (brief §4.1 / §-studentské ověření). Returns the public URL or null.
  Future<String?> _uploadStudentProof({
    required String email,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
      final safe = email.trim().toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '_',
          );
      final path =
          '$safe/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _client.storage.from('student-proofs').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from('student-proofs').getPublicUrl(path);
    } catch (_) {
      return null;
    }
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
