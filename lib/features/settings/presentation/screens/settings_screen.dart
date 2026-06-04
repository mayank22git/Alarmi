import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme Mode'),
            trailing: const Icon(Icons.brightness_6),
            onTap: () {
              // Toggle theme logic
            },
          ),
          SwitchListTile(
            title: const Text('24-hour format'),
            value: true,
            onChanged: (value) {
              // Update settings
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Default Ringtone'),
            subtitle: Text('Oxygen'),
          ),
          const ListTile(
            title: Text('Snooze Duration'),
            subtitle: Text('5 minutes'),
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
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
    );
  }
}
