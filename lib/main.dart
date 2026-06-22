import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dating_app/config/app_config.dart';
import 'package:dating_app/config/routes.dart';
import 'package:dating_app/themes/app_theme.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize ApiService
  ApiService().init();
  print('✅ ApiService initialized');

  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded successfully');
  } catch (e) {
    print('⚠️ .env file not found, using default values');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // ✅ Load saved tokens
  await AuthService().loadSavedTokens();
  print('✅ Saved tokens loaded');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}