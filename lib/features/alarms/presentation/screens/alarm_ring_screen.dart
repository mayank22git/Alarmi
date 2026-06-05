import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/alarm_model.dart';
import '../../../settings/providers/settings_provider.dart';

class AlarmRingScreen extends ConsumerWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snoozeDuration = ref.watch(settingsProvider).snoozeDuration;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  DateFormatter.formatTime(DateTime.now()),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  alarmSettings.notificationSettings.title.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 2.0,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RingButton(
                  label: 'SNOOZE',
                  subLabel: '${snoozeDuration}m',
                  icon: Icons.snooze,
                  onPressed: () {
                    final snoozeAlarm = AlarmModel(
                      id: alarmSettings.id,
                      dateTime: DateTime.now().add(Duration(minutes: snoozeDuration)),
                      assetAudioPath: alarmSettings.assetAudioPath ?? 'assets/audio/alarm.mp3',
                      label: alarmSettings.notificationSettings.title,
                      loopAudio: alarmSettings.loopAudio,
                      vibrate: alarmSettings.vibrate,
                      volume: alarmSettings.volumeSettings.volume ?? 0.7,
                      fadeDuration: 0, 
                    );
                    
                    ref.read(alarmServiceProvider).scheduleAlarm(snoozeAlarm);
                    Navigator.pop(context);
                  },
                ),
                _RingButton(
                  label: 'DISMISS',
                  icon: Icons.close,
                  isPrimary: true,
                  onPressed: () {
                    ref.read(alarmServiceProvider).stopAlarm(alarmSettings.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _RingButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subLabel,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? colorScheme.primary : colorScheme.surfaceVariant,
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        if (subLabel != null)
          Text(
            subLabel!,
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}
