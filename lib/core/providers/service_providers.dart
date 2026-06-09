import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';
import '../services/ringtone_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final ringtoneServiceProvider = Provider<RingtoneService>((ref) {
  final service = RingtoneService();
  ref.onDispose(() => service.dispose());
  return service;
});
