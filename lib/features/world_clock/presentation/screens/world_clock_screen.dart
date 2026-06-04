import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import '../../../../core/utils/date_formatter.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  late Timer _timer;
  final List<String> _selectedLocations = ['UTC', 'America/New_York', 'Europe/London', 'Asia/Tokyo'];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
      ),
      body: ListView.builder(
        itemCount: _selectedLocations.length,
        itemBuilder: (context, index) {
          final locationName = _selectedLocations[index];
          final location = tz.getLocation(locationName);
          final now = tz.TZDateTime.now(location);
          
          return ListTile(
            title: Text(locationName.split('/').last.replaceAll('_', ' ')),
            subtitle: Text(tz.TZDateTime.now(location).timeZoneName),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormatter.formatTime(now),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Today, ${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours}h',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show search dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
