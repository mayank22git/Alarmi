import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/models/city_model.dart';
import '../../providers/world_clock_provider.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allTimezones = [];
  List<String> _filteredTimezones = [];

  @override
  void initState() {
    super.initState();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList();
    _filteredTimezones = _allTimezones;
  }

  void _filterTimezones(String query) {
    setState(() {
      _filteredTimezones = _allTimezones
          .where((tz) => tz.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search city or timezone...',
            border: InputBorder.none,
          ),
          onChanged: _filterTimezones,
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredTimezones.length,
        itemBuilder: (context, index) {
          final timezone = _filteredTimezones[index];
          final cityName = timezone.split('/').last.replaceAll('_', ' ');
          
          return ListTile(
            title: Text(cityName),
            subtitle: Text(timezone),
            onTap: () {
              final city = CityModel(
                id: timezone.hashCode.toString(),
                name: cityName,
                timezone: timezone,
              );
              context.read<WorldClockNotifier>(worldClockProvider.notifier).addCity(city);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

extension on BuildContext {
  T read<T>(ProviderListenable<T> provider) {
    return ProviderScope.containerOf(this).read(provider);
  }
}
