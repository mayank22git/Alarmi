import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.read(alarmServiceProvider).ringStream.listen((settings) {
      if (_isRinging) return;
      
      _isRinging = true;
      final context = rootNavigatorKey.currentState?.context;
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmRingScreen(alarmSettings: settings),
          ),
        ).then((_) => _isRinging = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
