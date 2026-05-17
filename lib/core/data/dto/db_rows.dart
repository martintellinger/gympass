/// Database-shaped DTOs — a 1:1 mirror of the Postgres rows (see
/// `docs/backend/schema.sql`), deliberately kept separate from the
/// display-shaped view models in `lib/core/store/models.dart`.
///
/// The UI consumes the *view* models (`Member` with `daysNum`, a localised
/// `expiresAt` string, a derived `state`). These DTOs hold the **raw** truth
/// (dates, `billing_day_of_month`, `deposit_status`); the mapper layer
/// (`member_mapper.dart`) runs the tested `lib/core/domain/` functions to
/// derive the view fields. Parsing lives here so a Supabase repository just
/// does `MemberRow.fromMap(json)` and never re-implements date math.
library;

DateTime? _date(Object? v) =>
    v == null ? null : DateTime.parse(v as String).toLocal();

class MemberRow {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role; // 'member' | 'admin'
  final String status; // 'pending' | 'active' | 'suspended' | 'inactive'
  final String tariffType; // 'standard' | 'student'
  final String? studentProofUrl;
  final int? variableSymbol;
  final DateTime? membershipExpiresAt;
  final int? billingDayOfMonth; // 1–31, null = the 1st
  final bool keyIssued;
  final String? keyNumber;
  final DateTime? keyReturnedAt;
  final bool depositPaid;
  final String depositStatus; // 'paid' | 'returned' | 'forfeited'
  final DateTime? pausedAt;
  final String? pauseReason; // 'holiday' | 'illness' | 'other'
  final DateTime? createdAt;
  final List<String> tags;

  const MemberRow({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.tariffType,
    this.studentProofUrl,
    this.variableSymbol,
    this.membershipExpiresAt,
    this.billingDayOfMonth,
    this.keyIssued = false,
    this.keyNumber,
    this.keyReturnedAt,
    this.depositPaid = false,
    this.depositStatus = 'paid',
    this.pausedAt,
    this.pauseReason,
    this.createdAt,
    this.tags = const [],
  });

  bool get keyReturned => keyReturnedAt != null;

  factory MemberRow.fromMap(Map<String, dynamic> m) => MemberRow(
        id: m['id'] as String,
        firstName: (m['first_name'] ?? '') as String,
        lastName: (m['last_name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        role: (m['role'] ?? 'member') as String,
        status: (m['status'] ?? 'pending') as String,
        tariffType: (m['tariff_type'] ?? 'standard') as String,
        studentProofUrl: m['student_proof_url'] as String?,
        variableSymbol: (m['variable_symbol'] as num?)?.toInt(),
        membershipExpiresAt: _date(m['membership_expires_at']),
        billingDayOfMonth: (m['billing_day_of_month'] as num?)?.toInt(),
        keyIssued: (m['key_issued'] ?? false) as bool,
        keyNumber: m['key_number'] as String?,
        keyReturnedAt: _date(m['key_returned_at']),
        depositPaid: (m['deposit_paid'] ?? false) as bool,
        depositStatus: (m['deposit_status'] ?? 'paid') as String,
        pausedAt: _date(m['paused_at']),
        pauseReason: m['pause_reason'] as String?,
        createdAt: _date(m['created_at']),
        tags: ((m['tags'] as List?)?.cast<String>()) ?? const [],
      );
}

class PaymentRow {
  final String id;
  final String memberId;
  final int amount;
  final String tariff;
  final DateTime paidAt;
  final String method; // 'qr_bank' | 'cash' | 'manual' | 'imported'
  final int extendsMembershipByDays;
  final bool isHistorical;

  const PaymentRow({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.tariff,
    required this.paidAt,
    required this.method,
    this.extendsMembershipByDays = 0,
    this.isHistorical = false,
  });

  factory PaymentRow.fromMap(Map<String, dynamic> m) => PaymentRow(
        id: m['id'] as String,
        memberId: m['member_id'] as String,
        amount: (m['amount'] as num).toInt(),
        tariff: (m['tariff'] ?? 'other') as String,
        paidAt: DateTime.parse(m['paid_at'] as String).toLocal(),
        method: (m['method'] ?? 'manual') as String,
        extendsMembershipByDays:
            (m['extends_membership_by_days'] as num?)?.toInt() ?? 0,
        isHistorical: (m['is_historical'] ?? false) as bool,
      );
}

class TariffRow {
  final String id;
  final String name;
  final int durationDays;
  final int price;
  final bool isStudent;
  final bool isActive;
  final int sortOrder;

  const TariffRow({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.isStudent,
    required this.isActive,
    required this.sortOrder,
  });

  factory TariffRow.fromMap(Map<String, dynamic> m) => TariffRow(
        id: m['id'] as String,
        name: m['name'] as String,
        durationDays: (m['duration_days'] as num).toInt(),
        price: (m['price'] as num).toInt(),
        isStudent: (m['is_student'] ?? false) as bool,
        isActive: (m['is_active'] ?? true) as bool,
        sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
      );
}

class OpeningHoursRow {
  final int weekday; // 0 = Monday … 6 = Sunday
  final String? openTime; // 'HH:mm', null = closed
  final String? closeTime;
  final String? note;

  const OpeningHoursRow({
    required this.weekday,
    this.openTime,
    this.closeTime,
    this.note,
  });

  factory OpeningHoursRow.fromMap(Map<String, dynamic> m) => OpeningHoursRow(
        weekday: (m['weekday'] as num).toInt(),
        openTime: m['open_time'] as String?,
        closeTime: m['close_time'] as String?,
        note: m['note'] as String?,
      );
}
