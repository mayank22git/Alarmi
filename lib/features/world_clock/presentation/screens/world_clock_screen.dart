import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import '../../../../core/utils/date_formatter.dart';
import '../../providers/world_clock_provider.dart';
import 'city_search_screen.dart';
import 'dart:developer' as dev;

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> with AutomaticKeepAliveClientMixin {
  late Timer _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final cities = ref.watch(worldClockProvider);
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 110.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text('World Clock', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                ),
              ),
              if (cities.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('No cities added', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)))),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final city = cities[index];
                        final location = tz.getLocation(city.timezone);
                        final now = tz.TZDateTime.now(location);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(city.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              ref.read(worldClockProvider.notifier).removeCity(city.id);
                            },
                            background: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Icon(Icons.delete_outline, color: colorScheme.onError),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: colorScheme.outline.withOpacity(0.1), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          city.name,
                                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${now.timeZoneName} • Today, ${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours}h',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatTime(now),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: cities.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              onPressed: () {
                dev.log('WORLD_CLOCK: Add city button pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CitySearchScreen()),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        );
      },
    );
  }
}
