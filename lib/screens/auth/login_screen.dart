import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vorka_app2/config/routes/app_router.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('L o g i n S c r e e n'), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('Login Screen', style: TextStyle(fontSize: 24))),

          ElevatedButton(
            onPressed: () => context.router.push(OnboardingRoute()),
            child: Text('Onboarding Here'),
          ),

          ElevatedButton(
            onPressed: () => context.router.push(RegisterRoute()),
            child: Text('Register Here'),
          ),
        ],
      ),
    );
  }
}
