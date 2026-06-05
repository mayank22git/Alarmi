import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/alarm_action_provider.dart';
import '../widgets/alarm_tile.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AlarmActionState>(alarmActionProvider, (previous, next) {
      if (next.message != null && next.timestamp != previous?.timestamp) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.message!),
              behavior: SnackBarBehavior.floating,
              action: next.type == AlarmActionType.delete && next.success
                  ? SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        if (next.alarm != null) {
                          ref.read(alarmListProvider.notifier).undoDelete(next.alarm!);
                        }
                      },
                    )
                  : null,
            ),
          );
      }
    });

    final alarms = ref.watch(alarmListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alarm', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                  if (alarms.any((a) => a.enabled))
                    Text(
                      'Next alarm in 7 hours', 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (alarms.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No alarms set', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final alarm = alarms[index];
                    return AlarmTile(
                      alarm: alarm,
                      onToggle: (value) {
                        ref.read(alarmListProvider.notifier).toggleAlarm(alarm);
                      },
                      onDelete: () {
                        ref.read(alarmListProvider.notifier).deleteAlarm(alarm);
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
                  childCount: alarms.length,
                ),
              ),
            ),
        ],
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
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
