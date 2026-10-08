import 'package:flutter/material.dart';

import 'member1/app_theme.dart';
import 'member1/home_page.dart';

void main() {
  runApp(const OSSandboxApp());
}

class OSSandboxApp extends StatelessWidget {
  const OSSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OS Sandbox',
      debugShowCheckedModeBanner: false,

      // Apply the shared Member 1 design system.
      theme: AppTheme.lightTheme,

      // Open the dashboard when the app starts.
      home: const HomePage(),
    );
  }
}