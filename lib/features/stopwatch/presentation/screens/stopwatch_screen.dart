import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> with AutomaticKeepAliveClientMixin {
  late Stopwatch _stopwatch;
  late Timer _timer;
  final List<Duration> _laps = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted && _stopwatch.isRunning) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  void _lap() {
    setState(() {
      _laps.insert(0, _stopwatch.elapsed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = threeDigits(duration.inMilliseconds.remainder(1000)).substring(0, 2);
    return "$minutes:$seconds.$milliseconds";
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
          child: Text('Stopwatch'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Text(
              _formatDuration(_stopwatch.elapsed),
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 80,
                fontWeight: FontWeight.w200,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                onPressed: _stopwatch.isRunning ? _lap : _reset,
                icon: _stopwatch.isRunning ? Icons.flag_outlined : Icons.refresh,
                label: _stopwatch.isRunning ? 'Lap' : 'Reset',
                isTonal: true,
              ),
              const SizedBox(width: 32),
              _ActionButton(
                onPressed: _toggle,
                icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                label: _stopwatch.isRunning ? 'Pause' : 'Resume',
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: _laps.isEmpty
                  ? Center(child: Text('No laps yet', style: theme.textTheme.bodyMedium))
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: _laps.length,
                      separatorBuilder: (context, index) => Divider(color: colorScheme.outline.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final lapIndex = _laps.length - index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lap $lapIndex',
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _formatDuration(_laps[index]),
                                style: TextStyle(
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
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
