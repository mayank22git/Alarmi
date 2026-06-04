import 'package:hive_flutter/hive_flutter.dart';
import '../../features/alarms/domain/models/alarm_model.dart';

class StorageService {
  static const String alarmBoxName = 'alarms';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(AlarmModelAdapter());
    
    // Open Boxes
    await Hive.openBox<AlarmModel>(alarmBoxName);
    await Hive.openBox(settingsBoxName);
  }

  Box<AlarmModel> get alarmBox => Hive.box<AlarmModel>(alarmBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);

  // Alarm Methods
  List<AlarmModel> getAlarms() => alarmBox.values.toList();
  
  Future<void> saveAlarm(AlarmModel alarm) async {
    await alarmBox.put(alarm.id, alarm);
  }

  Future<void> deleteAlarm(int id) async {
    await alarmBox.delete(id);
  }

  // Settings Methods
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }
}
