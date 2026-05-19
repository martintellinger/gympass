/// The persistence seam.
///
/// Today every screen reads `ref.watch(storeProvider)` — a synchronous
/// in-memory [GymStore]. Supabase is async, so the real wiring (architectural
/// option B in the plan) replaces those reads with `AsyncValue` providers
/// backed by this interface, feature by feature. This file only establishes
/// the contract + a mock implementation so the boundary exists and is
/// exercised; **no screen is rewired yet** and the app still runs on the mock
/// store unchanged.
///
/// Returned [Member]/[Payment] are the display-shaped view models. A
/// [SupabaseGymRepository] parses DB rows (`dto/db_rows.dart`) and maps them
/// through `dto/member_mapper.dart` (which runs the tested domain math), so
/// every implementation yields the exact shape the UI already expects.
library;

import '../store/models.dart';

abstract interface class GymRepository {
  // ── Reads ────────────────────────────────────────────────────────────
  Future<List<Member>> members();
  Future<Member?> memberById(String id);
  Future<List<Payment>> payments();

  /// Owner↔member thread (raw messages, oldest first).
  Future<List<Message>> ownerThread(String memberId);

  /// Member-side inbox (owner conversation + member↔member threads).
  Future<List<MemberConvo>> memberInbox(String meId);

  /// Owner inbox — every member↔owner thread, newest first.
  Future<List<ThreadSummary>> adminThreads();

  /// Total unread across the owner inbox (nav badge).
  Future<int> totalUnread();

  /// Noticeboard posts, newest first (pinned still sort by date here; the
  /// screen pins separately).
  Future<List<BoardPost>> boardPosts();
  Future<BoardPost?> boardPostById(String id);

  /// Members who registered (claimed a roster row) and await the owner's
  /// approval — `status = 'pending'`.
  Future<List<Member>> pendingMembers();
  Future<void> approveMember(String id);
  Future<void> rejectMember(String id);

  /// Normalised bubble list for [meId]'s view of a conversation with
  /// [peerId] ([kOwnerId] for the owner thread).
  Future<List<({bool mine, String text, DateTime at})>> conversation(
      String meId, String peerId);

  // ── Mutations ────────────────────────────────────────────────────────
  Future<void> confirmPayment(String paymentId);
  Future<void> addManualPayment({
    required String memberId,
    required int amount,
    required String tariff,
    required String type,
  });
  /// Create a noticeboard post (owner only). Returns the created post.
  Future<BoardPost> addBoardPost({
    required String type,
    required String title,
    required String body,
    bool pinned,
  });

  /// Patch a noticeboard post. Null fields are left unchanged.
  Future<void> updateBoardPost(
    String id, {
    String? type,
    String? title,
    String? body,
    bool? pinned,
  });
  Future<void> deleteBoardPost(String id);
  Future<void> setBoardPostPinned(String id, bool pinned);

  Future<Member> addMember(Member partial);
  Future<void> updateMember(String id, Member Function(Member) patch);
  Future<void> removeMember(String id);
  Future<void> importMembers({
    required List<Member> additions,
    required Map<String, Member> updates,
  });
  Future<void> pauseMembership(String id,
      {String? reason, required String notice});
  Future<void> resumeMembership(String id, {required String notice});

  /// Owner↔member message. [from] is `'olda'` (admin) or `'member'`.
  Future<void> sendOwnerMessage(String memberId, String text,
      {String from});
  Future<void> markOwnerThreadRead(String memberId);

  /// Member-side send ([peerId] = [kOwnerId] for the owner thread).
  Future<void> memberSend(String meId, String peerId, String text);
  Future<void> memberMarkRead(String meId, String peerId);
}
