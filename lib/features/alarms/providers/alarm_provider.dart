import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';
import '../domain/repositories/alarm_repository.dart';
import '../data/repositories/alarm_repository_impl.dart';
import '../../../../core/providers/service_providers.dart';

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
    // 1. Save to DB
    await _repository.saveAlarm(alarm);
    
    // 2. Update UI instantly
    _loadAlarms();
    
    // 3. Schedule with Native Service
    if (alarm.enabled) {
      final alarmService = _ref.read(alarmServiceProvider);
      await alarmService.scheduleAlarm(alarm);
    }
  }

  Future<void> toggleAlarm(AlarmModel alarm) async {
    final updatedAlarm = alarm.copyWith(enabled: !alarm.enabled);
    
    // 1. Save to DB
    await _repository.saveAlarm(updatedAlarm);
    
    // 2. Update UI instantly
    _loadAlarms();
    
    // 3. Update Native Service
    final alarmService = _ref.read(alarmServiceProvider);
    if (updatedAlarm.enabled) {
      await alarmService.scheduleAlarm(updatedAlarm);
    } else {
      await alarmService.stopAlarm(updatedAlarm.id);
    }
  }

  Future<void> deleteAlarm(int id) async {
    // 1. Remove from DB
    await _repository.deleteAlarm(id);
    
    // 2. Update UI instantly
    _loadAlarms();
    
    // 3. Stop Native Alarm
    await _ref.read(alarmServiceProvider).stopAlarm(id);
  }
}

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<AlarmModel>>((ref) {
  final repository = ref.watch(alarmRepositoryProvider);
  return AlarmListNotifier(repository, ref);
});
