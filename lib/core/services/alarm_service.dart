import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import '../../features/alarms/domain/models/alarm_model.dart';
import 'dart:developer' as dev;

class AlarmService {
  Future<void> init() async {
    await Alarm.init();
  }

  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    final alarmSettings = AlarmSettings(
      id: alarm.id,
      dateTime: alarm.dateTime,
      assetAudioPath: alarm.assetAudioPath,
      loopAudio: alarm.loopAudio,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fixed(
        volume: alarm.volume,
      ),
      notificationSettings: NotificationSettings(
        title: alarm.label.isEmpty ? 'Alarm' : alarm.label,
        body: 'Your alarm is ringing!',
        stopButton: 'Stop',
        icon: 'notification_icon', // Ensure this exists or use default
      ),
    );

    dev.log('Scheduling alarm: ${alarm.id} at ${alarm.dateTime} with ${alarm.assetAudioPath}');
    return await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<bool> stopAlarm(int id) async {
    return await Alarm.stop(id);
  }

  bool isRinging(int id) {
    return false; // Placeholder
  }

  Stream<AlarmSettings> get ringStream => Alarm.ringStream.stream;
}
