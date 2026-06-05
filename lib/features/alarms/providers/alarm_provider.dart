import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';
import '../domain/repositories/alarm_repository.dart';
import '../data/repositories/alarm_repository_impl.dart';
import '../../../../core/providers/service_providers.dart';

import 'alarm_action_provider.dart';
import '../../../../core/utils/date_formatter.dart';

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
    state = _repository.getAlarms();
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      await _repository.saveAlarm(alarm);
      _loadAlarms();
      if (alarm.enabled) {
        await _ref.read(alarmServiceProvider).scheduleAlarm(alarm);
      }
      
      final timeStr = DateFormatter.formatTime(alarm.dateTime);
      _ref.read(alarmActionProvider.notifier).notify(
        AlarmActionType.add, 
        true, 
        message: 'Alarm set for $timeStr',
        alarm: alarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.add, false, message: 'Failed to add alarm');
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      await _repository.saveAlarm(alarm);
      _loadAlarms();
      if (alarm.enabled) {
        await _ref.read(alarmServiceProvider).scheduleAlarm(alarm);
      } else {
        await _ref.read(alarmServiceProvider).stopAlarm(alarm.id);
      }
      
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.update, true, message: 'Alarm updated');
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.update, false, message: 'Failed to update alarm');
    }
  }

  Future<void> toggleAlarm(AlarmModel alarm) async {
    try {
      final updatedAlarm = alarm.copyWith(enabled: !alarm.enabled);
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
      
      _ref.read(alarmActionProvider.notifier).notify(
        AlarmActionType.toggle, 
        true, 
        message: message,
        alarm: updatedAlarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.toggle, false, message: 'Failed to update alarm');
    }
  }

  Future<void> deleteAlarm(AlarmModel alarm) async {
    try {
      await _repository.deleteAlarm(alarm.id);
      _loadAlarms();
      await _ref.read(alarmServiceProvider).stopAlarm(alarm.id);
      
      _ref.read(alarmActionProvider.notifier).notify(
        AlarmActionType.delete, 
        true, 
        message: 'Alarm deleted',
        alarm: alarm,
      );
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.delete, false, message: 'Failed to delete alarm');
    }
  }

  Future<void> undoDelete(AlarmModel alarm) async {
    try {
      await _repository.saveAlarm(alarm);
      _loadAlarms();
      if (alarm.enabled) {
        await _ref.read(alarmServiceProvider).scheduleAlarm(alarm);
      }
      
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.undo, true, message: 'Alarm restored');
    } catch (e) {
      _ref.read(alarmActionProvider.notifier).notify(AlarmActionType.undo, false, message: 'Failed to restore alarm');
    }
  }
}

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<AlarmModel>>((ref) {
  final repository = ref.watch(alarmRepositoryProvider);
  return AlarmListNotifier(repository, ref);
});
