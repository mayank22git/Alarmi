import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import '../../../../core/providers/service_providers.dart';
import '../screens/alarm_ring_screen.dart';
import '../../../../routes/app_router.dart';

class AlarmListener extends ConsumerStatefulWidget {
  final Widget child;
  const AlarmListener({super.key, required this.child});

  @override
  ConsumerState<AlarmListener> createState() => _AlarmListenerState();
}

class _AlarmListenerState extends ConsumerState<AlarmListener> {
  bool _isRinging = false;

  @override
  void initState() {
    super.initState();
    _listenToRing();
    _checkInitialRing();
  }

  void _checkInitialRing() async {
    // Check if there are already ringing alarms on startup
    final alarms = await Alarm.getAlarms();
    final now = DateTime.now();
    
    // Alarms that should have fired in the last minute are likely the cause of the startup
    final potentiallyRinging = alarms.where((a) {
      final diff = now.difference(a.dateTime).inSeconds;
      return diff >= 0 && diff < 60;
    }).toList();

    if (potentiallyRinging.isNotEmpty) {
      debugPrint('ALARM_LISTENER: Found ${potentiallyRinging.length} potentially ringing alarms on startup');
      _showRingScreen(potentiallyRinging.first);
    }
  }

  void _listenToRing() {
    ref.read(alarmServiceProvider).ringStream.listen((settings) async {
      debugPrint('ALARM_LISTENER: Ringing detected for alarm ${settings.id}');
      
      // Request native takeover immediately
      try {
        await const MethodChannel('com.example.alarmi/alarm').invokeMethod('bringToForeground');
        debugPrint('ALARM_LISTENER: Native bringToForeground requested');
      } catch (e) {
        debugPrint('ALARM_LISTENER: Failed to bring to foreground: $e');
      }

      if (_isRinging) return;
      _isRinging = true;

      _showRingScreen(settings);
    });
  }

  Future<void> _showRingScreen(AlarmSettings settings) async {
    // Wait for navigator to be ready
    int attempts = 0;
    while (rootNavigatorKey.currentState == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (!mounted) return;

    final navigatorContext = rootNavigatorKey.currentState?.context;
    if (navigatorContext != null) {
      debugPrint('ALARM_LISTENER: Pushing AlarmRingScreen for alarm ${settings.id}');
      
      // Use a unique route name to allow detecting if we're already on this screen
      Navigator.push(
        navigatorContext,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: settings),
          settings: const RouteSettings(name: '/ringing'),
        ),
      ).then((_) {
        _isRinging = false;
      });
    } else {
      _isRinging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
