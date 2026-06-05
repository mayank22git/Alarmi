import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes/app_router.dart';
import '../core/theme/app_theme.dart';

import '../features/alarms/presentation/widgets/alarm_listener.dart';

import '../features/settings/providers/settings_provider.dart';

class AlarmiApp extends ConsumerWidget {
  const AlarmiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Alarmi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AlarmListener(child: child!);
      },
    );
  }
}
