import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_screen.dart';
import 'features/home/home_screen.dart';
import 'features/transactions/screens/add_transaction_screen.dart';
import 'core/supabase_client.dart';
import 'core/theme.dart';
import 'core/app_settings.dart';
import 'features/settings/settings_screen.dart';

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key, this.startupError, required this.settings});

  final Object? startupError;
  final AppSettings settings;

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final signedIn = supabase.auth.currentSession != null;
      final onAuth = state.matchedLocation == '/auth';
      if (!signedIn && !onAuth) return '/auth';
      if (signedIn && onAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) =>
            AddTransactionScreen(settings: widget.settings),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(settings: widget.settings),
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, child) {
        final theme = widget.settings.appearance == 'dark'
            ? AppTheme.dark()
            : AppTheme.light();
        if (widget.startupError != null) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: theme,
            locale: Locale(widget.settings.languageCode),
            home: StartupErrorScreen(error: widget.startupError!),
          );
        }
        return MaterialApp.router(
          title: 'Expense Tracker',
          theme: theme,
          locale: Locale(widget.settings.languageCode),
          routerConfig: _router,
        );
      },
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Supabase is not configured',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Run Flutter with SUPABASE_URL and SUPABASE_ANON_KEY dart defines.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(error.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
