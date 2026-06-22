// lib/config/routes.dart
import 'package:dating_app/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:dating_app/screens/auth/login_screen.dart';
import 'package:dating_app/screens/auth/register_screen.dart';
import 'package:dating_app/screens/auth/verify_otp_screen.dart';
import 'package:dating_app/screens/home/home_screen.dart';
import 'package:dating_app/screens/swipe/swipe_screen.dart';
import 'package:dating_app/screens/matches/matches_screen.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:dating_app/screens/profile/edit_profile_screen.dart';
import 'package:dating_app/screens/profile/settings_screen.dart';
import 'package:dating_app/screens/onboarding/onboarding_screen.dart';

final router = GoRouter(
  // ✅ Make sure this is '/splash'
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      name: 'verify-otp',
      builder: (context, state) => const VerifyOTPScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'swipe',
          name: 'swipe',
          builder: (context, state) => const SwipeScreen(),
        ),
        GoRoute(
          path: 'matches',
          name: 'matches',
          builder: (context, state) => const MatchesScreen(),
        ),
        GoRoute(
          path: 'chat/:matchId',
          name: 'chat',
          builder: (context, state) => ChatScreen(
            matchId: state.pathParameters['matchId']!,
          ),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'profile/edit',
          name: 'edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);