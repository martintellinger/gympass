import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/add_member.dart';
import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/admin_messages.dart';
import '../../features/admin/admin_more.dart';
import '../../features/admin/admin_payments.dart';
import '../../features/admin/admin_thread.dart';
import '../../features/admin/approval_queue.dart';
import '../../features/admin/broadcast_composer.dart';
import '../../features/admin/excel_import/excel_import_wizard.dart';
import '../../features/admin/member_detail.dart';
import '../../features/admin/member_list.dart';
import '../../features/member/board_screen.dart';
import '../../features/member/fault_report.dart';
import '../../features/member/history_screen.dart';
import '../../features/member/member_card.dart';
import '../../features/member/member_dashboard.dart';
import '../../features/member/member_messages.dart';
import '../../features/member/member_thread.dart';
import '../../features/member/profile_screen.dart';
import '../../features/member/qr_payment.dart';
import '../../features/styleguide/styleguide_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'persona_picker.dart';

final _memberKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());
final _adminKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

StatefulShellBranch _branch(GlobalKey<NavigatorState> key, String path,
        Widget Function(BuildContext, GoRouterState) builder) =>
    StatefulShellBranch(
      navigatorKey: key,
      routes: [GoRoute(path: path, builder: builder)],
    );

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const PersonaPicker()),
    GoRoute(
        path: '/styleguide', builder: (c, s) => const StyleguideScreen()),

    // ── Member tab shell — persistent nav, state preserved per branch ──
    StatefulShellRoute.indexedStack(
      builder: (c, s, shell) => MemberShell(navigationShell: shell),
      branches: [
        _branch(_memberKeys[0], '/member/dashboard',
            (c, s) => const MemberDashboardScreen()),
        _branch(_memberKeys[1], '/member/messages',
            (c, s) => const MemberMessagesScreen()),
        _branch(_memberKeys[2], '/member/history',
            (c, s) => const HistoryScreenView()),
        _branch(_memberKeys[3], '/member/board',
            (c, s) => const BoardScreenView()),
        _branch(_memberKeys[4], '/member/profile',
            (c, s) => const ProfileScreenView()),
      ],
    ),

    // ── Admin tab shell ──
    StatefulShellRoute.indexedStack(
      builder: (c, s, shell) => AdminShell(navigationShell: shell),
      branches: [
        _branch(_adminKeys[0], '/admin',
            (c, s) => const AdminDashboardScreen()),
        _branch(_adminKeys[1], '/admin/list',
            (c, s) => const MemberListScreen()),
        _branch(_adminKeys[2], '/admin/payments',
            (c, s) => const AdminPaymentsScreen()),
        _branch(_adminKeys[3], '/admin/messages',
            (c, s) => const AdminMessagesScreen()),
        _branch(_adminKeys[4], '/admin/more',
            (c, s) => const AdminMoreScreen()),
      ],
    ),

    // ── Full-screen sub-pages (push above the shell, no tab bar) ──
    GoRoute(path: '/member/card', builder: (c, s) => const MemberCardScreen()),
    GoRoute(path: '/member/qr', builder: (c, s) => const QrPaymentScreen()),
    GoRoute(path: '/member/fault', builder: (c, s) => const FaultReportScreen()),
    GoRoute(
      path: '/member/thread/:id',
      builder: (c, s) =>
          MemberThreadScreen(peerId: s.pathParameters['id'] ?? 'olda'),
    ),
    GoRoute(
        path: '/admin/approval',
        builder: (c, s) => const ApprovalQueueScreen()),
    GoRoute(
        path: '/admin/add',
        builder: (c, s) =>
            AddMemberScreen(editMemberId: s.uri.queryParameters['id'])),
    GoRoute(
        path: '/admin/import', builder: (c, s) => const ExcelImportWizard()),
    GoRoute(
        path: '/admin/broadcast',
        builder: (c, s) => const BroadcastComposerScreen()),
    GoRoute(
      path: '/admin/member/:id',
      builder: (c, s) =>
          MemberDetailScreen(memberId: s.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/admin/thread/:id',
      builder: (c, s) =>
          AdminThreadScreen(memberId: s.pathParameters['id'] ?? ''),
    ),
  ],
);
