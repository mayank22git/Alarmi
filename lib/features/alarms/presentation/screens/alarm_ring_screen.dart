import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/models/alarm_model.dart';
import '../../../settings/providers/settings_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  late bool _isCLocked;

  @override
  void initState() {
    super.initState();
    // Use ID range to determine type (CLocked alarms have ID >= 100000)
    _isCLocked = widget.alarmSettings.id >= 100000;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_isCLocked, // Disable back button if CLocked
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: _isCLocked 
            ? _CLockedDismissView(alarmSettings: widget.alarmSettings)
            : _NormalDismissView(alarmSettings: widget.alarmSettings),
        ),
      ),
    );
  }
}

class _NormalDismissView extends ConsumerWidget {
  final AlarmSettings alarmSettings;
  const _NormalDismissView({required this.alarmSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snoozeDuration = ref.watch(settingsProvider).snoozeDuration;

    return Column(
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
                final isCLocked = alarmSettings.id >= 100000;
                final baseId = isCLocked ? alarmSettings.id - 100000 : alarmSettings.id;

                final snoozeAlarm = AlarmModel(
                  id: baseId,
                  dateTime: DateTime.now().add(Duration(minutes: snoozeDuration)),
                  assetAudioPath: alarmSettings.assetAudioPath ?? 'assets/audio/Ringing.mp3',
                  label: alarmSettings.notificationSettings.title,
                  loopAudio: alarmSettings.loopAudio,
                  vibrate: alarmSettings.vibrate,
                  volume: alarmSettings.volumeSettings.volume ?? 0.7,
                  fadeDuration: 0, 
                  isCLocked: isCLocked,
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
    );
  }
}

class _CLockedDismissView extends ConsumerStatefulWidget {
  final AlarmSettings alarmSettings;
  const _CLockedDismissView({required this.alarmSettings});

  @override
  ConsumerState<_CLockedDismissView> createState() => _CLockedDismissViewState();
}

class _CLockedDismissViewState extends ConsumerState<_CLockedDismissView> {
  final TextEditingController _controller = TextEditingController();
  late Timer _timer;
  String _currentTimeStr = '';
  String _requiredPhrase = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final oldPhrase = _requiredPhrase;
      _updateTime();
      if (oldPhrase != _requiredPhrase && mounted) {
        setState(() {});
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _currentTimeStr = DateFormat('hh:mm a').format(now);
    _requiredPhrase = "It's $_currentTimeStr already";
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _validateAndDismiss() {
    final input = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final target = _requiredPhrase.toLowerCase();

    if (input == target) {
      ref.read(alarmServiceProvider).stopAlarm(widget.alarmSettings.id);
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = "Phrase doesn't match. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        32,
        0,
        32,
        MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.lock_clock, size: 64, color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            _currentTimeStr,
            style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w200),
          ),
          const SizedBox(height: 8),
          Text(
            widget.alarmSettings.notificationSettings.title,
            style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 48),
          const Text(
            'Type the following exactly to dismiss:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _requiredPhrase,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type phrase here...',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _validateAndDismiss(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: _validateAndDismiss,
              child: const Text('DISMISS ALARM', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
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
