import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'config.dart';
import 'screens/chat_screen.dart';
import 'screens/launcher_screen.dart';

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
      // Show the launcher home when enabled (Android), otherwise the chat screen.
      home: Config.launcherEnabled
          ? const ZenLauncherScreen()
          : const ChatScreen(),
      routes: {
        '/chat': (_) => const ChatScreen(),
        '/launcher': (_) => const ZenLauncherScreen(),
      },
    );
  }
}
