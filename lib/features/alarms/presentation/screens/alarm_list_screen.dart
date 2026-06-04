import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alarm_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../widgets/alarm_tile.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: alarms.isEmpty
          ? const Center(child: Text('No alarms set'))
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return AlarmTile(
                  alarm: alarm,
                  onToggle: (value) {
                    ref.read(alarmListProvider.notifier).toggleAlarm(alarm);
                  },
                  onDelete: () {
                    ref.read(alarmListProvider.notifier).deleteAlarm(alarm.id);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlarmEditScreen(alarm: alarm),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AlarmEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
