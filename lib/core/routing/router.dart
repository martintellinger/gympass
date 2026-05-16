import 'package:go_router/go_router.dart';

import '../../features/admin/add_member.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/admin_messages.dart';
import '../../features/admin/admin_more.dart';
import '../../features/admin/admin_payments.dart';
import '../../features/admin/admin_thread.dart';
import '../../features/admin/approval_queue.dart';
import '../../features/admin/broadcast_composer.dart';
import '../../features/admin/member_detail.dart';
import '../../features/admin/member_list.dart';
import '../../features/member/board_screen.dart';
import '../../features/member/fault_report.dart';
import '../../features/member/history_screen.dart';
import '../../features/member/member_card.dart';
import '../../features/member/member_dashboard.dart';
import '../../features/member/profile_screen.dart';
import '../../features/member/qr_payment.dart';
import 'persona_picker.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const PersonaPicker()),

    // ── Member ──
    GoRoute(path: '/member/dashboard', builder: (c, s) => const MemberDashboardScreen()),
    GoRoute(path: '/member/card', builder: (c, s) => const MemberCardScreen()),
    GoRoute(path: '/member/history', builder: (c, s) => const HistoryScreenView()),
    GoRoute(path: '/member/board', builder: (c, s) => const BoardScreenView()),
    GoRoute(path: '/member/profile', builder: (c, s) => const ProfileScreenView()),
    GoRoute(path: '/member/qr', builder: (c, s) => const QrPaymentScreen()),
    GoRoute(path: '/member/fault', builder: (c, s) => const FaultReportScreen()),

    // ── Admin ──
    GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/list', builder: (c, s) => const MemberListScreen()),
    GoRoute(path: '/admin/payments', builder: (c, s) => const AdminPaymentsScreen()),
    GoRoute(path: '/admin/messages', builder: (c, s) => const AdminMessagesScreen()),
    GoRoute(path: '/admin/more', builder: (c, s) => const AdminMoreScreen()),
    GoRoute(path: '/admin/approval', builder: (c, s) => const ApprovalQueueScreen()),
    GoRoute(path: '/admin/add', builder: (c, s) => const AddMemberScreen()),
    GoRoute(path: '/admin/broadcast', builder: (c, s) => const BroadcastComposerScreen()),
    GoRoute(
      path: '/admin/member/:id',
      builder: (c, s) => MemberDetailScreen(memberId: s.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/admin/thread/:id',
      builder: (c, s) => AdminThreadScreen(memberId: s.pathParameters['id'] ?? ''),
    ),
  ],
);
