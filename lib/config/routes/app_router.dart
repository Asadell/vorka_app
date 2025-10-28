import 'package:auto_route/auto_route.dart';
import 'package:vorka_app2/config/routes/auth_guard.dart';
import 'package:vorka_app2/screens/auth/login_screen.dart';
import 'package:vorka_app2/screens/auth/register_screen.dart';
import 'package:vorka_app2/screens/chat_pdf/chat_pdf_screen.dart';
import 'package:vorka_app2/screens/home/home_screen.dart';
import 'package:vorka_app2/screens/main/main_screen.dart';
import 'package:vorka_app2/screens/meetings/create_meeting_screen.dart';
import 'package:vorka_app2/screens/meetings/meeting_detail_screen.dart';
import 'package:vorka_app2/screens/meetings/meeting_list_screen.dart';
import 'package:vorka_app2/screens/meetings/qr_attendance_screen.dart';
import 'package:vorka_app2/screens/notifications/notification_screen.dart';
import 'package:vorka_app2/screens/notifications/request_detail_screen.dart';
import 'package:vorka_app2/screens/onboarding/add_departments_screen.dart';
import 'package:vorka_app2/screens/onboarding/create_org_screen.dart';
import 'package:vorka_app2/screens/onboarding/join_by_id_screen.dart';
import 'package:vorka_app2/screens/onboarding/join_by_qr_screen.dart';
import 'package:vorka_app2/screens/onboarding/onboarding_screen.dart';
import 'package:vorka_app2/screens/onboarding/select_role_screen.dart';
import 'package:vorka_app2/screens/profile/profile_screen.dart';
import 'package:vorka_app2/screens/proker/create_proker/step1_info_screen.dart';
import 'package:vorka_app2/screens/proker/create_proker/step2_timeline_screen.dart';
import 'package:vorka_app2/screens/proker/create_proker/step3_approval_screen.dart';
import 'package:vorka_app2/screens/proker/create_proker/step4_preparation_screen.dart';
import 'package:vorka_app2/screens/proker/proker_detail_screen.dart';
import 'package:vorka_app2/screens/proker/proker_list_screen.dart';
import 'package:vorka_app2/screens/structure/structure_screen.dart';
import 'package:vorka_app2/screens/tasks/create_task_screen.dart';
import 'package:vorka_app2/screens/tasks/task_detail_screen.dart';
import 'package:vorka_app2/screens/tasks/task_list_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // ========================================
    // PUBLIC ROUTES (Tidak perlu login)
    // ========================================
    AutoRoute(
      page: LoginRoute.page,
      initial: true, // Initial route
    ),
    AutoRoute(page: RegisterRoute.page),

    // ========================================
    // PROTECTED ROUTES (Harus login dulu)
    // Tambahkan guards: [AuthGuard()]
    // ========================================

    // Onboarding routes (protected)
    AutoRoute(
      page: OnboardingRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: CreateOrgRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: AddDepartmentsRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: JoinByIdRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: JoinByQrRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: SelectRoleRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),

    // Main screen with bottom navigation (protected)
    AutoRoute(
      page: MainRoute.page,
      guards: [AuthGuard()], // ← PROTECT SEMUA TABS
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: TaskListRoute.page),
        AutoRoute(page: MeetingListRoute.page),
        AutoRoute(page: ProkerListRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    // All other screens (protected)
    AutoRoute(
      page: StructureRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: NotificationRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: RequestDetailRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: TaskDetailRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: CreateTaskRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: MeetingDetailRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: CreateMeetingRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: QrAttendanceRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    AutoRoute(
      page: ProkerDetailRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
    // AutoRoute(
    //   page: CreateProkerStep1Route.page,
    //   guards: [AuthGuard()], // ← PROTECT
    // ),
    // AutoRoute(
    //   page: CreateProkerStep2Route.page,
    //   guards: [AuthGuard()], // ← PROTECT
    // ),
    // AutoRoute(
    //   page: CreateProkerStep3Route.page,
    //   guards: [AuthGuard()], // ← PROTECT
    // ),
    // AutoRoute(
    //   page: CreateProkerStep4Route.page,
    //   guards: [AuthGuard()], // ← PROTECT
    // ),
    AutoRoute(
      page: ChatPdfRoute.page,
      guards: [AuthGuard()], // ← PROTECT
    ),
  ];
}
