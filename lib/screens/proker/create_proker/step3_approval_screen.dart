import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class Step3ApprovalScreen extends StatelessWidget {
  const Step3ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S t e p3 A p p r o v a l S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: S t e p3 A p p r o v a l S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
