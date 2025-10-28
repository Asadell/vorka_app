import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('W a i t i n g A p p r o v a l S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: W a i t i n g A p p r o v a l S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
