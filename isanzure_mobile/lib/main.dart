import 'package:flutter/material.dart';
import 'package:isanzure_mobile/core/constants/app_theme.dart';
import 'package:isanzure_mobile/views/splash/splash_view.dart';

void main() {
  runApp(const IsanzureApp());
}

class IsanzureApp extends StatelessWidget {
  const IsanzureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isanzure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashView(),
    );
  }
}
