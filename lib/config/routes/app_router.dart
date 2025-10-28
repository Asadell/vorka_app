import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/screens/auth/login_screen.dart';
import 'package:vorka_app2/screens/auth/register_screen.dart';
import 'package:vorka_app2/screens/chat_pdf/chat_pdf_screen.dart';
import 'package:vorka_app2/screens/home/home_screen.dart';
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
    // Auth routes
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: RegisterRoute.page),

    // Onboarding routes
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: CreateOrgRoute.page),
    AutoRoute(page: AddDepartmentsRoute.page),
    AutoRoute(page: JoinByIdRoute.page),
    AutoRoute(page: JoinByQrRoute.page),
    AutoRoute(page: SelectRoleRoute.page),

    // Main routes
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: StructureRoute.page),

    // Task routes
    AutoRoute(page: TaskListRoute.page),
    AutoRoute(page: TaskDetailRoute.page),
    AutoRoute(page: CreateTaskRoute.page),

    // Meeting routes
    AutoRoute(page: MeetingListRoute.page),
    AutoRoute(page: MeetingDetailRoute.page),
    AutoRoute(page: CreateMeetingRoute.page),
    AutoRoute(page: QrAttendanceRoute.page),

    // Proker routes
    AutoRoute(page: ProkerListRoute.page),
    AutoRoute(page: ProkerDetailRoute.page),
    // AutoRoute(page: CreateProkerStep1Route.page),
    // AutoRoute(page: CreateProkerStep2Route.page),
    // AutoRoute(page: CreateProkerStep3Route.page),
    // AutoRoute(page: CreateProkerStep4Route.page),

    // Notification routes
    AutoRoute(page: NotificationRoute.page),
    AutoRoute(page: RequestDetailRoute.page),

    // Profile routes
    AutoRoute(page: ProfileRoute.page),

    // Chat PDF route
    AutoRoute(page: ChatPdfRoute.page),
  ];
}
