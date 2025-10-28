import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class ChatPdfScreen extends StatelessWidget {
  const ChatPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('C h a t P d f S c r e e n'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Screen: C h a t P d f S c r e e n',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
