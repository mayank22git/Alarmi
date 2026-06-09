import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import 'dart:developer' as dev;

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return const _TimerView();
  }
}

class _TimerView extends ConsumerStatefulWidget {
  const _TimerView();

  @override
  ConsumerState<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<_TimerView> with AutomaticKeepAliveClientMixin {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    
    _remainingSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (_remainingSeconds == 0) return;

    dev.log('TIMER: Starting for $_remainingSeconds seconds');
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        dev.log('TIMER: Reached zero, calling _onTimerFinished');
        _onTimerFinished();
      }
    });
  }

  void _onTimerFinished() async {
    _stopTimer();

    try {
      await ref.read(notificationServiceProvider).showNotification(
        id: 100,
        title: 'Timer Finished',
        body: 'Your countdown has ended!',
      );
    } catch (e) {
      dev.log('TIMER: Error showing notification: $e');
    }

    try {
      final now = DateTime.now();
      final triggerTime = now.add(const Duration(seconds: 1));
      
      final alarmSettings = AlarmSettings(
        id: 999,
        dateTime: triggerTime,
        assetAudioPath: 'assets/audio/Ringing.mp3',
        loopAudio: true,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.8),
        notificationSettings: const NotificationSettings(
          title: 'Timer Finished',
          body: 'Time is up!',
          stopButton: 'Dismiss',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      dev.log('TIMER: Exception during Alarm.set: $e');
    }
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
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Timer'),
        ),
      ),
      body: Center(
        child: _isRunning || _remainingSeconds > 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          value: _isRunning ? _remainingSeconds / (_hours * 3600 + _minutes * 60 + _seconds) : 0,
                          strokeWidth: 8,
                          backgroundColor: colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        onPressed: _resetTimer,
                        icon: Icons.refresh,
                        label: 'Reset',
                        isTonal: true,
                      ),
                      const SizedBox(width: 32),
                      _ActionButton(
                        onPressed: _isRunning ? _stopTimer : _startTimer,
                        icon: _isRunning ? Icons.pause : Icons.play_arrow,
                        label: _isRunning ? 'Pause' : 'Resume',
                        isPrimary: true,
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
                  const SizedBox(height: 80),
                  _ActionButton(
                    onPressed: _startTimer,
                    icon: Icons.play_arrow,
                    label: 'Start',
                    isPrimary: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPicker(String label, int max, ValueChanged<int> onChanged) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        SizedBox(
          height: 180,
          width: 80,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 60,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              childCount: max,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isTonal;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.isTonal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary 
                  ? colorScheme.primary 
                  : (isTonal ? colorScheme.outline.withOpacity(0.1) : Colors.transparent),
              border: !isPrimary && !isTonal ? Border.all(color: colorScheme.outline.withOpacity(0.3)) : null,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
