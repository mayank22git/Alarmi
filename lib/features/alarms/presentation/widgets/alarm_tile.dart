import 'package:flutter/material.dart';
import '../../domain/models/alarm_model.dart';
import '../../../../core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeStr = DateFormat('hh:mm').format(alarm.dateTime);
    final amPmStr = DateFormat('a').format(alarm.dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key(alarm.id.toString() + alarm.dateTime.toIso8601String()),
        direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          decoration: BoxDecoration(
            color: colorScheme.error.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(Icons.delete_outline, color: colorScheme.onError, size: 24),
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 92),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? colorScheme.primary.withOpacity(0.1) 
                  : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected 
                    ? colorScheme.primary 
                    : (alarm.enabled ? colorScheme.primary.withOpacity(0.3) : colorScheme.outline.withOpacity(0.2)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeStr,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: alarm.enabled || isSelected ? colorScheme.onSurface : theme.textTheme.bodyMedium?.color,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            amPmStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: alarm.enabled || isSelected ? colorScheme.onSurface : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${alarm.label.isNotEmpty ? "${alarm.label} • " : ""}${alarm.daysOfWeek.isEmpty ? "Ring once" : alarm.daysOfWeek.map(DateFormatter.formatDayOfWeek).join(", ")}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    shape: const CircleBorder(),
                  )
                else
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: alarm.enabled,
                      onChanged: onToggle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
