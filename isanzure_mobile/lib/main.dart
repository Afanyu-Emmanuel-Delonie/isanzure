import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isanzure_mobile/services/auth_service.dart';
import 'package:isanzure_mobile/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

// Your existing imports
import 'package:isanzure_mobile/core/constants/app_theme.dart';
import 'package:isanzure_mobile/views/splash/splash_view.dart';

// Your new architecture imports
import 'package:isanzure_mobile/core/network/api_client.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Core Base (API & Storage)
        Provider(create: (_) => const FlutterSecureStorage()),
        ProxyProvider<FlutterSecureStorage, ApiClient>(
          update: (_, storage, __) => ApiClient(storage),
        ),

        // 2. Service Layer (Depends on ApiClient and Storage)
        ProxyProvider2<ApiClient, FlutterSecureStorage, AuthService>(
          update: (_, api, storage, __) => AuthService(api, storage),
        ),

        // 3. ViewModel Layer (Depends on AuthService)
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
      ],
      child: const IsanzureApp(),
    ),
  );
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