import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/model/alarm_settings.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/utils/date_formatter.dart';

import '../../domain/models/alarm_model.dart';

class AlarmRingScreen extends ConsumerWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              DateFormatter.formatTime(DateTime.now()),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              alarmSettings.notificationSettings.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final snoozeAlarm = AlarmModel(
                      id: alarmSettings.id,
                      dateTime: DateTime.now().add(const Duration(minutes: 5)),
                      assetAudioPath: alarmSettings.assetAudioPath ?? 'assets/audio/alarm.mp3',
                      label: alarmSettings.notificationSettings.title,
                      loopAudio: alarmSettings.loopAudio,
                      vibrate: alarmSettings.vibrate,
                      volume: alarmSettings.volumeSettings.volume ?? 0.7,
                      fadeDuration: 0, // Default for snooze
                    );
                    
                    ref.read(alarmServiceProvider).scheduleAlarm(snoozeAlarm);
                    Navigator.pop(context);
                  },
                  child: const Text('Snooze (5m)'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    ref.read(alarmServiceProvider).stopAlarm(alarmSettings.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
