import 'package:flutter/material.dart';
import '../../domain/models/alarm_model.dart';
import '../../../../core/utils/date_formatter.dart';

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          DateFormatter.formatTime(alarm.dateTime),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: alarm.enabled ? null : Colors.grey,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alarm.label.isNotEmpty) Text(alarm.label),
            Text(
              alarm.daysOfWeek.isEmpty
                  ? 'Once'
                  : alarm.daysOfWeek.map(DateFormatter.formatDayOfWeek).join(', '),
            ),
          ],
        ),
        trailing: Switch(
          value: alarm.enabled,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
