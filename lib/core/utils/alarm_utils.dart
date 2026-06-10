import '../../features/alarms/domain/models/alarm_model.dart';

class AlarmUtils {
  /// Calculates the next occurrence of an alarm.
  /// 
  /// If the alarm is a "Ring Once" alarm (empty daysOfWeek), it returns the next
  /// occurrence of the time (today if still in the future, tomorrow otherwise).
  /// 
  /// If the alarm is a repeating alarm, it returns the next occurrence on one
  /// of the selected weekdays.
  static DateTime getNextOccurrence(AlarmModel alarm, DateTime now) {
    if (alarm.daysOfWeek.isEmpty) {
      // Ring Once
      DateTime occurrence = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.dateTime.hour,
        alarm.dateTime.minute,
        0,
        0,
      );

      if (occurrence.isBefore(now)) {
        occurrence = occurrence.add(const Duration(days: 1));
      }
      return occurrence;
    } else {
      // Repeating
      int currentDay = now.weekday;
      
      // Check days starting from today
      for (int i = 0; i < 8; i++) {
        int checkDay = ((currentDay + i - 1) % 7) + 1;
        if (alarm.daysOfWeek.contains(checkDay)) {
          DateTime occurrence = DateTime(
            now.year,
            now.month,
            now.day,
            alarm.dateTime.hour,
            alarm.dateTime.minute,
            0,
            0,
          ).add(Duration(days: i));

          if (occurrence.isAfter(now)) {
            return occurrence;
          }
        }
      }
      // Fallback (should not happen if daysOfWeek is not empty)
      return now.add(const Duration(days: 1));
    }
  }
}
