import 'package:flutter_test/flutter_test.dart';
import 'package:alarmi/core/utils/alarm_utils.dart';
import 'package:alarmi/features/alarms/domain/models/alarm_model.dart';

void main() {
  group('AlarmUtils.getNextOccurrence', () {
    test('Ring Once: Future time today', () {
      final now = DateTime(2024, 1, 1, 8, 0); // Monday 8:00 AM
      final alarm = AlarmModel(
        id: 1,
        dateTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
        assetAudioPath: '',
        daysOfWeek: const [],
      );

      final next = AlarmUtils.getNextOccurrence(alarm, now);
      expect(next, DateTime(2024, 1, 1, 9, 0));
    });

    test('Ring Once: Past time today (should be tomorrow)', () {
      final now = DateTime(2024, 1, 1, 10, 0); // Monday 10:00 AM
      final alarm = AlarmModel(
        id: 1,
        dateTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
        assetAudioPath: '',
        daysOfWeek: const [],
      );

      final next = AlarmUtils.getNextOccurrence(alarm, now);
      expect(next, DateTime(2024, 1, 2, 9, 0)); // Tuesday 9:00 AM
    });

    test('Repeating: Mon/Wed/Fri, today Monday (future)', () {
      final now = DateTime(2024, 1, 1, 8, 0); // Monday 8:00 AM
      final alarm = AlarmModel(
        id: 1,
        dateTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
        assetAudioPath: '',
        daysOfWeek: const [1, 3, 5], // Mon, Wed, Fri
      );

      final next = AlarmUtils.getNextOccurrence(alarm, now);
      expect(next, DateTime(2024, 1, 1, 9, 0));
    });

    test('Repeating: Mon/Wed/Fri, today Monday (past, should be Wednesday)', () {
      final now = DateTime(2024, 1, 1, 10, 0); // Monday 10:00 AM
      final alarm = AlarmModel(
        id: 1,
        dateTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
        assetAudioPath: '',
        daysOfWeek: const [1, 3, 5], // Mon, Wed, Fri
      );

      final next = AlarmUtils.getNextOccurrence(alarm, now);
      expect(next, DateTime(2024, 1, 3, 9, 0)); // Wednesday 9:00 AM
    });

    test('Repeating: Weekend only, today Monday', () {
      final now = DateTime(2024, 1, 1, 8, 0); // Monday 8:00 AM
      final alarm = AlarmModel(
        id: 1,
        dateTime: DateTime(2024, 1, 1, 9, 0), // 9:00 AM
        assetAudioPath: '',
        daysOfWeek: const [6, 7], // Sat, Sun
      );

      final next = AlarmUtils.getNextOccurrence(alarm, now);
      expect(next, DateTime(2024, 1, 6, 9, 0)); // Saturday 9:00 AM
    });
  });
}
