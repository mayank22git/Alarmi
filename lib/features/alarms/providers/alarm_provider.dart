import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';
import '../domain/repositories/alarm_repository.dart';
import '../data/repositories/alarm_repository_impl.dart';
import '../../../../core/providers/service_providers.dart';

import 'alarm_action_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/alarm_utils.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AlarmRepositoryImpl(storageService);
});

class AlarmListNotifier extends StateNotifier<List<AlarmModel>> {
  final AlarmRepository _repository;
  final Ref _ref;

  AlarmListNotifier(this._repository, this._ref) : super([]) {
    _loadAlarms();
  }

  void _loadAlarms() {
    List<AlarmModel> alarms = _repository.getAlarms();
    final now = DateTime.now();
    bool changed = false;

    // Auto-disable expired one-time alarms
    for (int i = 0; i < alarms.length; i++) {
      final alarm = alarms[i];
      if (alarm.enabled && alarm.daysOfWeek.isEmpty && alarm.dateTime.isBefore(now)) {
        // If it's more than a few seconds past, consider it expired
        if (now.difference(alarm.dateTime).inSeconds > 5) {
          alarms[i] = alarm.copyWith(enabled: false);
          _repository.saveAlarm(alarms[i]);
          changed = true;
        }
      }
    }

    // Sort alarms by time of day (chronological)
    alarms.sort((a, b) {
      if (a.dateTime.hour != b.dateTime.hour) {
        return a.dateTime.hour.compareTo(b.dateTime.hour);
      }
      return a.dateTime.minute.compareTo(b.dateTime.minute);
    });
    state = alarms;
  }

  void refreshAlarms() {
    _loadAlarms();
  }

  AlarmModel _sanitizeAlarmTime(AlarmModel alarm) {
    final now = DateTime.now();
    final nextTime = AlarmUtils.getNextOccurrence(alarm, now);
    return alarm.copyWith(dateTime: nextTime);
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      final sanitizedAlarm = _sanitizeAlarmTime(alarm);
      await _repository.saveAlarm(sanitizedAlarm);
      _loadAlarms();
      if (sanitizedAlarm.enabled) {
        await _ref.read(alarmServiceProvider).scheduleAlarm(sanitizedAlarm);
      }
      
      final timeStr = DateFormatter.formatTime(sanitizedAlarm.dateTime);
      _ref.read(alarmActionProvider.notifier).notifySingle(
        AlarmActionType.add, 
        true, 
        message: 'Alarm set for $timeStr',
        alarm: sanitizedAlarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.add, false, message: 'Failed to add alarm');
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      final sanitizedAlarm = _sanitizeAlarmTime(alarm);
      await _repository.saveAlarm(sanitizedAlarm);
      _loadAlarms();
      if (sanitizedAlarm.enabled) {
        await _ref.read(alarmServiceProvider).scheduleAlarm(sanitizedAlarm);
      } else {
        await _ref.read(alarmServiceProvider).stopAlarm(sanitizedAlarm.id);
      }
      
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.update, true, message: 'Alarm updated');
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.update, false, message: 'Failed to update alarm');
    }
  }

  Future<void> toggleAlarm(AlarmModel alarm) async {
    try {
      bool isNowEnabled = !alarm.enabled;
      AlarmModel updatedAlarm = alarm.copyWith(enabled: isNowEnabled);

      if (isNowEnabled) {
        updatedAlarm = _sanitizeAlarmTime(updatedAlarm);
      }

      await _repository.saveAlarm(updatedAlarm);
      _loadAlarms();
      
      final alarmService = _ref.read(alarmServiceProvider);
      if (updatedAlarm.enabled) {
        await alarmService.scheduleAlarm(updatedAlarm);
      } else {
        await alarmService.stopAlarm(updatedAlarm.id);
      }

      final timeStr = DateFormatter.formatTime(updatedAlarm.dateTime);
      final message = updatedAlarm.enabled ? 'Alarm enabled for $timeStr' : 'Alarm disabled';
      
      _ref.read(alarmActionProvider.notifier).notifySingle(
        AlarmActionType.toggle, 
        true, 
        message: message,
        alarm: updatedAlarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.toggle, false, message: 'Failed to update alarm');
    }
  }

  Future<void> dismissAlarm(int id) async {
    final alarms = state;
    final index = alarms.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final alarm = alarms[index];
    AlarmModel updatedAlarm;

    if (alarm.daysOfWeek.isEmpty) {
      // Ring Once: Disable it
      updatedAlarm = alarm.copyWith(enabled: false);
    } else {
      // Repeating: Schedule next occurrence
      final now = DateTime.now();
      final nextTime = AlarmUtils.getNextOccurrence(alarm, now);
      updatedAlarm = alarm.copyWith(dateTime: nextTime);
    }

    await _repository.saveAlarm(updatedAlarm);
    _loadAlarms();
    
    final alarmService = _ref.read(alarmServiceProvider);
    await alarmService.stopAlarm(id); // Ensure it's stopped in the package
    
    if (updatedAlarm.enabled) {
      await alarmService.scheduleAlarm(updatedAlarm);
    }
  }

  Future<void> deleteAlarm(AlarmModel alarm) async {
    try {
      await _repository.deleteAlarm(alarm.id);
      _loadAlarms();
      await _ref.read(alarmServiceProvider).stopAlarm(alarm.id);
      
      _ref.read(alarmActionProvider.notifier).notifySingle(
        AlarmActionType.delete, 
        true, 
        message: 'Alarm deleted',
        alarm: alarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.delete, false, message: 'Failed to delete alarm');
    }
  }

  Future<void> deleteMultipleAlarms(List<AlarmModel> alarms) async {
    try {
      for (final alarm in alarms) {
        await _repository.deleteAlarm(alarm.id);
        await _ref.read(alarmServiceProvider).stopAlarm(alarm.id);
      }
      _loadAlarms();
      
      _ref.read(alarmActionProvider.notifier).notify(
        AlarmActionType.delete, 
        true, 
        message: 'Deleted ${alarms.length} alarms',
        alarms: alarms,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.delete, false, message: 'Failed to delete alarms');
    }
  }

  Future<void> undoDelete(List<AlarmModel> alarms) async {
    try {
      for (final alarm in alarms) {
        final sanitizedAlarm = alarm.enabled ? _sanitizeAlarmTime(alarm) : alarm;
        await _repository.saveAlarm(sanitizedAlarm);
        if (sanitizedAlarm.enabled) {
          await _ref.read(alarmServiceProvider).scheduleAlarm(sanitizedAlarm);
        }
      }
      _loadAlarms();
      
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.undo, true, message: 'Alarms restored');
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notifySingle(AlarmActionType.undo, false, message: 'Failed to restore alarms');
    }
  }
}

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<AlarmModel>>((ref) {
  final repository = ref.watch(alarmRepositoryProvider);
  return AlarmListNotifier(repository, ref);
});
