import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

import '../../../../features/alarms/presentation/screens/ringtone_picker_screen.dart';
import '../../../../core/services/ringtone_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<int> snoozeOptions = [5, 10, 15, 20, 30];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsGroup(
            title: 'Appearance',
            children: [
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(settings.themeMode.name.toUpperCase()),
                trailing: Icon(Icons.brightness_6_outlined, color: colorScheme.primary),
                onTap: () {
                  final nextMode = settings.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  ref.read(settingsProvider.notifier).setThemeMode(nextMode);
                },
              ),
              SwitchListTile(
                title: const Text('24-hour format'),
                subtitle: const Text('Display time in 24-hour style'),
                value: settings.is24HourFormat,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).set24HourFormat(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Alarm Defaults',
            children: [
              ListTile(
                title: const Text('Default Ringtone'),
                subtitle: Text(settings.defaultRingtoneTitle),
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.4)),
                onTap: () async {
                  final RingtoneModel? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RingtonePickerScreen(currentPath: settings.defaultRingtone),
                    ),
                  );
                  if (result != null) {
                    ref.read(settingsProvider.notifier).setDefaultRingtone(result.path, result.title);
                  }
                },
              ),
              ListTile(
                title: const Text('Snooze Duration'),
                subtitle: Text('${settings.snoozeDuration} minutes'),
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.4)),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: colorScheme.surface,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (context) => ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: snoozeOptions.map((minutes) {
                        return RadioListTile<int>(
                          activeColor: colorScheme.primary,
                          title: Text('$minutes minutes', style: TextStyle(color: colorScheme.onSurface)),
                          value: minutes,
                          groupValue: settings.snoozeDuration,
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).setSnoozeDuration(value!);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'About',
            children: [
              ListTile(
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Alarmi',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          color: theme.colorScheme.surfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(children: children),
        ),
      ],
    );
  }
}
