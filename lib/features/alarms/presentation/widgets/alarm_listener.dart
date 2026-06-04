import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../screens/alarm_ring_screen.dart';

class AlarmListener extends ConsumerStatefulWidget {
  final Widget child;
  const AlarmListener({super.key, required this.child});

  @override
  ConsumerState<AlarmListener> createState() => _AlarmListenerState();
}

class _AlarmListenerState extends ConsumerState<AlarmListener> {
  @override
  void initState() {
    super.initState();
    ref.read(alarmServiceProvider).ringStream.listen((settings) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: settings),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
