import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  final List<Duration> _laps = [];

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
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              _formatDuration(_stopwatch.elapsed),
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200),
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                iconSize: 32,
                onPressed: _stopwatch.isRunning ? _lap : _reset,
                icon: Icon(_stopwatch.isRunning ? Icons.flag : Icons.refresh),
              ),
              FloatingActionButton.large(
                onPressed: _toggle,
                child: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('Lap ${_laps.length - index}'),
                  trailing: Text(_formatDuration(_laps[index])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
