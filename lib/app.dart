import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/reminder_service.dart';
import 'core/theme.dart';
import 'core/user_prefs.dart';
import 'router.dart';

class BlueArrowApp extends ConsumerWidget {
  const BlueArrowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderSyncProvider); // keeps scheduled deadline reminders in sync
    return MaterialApp.router(
      title: 'Blue Arrow',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(userPrefsProvider.select((p) => p.themeMode)),
      routerConfig: router,
    );
  }
}
