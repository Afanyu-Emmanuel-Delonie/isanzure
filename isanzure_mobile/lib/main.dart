import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isanzure_mobile/services/auth_service.dart';
import 'package:isanzure_mobile/services/booking_service.dart';
import 'package:isanzure_mobile/services/transit_service.dart';
import 'package:isanzure_mobile/viewmodels/auth_viewmodel.dart';
import 'package:isanzure_mobile/viewmodels/home_viewmodel.dart';
import 'package:isanzure_mobile/viewmodels/bookings_viewmodel.dart';
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
        ProxyProvider<ApiClient, TransitService>(
          update: (_, api, __) => TransitService(api),
        ),
        ProxyProvider<ApiClient, BookingService>(
          update: (_, api, __) => BookingService(api),
        ),

        // 3. ViewModel Layer (Depends on AuthService)
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<TransitService>(), context.read<BookingService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BookingsViewModel(context.read<BookingService>()),
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