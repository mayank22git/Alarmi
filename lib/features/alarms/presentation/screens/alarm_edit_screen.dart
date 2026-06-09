import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../settings/providers/settings_provider.dart';

import 'ringtone_picker_screen.dart';
import '../../../../core/services/ringtone_service.dart';

class AlarmEditScreen extends ConsumerStatefulWidget {
  final AlarmModel? alarm;

  const AlarmEditScreen({super.key, this.alarm});

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late DateTime _selectedDateTime;
  late TextEditingController _labelController;
  late bool _vibrate;
  late bool _loopAudio;
  late double _volume;
  late List<int> _selectedDays;
  String? _selectedAudio;
  late String _ringtoneTitle;
  late bool _isCustomRingtone;
  late bool _isCLocked;

  final List<Map<String, String>> _ringtones = [
    {'name': 'Default', 'path': 'assets/audio/Ringing.mp3'},
    {'name': 'Ringtone 1', 'path': 'assets/audio/EMERGENCY.mp3'},
    {'name': 'Ringtone 2', 'path': 'assets/audio/Melody.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _selectedDateTime = alarm?.dateTime ?? DateTime.now().add(const Duration(minutes: 1));
    _labelController = TextEditingController(text: alarm?.label ?? '');
    _vibrate = alarm?.vibrate ?? true;
    _loopAudio = alarm?.loopAudio ?? true;
    _volume = alarm?.volume ?? 0.7;
    _selectedDays = List.from(alarm?.daysOfWeek ?? []);
    _selectedAudio = alarm?.assetAudioPath;
    _ringtoneTitle = alarm?.ringtoneTitle ?? 'Default';
    _isCustomRingtone = alarm?.isCustomRingtone ?? false;
    _isCLocked = alarm?.isCLocked ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final now = DateTime.now();
    // Reset seconds and milliseconds to avoid "past" triggers
    DateTime scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedDateTime.hour,
      _selectedDateTime.minute,
      0, // seconds
      0, // milliseconds
    );

    // If the calculated time is before "now", schedule it for tomorrow
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    final settings = ref.read(settingsProvider);
    final defaultAudio = settings.defaultRingtone;
    final defaultTitle = settings.defaultRingtoneTitle;

    final alarm = AlarmModel(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      dateTime: scheduleTime,
      assetAudioPath: _selectedAudio ?? defaultAudio,
      ringtoneTitle: _ringtoneTitle,
      isCustomRingtone: _isCustomRingtone,
      isCLocked: _isCLocked,
      label: _labelController.text,
      vibrate: _vibrate,
      loopAudio: _loopAudio,
      volume: _volume,
      daysOfWeek: _selectedDays,
      enabled: true,
    );

    if (widget.alarm == null) {
      ref.read(alarmListProvider.notifier).addAlarm(alarm);
    } else {
      ref.read(alarmListProvider.notifier).updateAlarm(alarm);
    }
    Navigator.pop(context);
  }

  String _getCountdownText() {
    final now = DateTime.now();
    DateTime target = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedDateTime.hour,
      _selectedDateTime.minute,
    );
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final diff = target.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours == 0) return 'Ring in $minutes minutes';
    return 'Ring in $hours hours $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultAudio = ref.watch(settingsProvider).defaultRingtone;
    final effectiveAudio = _selectedAudio ?? defaultAudio;
    final ringtoneName = _ringtones.firstWhere(
      (r) => r['path'] == effectiveAudio, 
      orElse: () => _ringtones[0]
    )['name']!;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.alarm == null ? 'New Alarm' : 'Edit Alarm',
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _save,
              child: Text('Save', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Time Picker Section
              SizedBox(
                height: 220,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: theme.brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _selectedDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _selectedDateTime = newDateTime;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getCountdownText(),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 32),

              // Repeat Days Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Repeat', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final day = index + 1;
                          final isSelected = _selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? colorScheme.primary : colorScheme.surface,
                                border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline),
                              ),
                              child: Center(
                                child: Text(
                                  DateFormatter.formatDayOfWeek(day).substring(0, 1),
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Alarm Type Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alarm Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                              label: 'Normal',
                              isSelected: !_isCLocked,
                              onTap: () => setState(() => _isCLocked = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeChip(
                              label: 'CLocked',
                              isSelected: _isCLocked,
                              onTap: () => setState(() => _isCLocked = true),
                            ),
                          ),
                        ],
                      ),
                      if (_isCLocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Requires typing a phrase to dismiss.',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Label Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alarm Label', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _labelController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Morning Workout',
                          fillColor: theme.scaffoldBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.music_note, color: colorScheme.primary),
                        title: const Text('Ringtone'),
                        subtitle: Text(_ringtoneTitle, style: theme.textTheme.bodyMedium),
                        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.4)),
                        onTap: () async {
                          final RingtoneModel? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RingtonePickerScreen(currentPath: effectiveAudio),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedAudio = result.path;
                              _ringtoneTitle = result.title;
                              _isCustomRingtone = result.source == RingtoneSource.custom;
                            });
                          }
                        },
                      ),
                      Divider(height: 1, color: colorScheme.outline.withOpacity(0.2), indent: 56),
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: colorScheme.primary),
                        title: const Text('Vibrate'),
                        value: _vibrate,
                        onChanged: (value) => setState(() => _vibrate = value),
                      ),
                      Divider(height: 1, color: colorScheme.outline.withOpacity(0.2), indent: 56),
                      ListTile(
                        leading: Icon(Icons.volume_up, color: colorScheme.primary),
                        title: const Text('Alarm Volume'),
                        subtitle: Slider(
                          value: _volume,
                          activeColor: colorScheme.primary,
                          inactiveColor: colorScheme.outline.withOpacity(0.3),
                          onChanged: (value) => setState(() => _volume = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
