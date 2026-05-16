// Domain models — port of the in-memory shapes in store.jsx.

class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String state; // ok | warn | error | muted
  final int daysNum;
  final String tariff; // Standard | Student
  final bool hasKey;
  final bool isic;
  final bool overdue;
  final bool suspended;
  final String joined;
  final String expiresAt;
  final int? monthlyPrice;

  const Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.state,
    required this.daysNum,
    required this.tariff,
    required this.hasKey,
    this.isic = false,
    this.overdue = false,
    this.suspended = false,
    required this.joined,
    required this.expiresAt,
    this.monthlyPrice,
  });

  Member copyWith({
    String? name,
    String? phone,
    String? email,
    String? state,
    int? daysNum,
    String? tariff,
    bool? hasKey,
    bool? isic,
    bool? overdue,
    bool? suspended,
    String? joined,
    String? expiresAt,
    int? monthlyPrice,
  }) =>
      Member(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        state: state ?? this.state,
        daysNum: daysNum ?? this.daysNum,
        tariff: tariff ?? this.tariff,
        hasKey: hasKey ?? this.hasKey,
        isic: isic ?? this.isic,
        overdue: overdue ?? this.overdue,
        suspended: suspended ?? this.suspended,
        joined: joined ?? this.joined,
        expiresAt: expiresAt ?? this.expiresAt,
        monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      );
}

class Message {
  final String from; // 'olda' | 'member'
  final String text;
  final DateTime at;
  bool read;
  Message({
    required this.from,
    required this.text,
    required this.at,
    this.read = false,
  });
}

class Payment {
  final String id;
  final String memberId;
  final DateTime date;
  final int amount;
  final String type;
  final String tariff;
  final String state; // ok | pending | overdue
  const Payment({
    required this.id,
    required this.memberId,
    required this.date,
    required this.amount,
    required this.type,
    required this.tariff,
    required this.state,
  });
}

class ThreadSummary {
  final Member member;
  final List<Message> msgs;
  final Message last;
  final int unread;
  const ThreadSummary({
    required this.member,
    required this.msgs,
    required this.last,
    required this.unread,
  });
}
