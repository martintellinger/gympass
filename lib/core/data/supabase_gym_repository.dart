/// Supabase-backed [GymRepository].
///
/// Parses DB rows with `dto/db_rows.dart` and maps them to the display
/// [Member]/[Payment] via `dto/member_mapper.dart`, which runs the tested
/// `lib/core/domain/` math — no date/expiry/deposit logic is re-implemented
/// here. Row-Level Security in Postgres is the real authorization boundary;
/// this client only issues queries.
///
/// `now` is the real wall clock (not the mock `kNow`) so expiry/pause/deposit
/// derivations reflect actual time once the app runs on live data.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../store/models.dart';
import '../store/store.dart' show kOwnerId;
import 'dto/db_rows.dart';
import 'dto/member_mapper.dart';
import 'gym_repository.dart';

class SupabaseGymRepository implements GymRepository {
  const SupabaseGymRepository();

  SupabaseClient get _c => Supabase.instance.client;
  DateTime get _now => DateTime.now();

  // ── Reads ────────────────────────────────────────────────────────────

  @override
  Future<List<Member>> members() async {
    final rows = await _c.from('members').select().order('last_name');
    final now = _now;
    return rows
        .map((j) => memberFromRow(MemberRow.fromMap(j), now: now))
        .toList();
  }

  @override
  Future<Member?> memberById(String id) async {
    final j =
        await _c.from('members').select().eq('id', id).maybeSingle();
    if (j == null) return null;
    return memberFromRow(MemberRow.fromMap(j), now: _now);
  }

  @override
  Future<List<Payment>> payments() async {
    final rows =
        await _c.from('payments').select().order('paid_at', ascending: false);
    return rows.map((j) => paymentFromRow(PaymentRow.fromMap(j))).toList();
  }

  /// Owner↔member messages (oldest first). `from_role` 'admin' → the owner
  /// sentinel the view model expects, anything else → 'member'.
  @override
  Future<List<Message>> ownerThread(String memberId) async {
    final thread = await _c
        .from('threads')
        .select('id')
        .eq('member_id', memberId)
        .maybeSingle();
    if (thread == null) return const [];
    final rows = await _c
        .from('messages')
        .select()
        .eq('thread_id', thread['id'] as String)
        .order('created_at');
    return rows
        .map((m) => Message(
              from: (m['from_role'] == 'admin') ? 'olda' : 'member',
              text: (m['body'] ?? '') as String,
              at: DateTime.parse(m['created_at'] as String).toLocal(),
              read: m['read_at'] != null,
            ))
        .toList();
  }

  @override
  Future<List<MemberConvo>> memberInbox(String meId) async {
    final out = <MemberConvo>[];

    // Owner conversation — always present, even with no history.
    final owner = await ownerThread(meId);
    if (owner.isEmpty) {
      out.add(MemberConvo(
        peerId: kOwnerId,
        isOwner: true,
        lastText: '',
        lastAt: _now,
        lastMine: false,
        unread: 0,
      ));
    } else {
      final last = owner.last;
      out.add(MemberConvo(
        peerId: kOwnerId,
        isOwner: true,
        lastText: last.text,
        lastAt: last.at,
        lastMine: last.from == 'member',
        unread: _trailingUnread(owner, (m) => m.from == 'olda'),
      ));
    }

    // Member↔member threads this member takes part in.
    final pts = await _c
        .from('peer_threads')
        .select('id, member_a, member_b')
        .or('member_a.eq.$meId,member_b.eq.$meId');
    for (final pt in pts) {
      final otherId =
          pt['member_a'] == meId ? pt['member_b'] : pt['member_a'];
      final msgs = await _c
          .from('peer_messages')
          .select()
          .eq('thread_id', pt['id'] as String)
          .order('created_at');
      if (msgs.isEmpty) continue;
      final last = msgs.last;
      var unread = 0;
      for (var i = msgs.length - 1; i >= 0; i--) {
        final m = msgs[i];
        if (m['sender_id'] != meId && m['read_at'] == null) {
          unread++;
        } else {
          break;
        }
      }
      out.add(MemberConvo(
        peerId: otherId as String,
        isOwner: false,
        lastText: (last['body'] ?? '') as String,
        lastAt: DateTime.parse(last['created_at'] as String).toLocal(),
        lastMine: last['sender_id'] == meId,
        unread: unread,
      ));
    }

    out.sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return out;
  }

  @override
  Future<List<({bool mine, String text, DateTime at})>> conversation(
      String meId, String peerId) async {
    if (peerId == kOwnerId) {
      final t = await ownerThread(meId);
      return t
          .map((m) => (mine: m.from == 'member', text: m.text, at: m.at))
          .toList();
    }
    final pt = await _c
        .from('peer_threads')
        .select('id')
        .or('and(member_a.eq.$meId,member_b.eq.$peerId),'
            'and(member_a.eq.$peerId,member_b.eq.$meId)')
        .maybeSingle();
    if (pt == null) return const [];
    final rows = await _c
        .from('peer_messages')
        .select()
        .eq('thread_id', pt['id'] as String)
        .order('created_at');
    return rows
        .map((m) => (
              mine: m['sender_id'] == meId,
              text: (m['body'] ?? '') as String,
              at: DateTime.parse(m['created_at'] as String).toLocal(),
            ))
        .toList();
  }

  @override
  Future<List<ThreadSummary>> adminThreads() async {
    final rows = await _c
        .from('threads')
        .select('member_id, members(*), messages(from_role, body, '
            'read_at, created_at)');
    final now = _now;
    final out = <ThreadSummary>[];
    for (final t in rows) {
      final mj = t['members'];
      if (mj == null) continue;
      final member =
          memberFromRow(MemberRow.fromMap(mj as Map<String, dynamic>),
              now: now);
      final rawMsgs = ((t['messages'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
        ..sort((a, b) => DateTime.parse(a['created_at'] as String)
            .compareTo(DateTime.parse(b['created_at'] as String)));
      if (rawMsgs.isEmpty) continue;
      final msgs = rawMsgs
          .map((m) => Message(
                from: (m['from_role'] == 'admin') ? 'olda' : 'member',
                text: (m['body'] ?? '') as String,
                at: DateTime.parse(m['created_at'] as String).toLocal(),
                read: m['read_at'] != null,
              ))
          .toList();
      out.add(ThreadSummary(
        member: member,
        msgs: msgs,
        last: msgs.last,
        unread: _trailingUnread(msgs, (m) => m.from == 'member'),
      ));
    }
    out.sort((a, b) => b.last.at.compareTo(a.last.at));
    return out;
  }

  @override
  Future<int> totalUnread() async {
    final threads = await adminThreads();
    return threads.fold<int>(0, (s, t) => s + t.unread);
  }

  @override
  Future<List<BoardPost>> boardPosts() async {
    final rows = await _c
        .from('board_posts')
        .select('id, type, title, body, is_pinned, cta_label, '
            'published_at, created_at, members:author_id(first_name, '
            'last_name)')
        .order('created_at', ascending: false);
    return rows.map((r) {
      final a = r['members'] as Map<String, dynamic>?;
      final author = a == null
          ? '—'
          : '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim();
      final ts = (r['published_at'] ?? r['created_at']) as String;
      return BoardPost(
        id: r['id'] as String,
        type: (r['type'] ?? 'info') as String,
        pinned: (r['is_pinned'] ?? false) as bool,
        title: (r['title'] ?? '') as String,
        body: (r['body'] ?? '') as String,
        at: DateTime.parse(ts).toLocal(),
        author: author.isEmpty ? '—' : author,
        cta: r['cta_label'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> addManualPayment({
    required String memberId,
    required int amount,
    required String tariff,
    required String type,
  }) async {
    await _c.from('payments').insert({
      'member_id': memberId,
      'amount': amount,
      'tariff': tariff,
      'method': 'manual',
    });
  }

  static int _trailingUnread(
      List<Message> msgs, bool Function(Message) fromOther) {
    var c = 0;
    for (var i = msgs.length - 1; i >= 0; i--) {
      if (fromOther(msgs[i]) && !msgs[i].read) {
        c++;
      } else {
        break;
      }
    }
    return c;
  }

  // ── Mutations ────────────────────────────────────────────────────────

  /// Splits a display name into (first, rest) for the DB columns.
  static (String, String) _splitName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  static String _tariffType(String tariff) =>
      tariff == 'Student' ? 'student' : 'standard';

  @override
  Future<Member> addMember(Member partial) async {
    final (first, last) = _splitName(partial.name);
    final inserted = await _c
        .from('members')
        .insert({
          'first_name': first,
          'last_name': last,
          'email': partial.email == '—' ? null : partial.email,
          'phone': partial.phone,
          'role': 'member',
          'status': 'active',
          'tariff_type': _tariffType(partial.tariff),
          'key_issued': partial.hasKey,
        })
        .select()
        .single();
    return memberFromRow(MemberRow.fromMap(inserted), now: _now);
  }

  /// Applies a view-level [patch] by reading the row, mapping to the view
  /// [Member], patching, then writing back the columns the UI can change.
  /// Pause/resume have dedicated methods; this covers contact/tariff/key
  /// and the suspend toggle.
  @override
  Future<void> updateMember(String id, Member Function(Member) patch) async {
    final j =
        await _c.from('members').select().eq('id', id).maybeSingle();
    if (j == null) return;
    final row = MemberRow.fromMap(j);
    final before = memberFromRow(row, now: _now);
    final after = patch(before);
    final (first, last) = _splitName(after.name);
    await _c.from('members').update({
      'first_name': first,
      'last_name': last,
      'email': after.email == '—' ? null : after.email,
      'phone': after.phone,
      'tariff_type': _tariffType(after.tariff),
      'key_issued': after.hasKey,
      'status': after.suspended ? 'suspended' : 'active',
    }).eq('id', id);
  }

  @override
  Future<void> removeMember(String id) async =>
      _c.from('members').delete().eq('id', id);

  /// Idempotent migration (§8): match by e-mail, update existing else insert.
  @override
  Future<void> importMembers({
    required List<Member> additions,
    required Map<String, Member> updates,
  }) async {
    for (final m in [...additions, ...updates.values]) {
      final (first, last) = _splitName(m.name);
      final email = m.email == '—' ? null : m.email;
      final payload = {
        'first_name': first,
        'last_name': last,
        'phone': m.phone,
        'role': 'member',
        'status': 'active',
        'tariff_type': _tariffType(m.tariff),
        'key_issued': m.hasKey,
      };
      if (email == null) {
        await _c.from('members').insert(payload);
        continue;
      }
      final existing = await _c
          .from('members')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      if (existing == null) {
        await _c.from('members').insert({...payload, 'email': email});
      } else {
        await _c
            .from('members')
            .update(payload)
            .eq('id', existing['id'] as String);
      }
    }
  }

  @override
  Future<void> pauseMembership(String id,
      {String? reason, required String notice}) async {
    await _c.from('members').update({
      'paused_at': _now.toUtc().toIso8601String(),
      'pause_reason': reason,
      'status': 'suspended',
    }).eq('id', id);
    await sendOwnerMessage(id, notice, from: 'member');
  }

  @override
  Future<void> resumeMembership(String id, {required String notice}) async {
    await _c.from('members').update({
      'paused_at': null,
      'pause_reason': null,
      'status': 'active',
    }).eq('id', id);
    // Owner-only resume (product rule): the note is owner-voiced.
    await sendOwnerMessage(id, notice, from: 'olda');
  }

  /// Ensures the member's owner thread exists and returns its id.
  Future<String> _ownerThreadId(String memberId) async {
    final existing = await _c
        .from('threads')
        .select('id')
        .eq('member_id', memberId)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;
    final created = await _c
        .from('threads')
        .insert({'member_id': memberId})
        .select('id')
        .single();
    return created['id'] as String;
  }

  @override
  Future<void> sendOwnerMessage(String memberId, String text,
      {String from = 'olda'}) async {
    final threadId = await _ownerThreadId(memberId);
    await _c.from('messages').insert({
      'thread_id': threadId,
      'from_role': from == 'olda' ? 'admin' : 'member',
      'body': text,
    });
  }

  @override
  Future<void> markOwnerThreadRead(String memberId) async {
    final thread = await _c
        .from('threads')
        .select('id')
        .eq('member_id', memberId)
        .maybeSingle();
    if (thread == null) return;
    await _c
        .from('messages')
        .update({'read_at': _now.toUtc().toIso8601String()})
        .eq('thread_id', thread['id'] as String)
        .eq('from_role', 'admin')
        .isFilter('read_at', null);
  }

  Future<String> _peerThreadId(String a, String b) async {
    final existing = await _c
        .from('peer_threads')
        .select('id')
        .or('and(member_a.eq.$a,member_b.eq.$b),'
            'and(member_a.eq.$b,member_b.eq.$a)')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;
    final created = await _c
        .from('peer_threads')
        .insert({'member_a': a, 'member_b': b})
        .select('id')
        .single();
    return created['id'] as String;
  }

  @override
  Future<void> memberSend(String meId, String peerId, String text) async {
    if (peerId == kOwnerId) {
      await sendOwnerMessage(meId, text, from: 'member');
      return;
    }
    final threadId = await _peerThreadId(meId, peerId);
    await _c.from('peer_messages').insert({
      'thread_id': threadId,
      'sender_id': meId,
      'body': text,
    });
  }

  @override
  Future<void> memberMarkRead(String meId, String peerId) async {
    if (peerId == kOwnerId) {
      final thread = await _c
          .from('threads')
          .select('id')
          .eq('member_id', meId)
          .maybeSingle();
      if (thread == null) return;
      await _c
          .from('messages')
          .update({'read_at': _now.toUtc().toIso8601String()})
          .eq('thread_id', thread['id'] as String)
          .eq('from_role', 'admin')
          .isFilter('read_at', null);
      return;
    }
    final pt = await _c
        .from('peer_threads')
        .select('id')
        .or('and(member_a.eq.$meId,member_b.eq.$peerId),'
            'and(member_a.eq.$peerId,member_b.eq.$meId)')
        .maybeSingle();
    if (pt == null) return;
    await _c
        .from('peer_messages')
        .update({'read_at': _now.toUtc().toIso8601String()})
        .eq('thread_id', pt['id'] as String)
        .neq('sender_id', meId)
        .isFilter('read_at', null);
  }

  /// The live `payments` table records only real (confirmed) payments — there
  /// is no pending-payment row to flip, unlike the mock. "Mark as paid" in
  /// the real model means inserting a payment, which needs the amount/tariff
  /// context the caller does not pass here. Left explicit rather than
  /// silently wrong until the add-payment flow is wired (task: payments).
  @override
  Future<void> confirmPayment(String paymentId) async {
    throw UnimplementedError(
      'confirmPayment: live schema has no pending-payment row to confirm; '
      'recording a payment requires amount/tariff — wire via the '
      'add-payment flow.',
    );
  }
}
