import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/alarms/presentation/screens/alarm_list_screen.dart';
import '../features/world_clock/presentation/screens/world_clock_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/stopwatch/presentation/screens/stopwatch_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/constants/app_colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

final appRouter = GoRouter(
  initialLocation: '/alarms',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
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

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getIndex(String location) {
    if (location.startsWith('/alarms')) return 0;
    if (location.startsWith('/world-clock')) return 1;
    if (location.startsWith('/timer')) return 2;
    if (location.startsWith('/stopwatch')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = getIndex(location);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _pageController.page?.round() != currentIndex) {
        _pageController.jumpToPage(currentIndex);
      }
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          switch (index) {
            case 0: context.go('/alarms'); break;
            case 1: context.go('/world-clock'); break;
            case 2: context.go('/timer'); break;
            case 3: context.go('/stopwatch'); break;
          }
        },
        children: const [
          AlarmListScreen(),
          WorldClockScreen(),
          TimerScreen(),
          StopwatchScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        elevation: 10,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.language_outlined),
            selectedIcon: Icon(Icons.language),
            label: 'World Clock',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty_outlined),
            selectedIcon: Icon(Icons.hourglass_empty),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
        ],
      ),
    );
  }
}
