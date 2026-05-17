/// The signed-in user's `members` row, reduced to what routing + the shell
/// need. Resolved from Supabase Auth uid → `members.auth_user_id`.
class AppProfile {
  final String memberId;
  final String firstName;
  final String lastName;
  final String email;

  /// `member` | `admin` (DB CHECK constraint).
  final String role;

  /// `pending` | `active` | `suspended` | `inactive` (DB CHECK constraint).
  final String status;

  const AppProfile({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
  });

  bool get isAdmin => role == 'admin';

  /// A `pending` account still waits for the owner's approval (brief §4.1) —
  /// it is sent to the waiting screen, not into the app.
  bool get isPending => status == 'pending';

  String get displayName => '$firstName $lastName'.trim();

  factory AppProfile.fromRow(Map<String, dynamic> row) => AppProfile(
        memberId: row['id'] as String,
        firstName: (row['first_name'] as String?) ?? '',
        lastName: (row['last_name'] as String?) ?? '',
        email: (row['email'] as String?) ?? '',
        role: (row['role'] as String?) ?? 'member',
        status: (row['status'] as String?) ?? 'pending',
      );
}
