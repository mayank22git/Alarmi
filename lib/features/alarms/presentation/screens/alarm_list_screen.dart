import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/alarm_action_provider.dart';
import '../../providers/alarm_selection_provider.dart';
import '../widgets/alarm_tile.dart';
import 'alarm_edit_screen.dart';

import '../../providers/next_alarm_provider.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _confirmDeleteDialog(List<int> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete alarms?'),
        content: Text('Delete ${selectedIds.length} selected alarms?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedAlarms(selectedIds);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedAlarms(List<int> selectedIds) {
    final alarms = ref.read(alarmListProvider);
    final toDelete = alarms.where((a) => selectedIds.contains(a.id)).toList();
    
    ref.read(alarmListProvider.notifier).deleteMultipleAlarms(toDelete);
    ref.read(alarmSelectionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nextAlarm = ref.watch(nextAlarmProvider);
    final selectedIds = ref.watch(alarmSelectionProvider);
    final selectionNotifier = ref.read(alarmSelectionProvider.notifier);
    final isSelectionMode = selectedIds.isNotEmpty;

    ref.listen<AlarmActionState>(alarmActionProvider, (previous, next) {
      if (next.message != null && next.timestamp != previous?.timestamp) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.message!, style: TextStyle(color: colorScheme.onInverseSurface)),
              backgroundColor: colorScheme.inverseSurface,
              behavior: SnackBarBehavior.floating,
              action: next.type == AlarmActionType.delete && next.success
                  ? SnackBarAction(
                      label: 'UNDO',
                      textColor: colorScheme.inversePrimary,
                      onPressed: () {
                        if (next.alarms.isNotEmpty) {
                          ref.read(alarmListProvider.notifier).undoDelete(next.alarms);
                        }
                      },
                    )
                  : null,
            ),
          );
      }
    });

    final alarms = ref.watch(alarmListProvider);

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvoked: (didPop) {
        if (!didPop && isSelectionMode) {
          selectionNotifier.clear();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 110.0,
              floating: false,
              pinned: true,
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => selectionNotifier.clear(),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(
                  horizontal: isSelectionMode ? 56 : 16, 
                  vertical: 12,
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelectionMode ? '${selectedIds.length} selected' : 'Alarm',
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onBackground),
                    ),
                    if (!isSelectionMode)
                      Text(
                        nextAlarm.message, 
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.normal, 
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (!isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/settings'),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            if (alarms.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No alarms set', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alarm = alarms[index];
                      final isSelected = selectedIds.contains(alarm.id);
                      return AlarmTile(
                        alarm: alarm,
                        isSelected: isSelected,
                        isSelectionMode: isSelectionMode,
                        onToggle: (value) {
                          ref.read(alarmListProvider.notifier).toggleAlarm(alarm);
                        },
                        onDelete: () {
                          ref.read(alarmListProvider.notifier).deleteAlarm(alarm);
                        },
                        onLongPress: () {
                          selectionNotifier.select(alarm.id);
                        },
                        onTap: () {
                          if (isSelectionMode) {
                            selectionNotifier.toggle(alarm.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlarmEditScreen(alarm: alarm),
                              ),
                            );
                          }
                        },
                      );
                    },
                    childCount: alarms.length,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isSelectionMode
            ? FloatingActionButton.extended(
                onPressed: () => _confirmDeleteDialog(selectedIds.toList()),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.delete_outline),
                label: Text('Delete (${selectedIds.length})'),
              )
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlarmEditScreen(),
                    ),
                  );
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 28),
              ),
      ),
    );
  }
}
