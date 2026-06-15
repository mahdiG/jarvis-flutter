import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ZenAssistantApp());
}

class ZenAssistantApp extends StatelessWidget {
  const ZenAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen Assistant',
      debugShowCheckedModeBanner: false,
      theme: ZenTheme.light,
      home: const ChatScreen(),
    );
  }
}