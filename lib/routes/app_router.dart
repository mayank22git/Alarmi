import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/alarms/presentation/screens/alarm_list_screen.dart';
import '../features/world_clock/presentation/screens/world_clock_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/stopwatch/presentation/screens/stopwatch_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

import '../features/alarms/presentation/widgets/alarm_listener.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/alarms',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AlarmListener(child: MainScreen(child: child));
      },
      routes: [
        GoRoute(
          path: '/alarms',
          builder: (context, state) => const AlarmListScreen(),
        ),
        GoRoute(
          path: '/world-clock',
          builder: (context, state) => const WorldClockScreen(),
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/stopwatch',
          builder: (context, state) => const StopwatchScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    int getIndex() {
      if (location.startsWith('/alarms')) return 0;
      if (location.startsWith('/world-clock')) return 1;
      if (location.startsWith('/timer')) return 2;
      if (location.startsWith('/stopwatch')) return 3;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: getIndex(),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/alarms'); break;
            case 1: context.go('/world-clock'); break;
            case 2: context.go('/timer'); break;
            case 3: context.go('/stopwatch'); break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.language),
            label: 'World Clock',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
        ],
      ),
    );
  }
}
