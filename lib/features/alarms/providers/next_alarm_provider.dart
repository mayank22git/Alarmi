import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';
import 'alarm_provider.dart';

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

    for (final alarm in enabledAlarms) {
      DateTime nextOccurrence;

      if (alarm.daysOfWeek.isEmpty) {
        // One-time alarm
        nextOccurrence = DateTime(
          now.year, now.month, now.day,
          alarm.dateTime.hour, alarm.dateTime.minute, 0, 0,
        );
        if (nextOccurrence.isBefore(now)) {
          nextOccurrence = nextOccurrence.add(const Duration(days: 1));
        }
      } else {
        // Repeating alarm
        nextOccurrence = _getNextRepeatingOccurrence(alarm, now);
      }

      if (earliest == null || nextOccurrence.isBefore(earliest)) {
        earliest = nextOccurrence;
      }
    }

    if (earliest != null) {
      final diff = earliest.difference(now);
      state = NextAlarmState(
        message: _formatRemaining(diff),
        remaining: diff,
      );
    }
  }

  DateTime _getNextRepeatingOccurrence(AlarmModel alarm, DateTime now) {
    // 1 = Monday, 7 = Sunday
    int currentDay = now.weekday;
    
    // Check days in a circle starting from today
    for (int i = 0; i < 8; i++) {
      int checkDay = ((currentDay + i - 1) % 7) + 1;
      if (alarm.daysOfWeek.contains(checkDay)) {
        DateTime occurrence = DateTime(
          now.year, now.month, now.day,
          alarm.dateTime.hour, alarm.dateTime.minute, 0, 0,
        ).add(Duration(days: i));

        if (occurrence.isAfter(now)) {
          return occurrence;
        }
      }
    }
    return now.add(const Duration(days: 1)); // Fallback
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
