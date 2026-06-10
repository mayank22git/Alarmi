import 'package:alarm/alarm.dart';
import '../../features/alarms/domain/models/alarm_model.dart';
import 'dart:developer' as dev;

import 'dart:io';

class AlarmService {
  Future<void> init() async {
    await Alarm.init();
  }

  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    String audioPath = alarm.assetAudioPath;
    
    // Fallback logic for custom files
    if (alarm.isCustomRingtone) {
      final file = File(audioPath);
      if (!await file.exists()) {
        dev.log('ALARM_SERVICE: Custom ringtone file not found, falling back to default');
        audioPath = 'assets/audio/Ringing.mp3';
      }
    }

    final alarmSettings = AlarmSettings(
      id: alarm.isCLocked ? alarm.id + 100000 : alarm.id,
      dateTime: alarm.dateTime,
      assetAudioPath: audioPath,
      loopAudio: alarm.loopAudio,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fixed(
        volume: alarm.volume,
      ),
      notificationSettings: NotificationSettings(
        title: '', // Remove title to suppress banner content
        body: '',  // Remove body to suppress banner content
        stopButton: '', // Remove stop button
        icon: 'ic_launcher',
      ),
      androidFullScreenIntent: false, // Disable native FSI to prevent the pop-up panel (HUN)
    );

    dev.log('Scheduling alarm: ${alarm.id} at ${alarm.dateTime} with $audioPath');
    return await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<bool> stopAlarm(int id) async {
    return await Alarm.stop(id);
  }

  bool isRinging(int id) {
    return false; // Placeholder
  }

  Stream<AlarmSettings> get ringStream => Alarm.ringing.expand((set) => set.alarms);
}
