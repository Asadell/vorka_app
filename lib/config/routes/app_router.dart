import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:vorka_app2/config/routes/auth_guard.dart';
import 'package:vorka_app2/models/join_request_model.dart';
import 'package:vorka_app2/models/organization_model.dart';
import 'package:vorka_app2/models/proker_model.dart';
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
import 'package:vorka_app2/screens/onboarding/waiting_approval_screen.dart';
import 'package:vorka_app2/screens/profile/profile_screen.dart';
import 'package:vorka_app2/screens/proker/proker_detail_screen.dart';
import 'package:vorka_app2/screens/proker/proker_list_screen.dart';
import 'package:vorka_app2/screens/proker/step1_info_screen.dart';
import 'package:vorka_app2/screens/proker/step2_timeline_screen.dart';
import 'package:vorka_app2/screens/proker/step3_approval_screen.dart';
import 'package:vorka_app2/screens/proker/step4_preparation_screen.dart';
import 'package:vorka_app2/screens/structure/structure_screen.dart';
import 'package:vorka_app2/screens/tasks/create_task_screen.dart';
import 'package:vorka_app2/screens/tasks/task_detail_screen.dart';
import 'package:vorka_app2/screens/tasks/task_list_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends _$AppRouter {
  AppRouter({super.navigatorKey});

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: LoginRoute.page,
      initial: true, // Initial route
    ),
    AutoRoute(page: RegisterRoute.page),

    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: CreateOrgRoute.page),
    AutoRoute(page: AddDepartmentsRoute.page),
    AutoRoute(page: JoinByIdRoute.page),
    AutoRoute(page: JoinByQrRoute.page),
    AutoRoute(page: SelectRoleRoute.page),
    AutoRoute(page: WaitingApprovalRoute.page),

    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: TaskListRoute.page),
        AutoRoute(page: MeetingListRoute.page),
        AutoRoute(page: ProkerListRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    AutoRoute(page: StructureRoute.page),
    AutoRoute(page: NotificationRoute.page),
    AutoRoute(page: RequestDetailRoute.page),
    AutoRoute(page: TaskDetailRoute.page),
    AutoRoute(page: CreateTaskRoute.page),
    AutoRoute(page: MeetingDetailRoute.page),
    AutoRoute(page: CreateMeetingRoute.page),
    AutoRoute(page: QrAttendanceRoute.page),
    AutoRoute(page: ProkerDetailRoute.page),
    AutoRoute(page: ChatPdfRoute.page),
  ];
}
