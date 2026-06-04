import '../models/alarm_model.dart';

abstract class AlarmRepository {
  List<AlarmModel> getAlarms();
  Future<void> saveAlarm(AlarmModel alarm);
  Future<void> deleteAlarm(int id);
}
