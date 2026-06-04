import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../../../core/utils/date_formatter.dart';

class AlarmEditScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AlarmEditScreen({super.key, this.alarm});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late bool _vibrate;
  late bool _loopAudio;
  late double _volume;
  late List<int> _selectedDays;
  late String _selectedAudio;

  final List<Map<String, String>> _ringtones = [
    {'name': 'Default', 'path': 'assets/audio/alarm.mp3'},
    {'name': 'Ringtone 1', 'path': 'assets/audio/alarm1.mp3'},
    {'name': 'Ringtone 2', 'path': 'assets/audio/alarm2.mp3'},
    {'name': 'Ringtone 3', 'path': 'assets/audio/alarm3.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _selectedTime = alarm != null
        ? TimeOfDay.fromDateTime(alarm.dateTime)
        : TimeOfDay.now();
    _labelController = TextEditingController(text: alarm?.label ?? '');
    _vibrate = alarm?.vibrate ?? true;
    _loopAudio = alarm?.loopAudio ?? true;
    _volume = alarm?.volume ?? 0.7;
    _selectedDays = List.from(alarm?.daysOfWeek ?? []);
    _selectedAudio = alarm?.assetAudioPath ?? 'assets/audio/alarm.mp3';
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _save(WidgetRef ref) {
    final now = DateTime.now();
    DateTime scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the time is in the past, schedule for tomorrow
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    final alarm = AlarmModel(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      dateTime: scheduleTime,
      assetAudioPath: _selectedAudio,
      label: _labelController.text,
      vibrate: _vibrate,
      loopAudio: _loopAudio,
      volume: _volume,
      daysOfWeek: _selectedDays,
      enabled: true,
    );

    ref.read(alarmListProvider.notifier).addAlarm(alarm);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [
          Consumer(
            builder: (context, ref, child) => TextButton(
              onPressed: () => _save(ref),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Center(
              child: Text(
                _selectedTime.format(context),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'Work, School, etc.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Ringtone'),
            subtitle: Text(_ringtones.firstWhere((r) => r['path'] == _selectedAudio)['name']!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children: _ringtones.map((ringtone) {
                    return RadioListTile<String>(
                      title: Text(ringtone['name']!),
                      value: ringtone['path']!,
                      groupValue: _selectedAudio,
                      onChanged: (value) {
                        setState(() => _selectedAudio = value!);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Vibrate'),
            value: _vibrate,
            onChanged: (value) => setState(() => _vibrate = value),
          ),
          SwitchListTile(
            title: const Text('Loop Audio'),
            value: _loopAudio,
            onChanged: (value) => setState(() => _loopAudio = value),
          ),
          ListTile(
            title: const Text('Volume'),
            subtitle: Slider(
              value: _volume,
              onChanged: (value) => setState(() => _volume = value),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Repeat', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isSelected = _selectedDays.contains(day);
              return ChoiceChip(
                label: Text(DateFormatter.formatDayOfWeek(day)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
