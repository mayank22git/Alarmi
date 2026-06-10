import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';
import 'alarm_provider.dart';
import '../../../../core/utils/alarm_utils.dart';

class NextAlarmState {
  final String message;
  final Duration? remaining;

  NextAlarmState({required this.message, this.remaining});
}

class NextAlarmNotifier extends StateNotifier<NextAlarmState> {
  final Ref _ref;
  Timer? _timer;

  NextAlarmNotifier(this._ref) : super(NextAlarmState(message: 'No upcoming alarms')) {
    _startTimer();
    // Re-calculate when the alarm list changes
    _ref.listen(alarmListProvider, (_, __) => calculateNextAlarm());
    calculateNextAlarm();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => calculateNextAlarm());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void calculateNextAlarm() {
    final alarms = _ref.read(alarmListProvider);
    final enabledAlarms = alarms.where((a) => a.enabled).toList();

    if (enabledAlarms.isEmpty) {
      state = NextAlarmState(message: 'No upcoming alarms');
      return;
    }

    final now = DateTime.now();
    DateTime? earliest;
    bool foundExpired = false;

    for (final alarm in enabledAlarms) {
      DateTime nextOccurrence;

      if (alarm.daysOfWeek.isEmpty) {
        // One-time alarm
        nextOccurrence = alarm.dateTime;
        // If it's in the past, it shouldn't be considered upcoming
        if (nextOccurrence.isBefore(now)) {
          foundExpired = true;
          continue;
        }
      } else {
        // Repeating alarm
        nextOccurrence = AlarmUtils.getNextOccurrence(alarm, now);
      }

      if (earliest == null || nextOccurrence.isBefore(earliest)) {
        earliest = nextOccurrence;
      }
    }

    if (foundExpired) {
      // Trigger a cleanup in AlarmListNotifier to sync states
      Future.microtask(() => _ref.read(alarmListProvider.notifier).refreshAlarms());
    }

    if (earliest != null) {
      final diff = earliest.difference(now);
      state = NextAlarmState(
        message: _formatRemaining(diff),
        remaining: diff,
      );
    } else {
      state = NextAlarmState(message: 'No upcoming alarms');
    }
  }

  String _formatRemaining(Duration diff) {
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days day${days > 1 ? "s" : ""}');
    if (hours > 0) parts.add('$hours hour${hours > 1 ? "s" : ""}');
    if (minutes > 0 || (days == 0 && hours == 0)) {
       parts.add('$minutes minute${minutes != 1 ? "s" : ""}');
    }

    return 'Next alarm in ${parts.join(" ")}';
  }
}

final nextAlarmProvider = StateNotifierProvider<NextAlarmNotifier, NextAlarmState>((ref) {
  return NextAlarmNotifier(ref);
});
