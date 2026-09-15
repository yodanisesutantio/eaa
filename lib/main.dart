import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_settings.dart';
import 'core/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  Object? startupError;
  try {
    await initializeSupabase();
  } catch (error) {
    startupError = error;
  }

  runApp(
    ProviderScope(
      child: ExpenseApp(startupError: startupError, settings: settings),
    ),
  );
}
