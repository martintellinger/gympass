/// Supabase-backed [GymRepository] — **stub**.
///
/// Intentionally does NOT import `supabase_flutter` yet: this scaffold must
/// keep `flutter analyze`/`flutter test` green with or without `pub get`, and
/// wiring is gated on credentials + the auth decision (see
/// docs/backend/README.md). Each method documents the table + the
/// parse→map path it will take so the implementation is mechanical:
///
///   final rows = await client.from('members').select();
///   return rows.map((j) => memberFromRow(MemberRow.fromMap(j), now: now))
///              .toList();
///
/// i.e. the DB shape is parsed by `dto/db_rows.dart` and turned into the
/// view model by `dto/member_mapper.dart`, which runs the tested domain
/// math. No date/expiry/deposit logic is re-implemented here.
library;

import '../store/models.dart';
import 'gym_repository.dart';

class SupabaseGymRepository implements GymRepository {
  const SupabaseGymRepository();

  Never _todo(String table) => throw UnimplementedError(
        'SupabaseGymRepository: wire `$table` — parse with *Row.fromMap, map '
        'via dto/member_mapper.dart. Gated on credentials + auth decision '
        '(docs/backend/README.md).',
      );

  @override
  Future<List<Member>> members() async => _todo('members → select()');

  @override
  Future<Member?> memberById(String id) async => _todo('members eq id');

  @override
  Future<List<Payment>> payments() async => _todo('payments');

  @override
  Future<List<Message>> ownerThread(String memberId) async =>
      _todo('messages via threads.member_id');

  @override
  Future<List<MemberConvo>> memberInbox(String meId) async =>
      _todo('threads + peer_threads');

  @override
  Future<List<({bool mine, String text, DateTime at})>> conversation(
          String meId, String peerId) async =>
      _todo('messages / peer_messages');

  @override
  Future<void> confirmPayment(String paymentId) async =>
      _todo('payments update state');

  @override
  Future<Member> addMember(Member partial) async => _todo('members insert');

  @override
  Future<void> updateMember(String id, Member Function(Member) patch) async =>
      _todo('members update');

  @override
  Future<void> removeMember(String id) async => _todo('members delete');

  @override
  Future<void> importMembers({
    required List<Member> additions,
    required Map<String, Member> updates,
  }) async =>
      _todo('members upsert (idempotent re-import, §8)');

  @override
  Future<void> pauseMembership(String id,
          {String? reason, required String notice}) async =>
      _todo('members.paused_at + owner message');

  @override
  Future<void> resumeMembership(String id, {required String notice}) async =>
      _todo('members clear pause + owner message');

  @override
  Future<void> sendOwnerMessage(String memberId, String text,
          {String from = 'olda'}) async =>
      _todo('messages insert');

  @override
  Future<void> markOwnerThreadRead(String memberId) async =>
      _todo('messages.read_at');

  @override
  Future<void> memberSend(String meId, String peerId, String text) async =>
      _todo('messages / peer_messages insert');

  @override
  Future<void> memberMarkRead(String meId, String peerId) async =>
      _todo('messages.read_at / peer_messages');
}
