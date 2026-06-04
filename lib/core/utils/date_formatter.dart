import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTime(DateTime dateTime, {bool is24Hour = false}) {
    return is24Hour
        ? DateFormat('HH:mm').format(dateTime)
        : DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  static String formatDayOfWeek(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
