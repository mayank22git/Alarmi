import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
