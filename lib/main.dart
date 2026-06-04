import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/alarm_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/service_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final alarmService = AlarmService();
  await alarmService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        alarmServiceProvider.overrideWithValue(alarmService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const AlarmiApp(),
    ),
  );
}
