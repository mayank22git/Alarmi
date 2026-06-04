import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  void _startTimer(WidgetRef ref) {
    if (_isRunning) return;
    
    _remainingSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (_remainingSeconds == 0) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
        ref.read(notificationServiceProvider).showNotification(
          id: 100,
          title: 'Timer Finished',
          body: 'Your countdown has ended!',
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: _isRunning || _remainingSeconds > 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                      ),
                      Consumer(
                        builder: (context, ref, child) => FloatingActionButton.large(
                          onPressed: _isRunning ? _stopTimer : () => _startTimer(ref),
                          child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPicker('Hrs', 24, (val) => setState(() => _hours = val)),
                      _buildPicker('Min', 60, (val) => setState(() => _minutes = val)),
                      _buildPicker('Sec', 60, (val) => setState(() => _seconds = val)),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Consumer(
                    builder: (context, ref, child) => FloatingActionButton.large(
                      onPressed: () => _startTimer(ref),
                      child: const Icon(Icons.play_arrow),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPicker(String label, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label),
        SizedBox(
          height: 150,
          width: 70,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Center(
                child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 24)),
              ),
              childCount: max,
            ),
          ),
        ),
      ],
    );
  }
}
