// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AddDepartmentsRoute.name: (routeData) {
      final args = routeData.argsAs<AddDepartmentsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AddDepartmentsScreen(
          key: args.key,
          orgName: args.orgName,
          orgDescription: args.orgDescription,
        ),
      );
    },
    ChatPdfRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChatPdfScreen(),
      );
    },
    CreateMeetingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateMeetingScreen(),
      );
    },
    CreateOrgRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateOrgScreen(),
      );
    },
    CreateTaskRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateTaskScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    JoinByIdRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const JoinByIdScreen(),
      );
    },
    JoinByQrRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const JoinByQrScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainScreen(),
      );
    },
    MeetingDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MeetingDetailScreen(),
      );
    },
    MeetingListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MeetingListScreen(),
      );
    },
    NotificationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationScreen(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingScreen(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileScreen(),
      );
    },
    ProkerDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProkerDetailScreen(),
      );
    },
    ProkerListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProkerListScreen(),
      );
    },
    QrAttendanceRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const QrAttendanceScreen(),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterScreen(),
      );
    },
    RequestDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RequestDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RequestDetailScreen(
          key: args.key,
          request: args.request,
        ),
      );
    },
    SelectRoleRoute.name: (routeData) {
      final args = routeData.argsAs<SelectRoleRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SelectRoleScreen(
          key: args.key,
          organization: args.organization,
        ),
      );
    },
    Step1InfoRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Step1InfoScreen(),
      );
    },
    Step2TimelineRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Step2TimelineScreen(),
      );
    },
    Step3ApprovalRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Step3ApprovalScreen(),
      );
    },
    Step4PreparationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Step4PreparationScreen(),
      );
    },
    StructureRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const StructureScreen(),
      );
    },
    TaskDetailRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TaskDetailScreen(),
      );
    },
    TaskListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TaskListScreen(),
      );
    },
    WaitingApprovalRoute.name: (routeData) {
      final args = routeData.argsAs<WaitingApprovalRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WaitingApprovalScreen(
          key: args.key,
          organizationName: args.organizationName,
        ),
      );
    },
  };
}

/// generated route for
/// [AddDepartmentsScreen]
class AddDepartmentsRoute extends PageRouteInfo<AddDepartmentsRouteArgs> {
  AddDepartmentsRoute({
    Key? key,
    required String orgName,
    required String orgDescription,
    List<PageRouteInfo>? children,
  }) : super(
          AddDepartmentsRoute.name,
          args: AddDepartmentsRouteArgs(
            key: key,
            orgName: orgName,
            orgDescription: orgDescription,
          ),
          initialChildren: children,
        );

  static const String name = 'AddDepartmentsRoute';

  static const PageInfo<AddDepartmentsRouteArgs> page =
      PageInfo<AddDepartmentsRouteArgs>(name);
}

class AddDepartmentsRouteArgs {
  const AddDepartmentsRouteArgs({
    this.key,
    required this.orgName,
    required this.orgDescription,
  });

  final Key? key;

  final String orgName;

  final String orgDescription;

  @override
  String toString() {
    return 'AddDepartmentsRouteArgs{key: $key, orgName: $orgName, orgDescription: $orgDescription}';
  }
}

/// generated route for
/// [ChatPdfScreen]
class ChatPdfRoute extends PageRouteInfo<void> {
  const ChatPdfRoute({List<PageRouteInfo>? children})
      : super(
          ChatPdfRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatPdfRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateMeetingScreen]
class CreateMeetingRoute extends PageRouteInfo<void> {
  const CreateMeetingRoute({List<PageRouteInfo>? children})
      : super(
          CreateMeetingRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateMeetingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateOrgScreen]
class CreateOrgRoute extends PageRouteInfo<void> {
  const CreateOrgRoute({List<PageRouteInfo>? children})
      : super(
          CreateOrgRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateOrgRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateTaskScreen]
class CreateTaskRoute extends PageRouteInfo<void> {
  const CreateTaskRoute({List<PageRouteInfo>? children})
      : super(
          CreateTaskRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateTaskRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [JoinByIdScreen]
class JoinByIdRoute extends PageRouteInfo<void> {
  const JoinByIdRoute({List<PageRouteInfo>? children})
      : super(
          JoinByIdRoute.name,
          initialChildren: children,
        );

  static const String name = 'JoinByIdRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [JoinByQrScreen]
class JoinByQrRoute extends PageRouteInfo<void> {
  const JoinByQrRoute({List<PageRouteInfo>? children})
      : super(
          JoinByQrRoute.name,
          initialChildren: children,
        );

  static const String name = 'JoinByQrRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MeetingDetailScreen]
class MeetingDetailRoute extends PageRouteInfo<void> {
  const MeetingDetailRoute({List<PageRouteInfo>? children})
      : super(
          MeetingDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'MeetingDetailRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MeetingListScreen]
class MeetingListRoute extends PageRouteInfo<void> {
  const MeetingListRoute({List<PageRouteInfo>? children})
      : super(
          MeetingListRoute.name,
          initialChildren: children,
        );

  static const String name = 'MeetingListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationScreen]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
      : super(
          NotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProkerDetailScreen]
class ProkerDetailRoute extends PageRouteInfo<void> {
  const ProkerDetailRoute({List<PageRouteInfo>? children})
      : super(
          ProkerDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProkerDetailRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProkerListScreen]
class ProkerListRoute extends PageRouteInfo<void> {
  const ProkerListRoute({List<PageRouteInfo>? children})
      : super(
          ProkerListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProkerListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [QrAttendanceScreen]
class QrAttendanceRoute extends PageRouteInfo<void> {
  const QrAttendanceRoute({List<PageRouteInfo>? children})
      : super(
          QrAttendanceRoute.name,
          initialChildren: children,
        );

  static const String name = 'QrAttendanceRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RequestDetailScreen]
class RequestDetailRoute extends PageRouteInfo<RequestDetailRouteArgs> {
  RequestDetailRoute({
    Key? key,
    required JoinRequestModel request,
    List<PageRouteInfo>? children,
  }) : super(
          RequestDetailRoute.name,
          args: RequestDetailRouteArgs(
            key: key,
            request: request,
          ),
          initialChildren: children,
        );

  static const String name = 'RequestDetailRoute';

  static const PageInfo<RequestDetailRouteArgs> page =
      PageInfo<RequestDetailRouteArgs>(name);
}

class RequestDetailRouteArgs {
  const RequestDetailRouteArgs({
    this.key,
    required this.request,
  });

  final Key? key;

  final JoinRequestModel request;

  @override
  String toString() {
    return 'RequestDetailRouteArgs{key: $key, request: $request}';
  }
}

/// generated route for
/// [SelectRoleScreen]
class SelectRoleRoute extends PageRouteInfo<SelectRoleRouteArgs> {
  SelectRoleRoute({
    Key? key,
    required OrganizationModel organization,
    List<PageRouteInfo>? children,
  }) : super(
          SelectRoleRoute.name,
          args: SelectRoleRouteArgs(
            key: key,
            organization: organization,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectRoleRoute';

  static const PageInfo<SelectRoleRouteArgs> page =
      PageInfo<SelectRoleRouteArgs>(name);
}

class SelectRoleRouteArgs {
  const SelectRoleRouteArgs({
    this.key,
    required this.organization,
  });

  final Key? key;

  final OrganizationModel organization;

  @override
  String toString() {
    return 'SelectRoleRouteArgs{key: $key, organization: $organization}';
  }
}

/// generated route for
/// [Step1InfoScreen]
class Step1InfoRoute extends PageRouteInfo<void> {
  const Step1InfoRoute({List<PageRouteInfo>? children})
      : super(
          Step1InfoRoute.name,
          initialChildren: children,
        );

  static const String name = 'Step1InfoRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Step2TimelineScreen]
class Step2TimelineRoute extends PageRouteInfo<void> {
  const Step2TimelineRoute({List<PageRouteInfo>? children})
      : super(
          Step2TimelineRoute.name,
          initialChildren: children,
        );

  static const String name = 'Step2TimelineRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Step3ApprovalScreen]
class Step3ApprovalRoute extends PageRouteInfo<void> {
  const Step3ApprovalRoute({List<PageRouteInfo>? children})
      : super(
          Step3ApprovalRoute.name,
          initialChildren: children,
        );

  static const String name = 'Step3ApprovalRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Step4PreparationScreen]
class Step4PreparationRoute extends PageRouteInfo<void> {
  const Step4PreparationRoute({List<PageRouteInfo>? children})
      : super(
          Step4PreparationRoute.name,
          initialChildren: children,
        );

  static const String name = 'Step4PreparationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [StructureScreen]
class StructureRoute extends PageRouteInfo<void> {
  const StructureRoute({List<PageRouteInfo>? children})
      : super(
          StructureRoute.name,
          initialChildren: children,
        );

  static const String name = 'StructureRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TaskDetailScreen]
class TaskDetailRoute extends PageRouteInfo<void> {
  const TaskDetailRoute({List<PageRouteInfo>? children})
      : super(
          TaskDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'TaskDetailRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TaskListScreen]
class TaskListRoute extends PageRouteInfo<void> {
  const TaskListRoute({List<PageRouteInfo>? children})
      : super(
          TaskListRoute.name,
          initialChildren: children,
        );

  static const String name = 'TaskListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WaitingApprovalScreen]
class WaitingApprovalRoute extends PageRouteInfo<WaitingApprovalRouteArgs> {
  WaitingApprovalRoute({
    Key? key,
    required String organizationName,
    List<PageRouteInfo>? children,
  }) : super(
          WaitingApprovalRoute.name,
          args: WaitingApprovalRouteArgs(
            key: key,
            organizationName: organizationName,
          ),
          initialChildren: children,
        );

  static const String name = 'WaitingApprovalRoute';

  static const PageInfo<WaitingApprovalRouteArgs> page =
      PageInfo<WaitingApprovalRouteArgs>(name);
}

class WaitingApprovalRouteArgs {
  const WaitingApprovalRouteArgs({
    this.key,
    required this.organizationName,
  });

  final Key? key;

  final String organizationName;

  @override
  String toString() {
    return 'WaitingApprovalRouteArgs{key: $key, organizationName: $organizationName}';
  }
}
