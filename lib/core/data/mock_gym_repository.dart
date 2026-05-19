/// In-memory [GymRepository] backed by the existing [GymStore].
///
/// This makes the seam real and testable *without* touching any screen: the
/// mock store stays the single source of truth for the running app, and this
/// adapter just exposes it through the async contract a Supabase
/// implementation will also satisfy. When wiring begins (option B), screens
/// move to providers over [GymRepository]; swapping mock→Supabase is then a
/// one-line provider override.
library;

import '../store/models.dart';
import '../store/store.dart';
import 'gym_repository.dart';

class MockGymRepository implements GymRepository {
  MockGymRepository(this._store);

  final GymStore _store;

  @override
  Future<List<Member>> members() async => List.unmodifiable(_store.members);

  @override
  Future<Member?> memberById(String id) async => _store.memberById(id);

  @override
  Future<List<Payment>> payments() async => List.unmodifiable(_store.payments);

  @override
  Future<List<Message>> ownerThread(String memberId) async =>
      _store.threadFor(memberId);

  @override
  Future<List<MemberConvo>> memberInbox(String meId) async =>
      _store.memberInbox(meId);

  @override
  Future<List<ThreadSummary>> adminThreads() async =>
      _store.threadsSorted();

  @override
  Future<int> totalUnread() async => _store.totalUnread();

  // No real auth in the mock — the approval queue is empty in preview.
  @override
  Future<List<Member>> pendingMembers() async => const [];

  @override
  Future<void> approveMember(String id) async {}

  @override
  Future<void> rejectMember(String id) async {}

  @override
  Future<List<BoardPost>> boardPosts() async {
    final now = DateTime.now();
    return [
      BoardPost(
        id: 'b1',
        type: 'pinned',
        pinned: true,
        title: 'Vítej v BýtFit Klubu',
        body: 'Tady se objeví oznámení od Oldy — výpadky, akce, události.',
        at: now,
        author: 'Olda',
      ),
    ];
  }

  @override
  Future<List<({bool mine, String text, DateTime at})>> conversation(
          String meId, String peerId) async =>
      _store.memberThread(meId, peerId);

  @override
  Future<void> confirmPayment(String paymentId) async =>
      _store.confirmPayment(paymentId);

  @override
  Future<void> addManualPayment({
    required String memberId,
    required int amount,
    required String tariff,
    required String type,
  }) async =>
      _store.addManualPayment(
        memberId: memberId,
        amount: amount,
        tariff: tariff,
        type: type,
      );

  @override
  Future<Member> addMember(Member partial) async => _store.addMember(partial);

  @override
  Future<void> updateMember(String id, Member Function(Member) patch) async =>
      _store.updateMember(id, patch);

  @override
  Future<void> removeMember(String id) async => _store.removeMember(id);

  @override
  Future<void> importMembers({
    required List<Member> additions,
    required Map<String, Member> updates,
  }) async =>
      _store.importMembers(additions: additions, updates: updates);

  @override
  Future<void> pauseMembership(String id,
          {String? reason, required String notice}) async =>
      _store.pauseMembership(id, reason: reason, notice: notice);

  @override
  Future<void> resumeMembership(String id, {required String notice}) async =>
      _store.resumeMembership(id, notice: notice);

  @override
  Future<void> sendOwnerMessage(String memberId, String text,
          {String from = 'olda'}) async =>
      _store.sendMessage(memberId, text, from: from);

  @override
  Future<void> markOwnerThreadRead(String memberId) async =>
      _store.markRead(memberId);

  @override
  Future<void> memberSend(String meId, String peerId, String text) async =>
      _store.memberSend(meId, peerId, text);

  @override
  Future<void> memberMarkRead(String meId, String peerId) async =>
      _store.memberMarkRead(meId, peerId);
}
