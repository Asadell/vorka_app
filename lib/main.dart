import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vorka_app2/app.dart';
import 'package:vorka_app2/core/utils/notification_helper.dart';
import 'package:vorka_app2/providers/auth_provider.dart';
import 'package:vorka_app2/providers/organization_provider.dart';
import 'package:vorka_app2/providers/task_provider.dart';
import 'package:vorka_app2/providers/meeting_provider.dart';
import 'package:vorka_app2/providers/proker_provider.dart';
import 'package:vorka_app2/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  await NotificationHelper.initialize();
  await NotificationHelper.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => ProkerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
