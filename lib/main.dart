import 'package:flutter/material.dart';
import 'package:leadright/features/auth/presentation/pages/onboarding_page.dart';
import 'package:leadright/presentation/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeadRight',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const OnboardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
