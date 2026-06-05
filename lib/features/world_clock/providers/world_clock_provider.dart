import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/city_model.dart';
import '../../../core/providers/service_providers.dart';
import '../../alarms/providers/alarm_action_provider.dart';
import 'dart:developer' as dev;

class WorldClockNotifier extends StateNotifier<List<CityModel>> {
  final Ref _ref;
  static const String _storageKey = 'selected_cities';

  WorldClockNotifier(this._ref) : super([]) {
    _loadCities();
  }

  void _loadCities() {
    final storage = _ref.read(storageServiceProvider);
    final List<dynamic>? storedData = storage.getSetting(_storageKey);
    
    if (storedData != null) {
      state = storedData.cast<CityModel>();
    } else {
      // Default cities if none stored
      state = [
        const CityModel(id: 'utc', name: 'UTC', timezone: 'UTC'),
        const CityModel(id: 'london', name: 'London', timezone: 'Europe/London'),
      ];
    }
  }

  Future<void> addCity(CityModel city) async {
    if (state.any((c) => c.timezone == city.timezone)) {
      dev.log('WORLD_CLOCK: City already exists: ${city.name}');
      return;
    }

    dev.log('WORLD_CLOCK: Adding city: ${city.name}');
    state = [...state, city];
    await _saveCities();
    
    _ref.read(alarmActionProvider.notifier).notify(
      AlarmActionType.add, 
      true, 
      message: '${city.name} added to World Clock',
    );
  }

  Future<void> removeCity(String id) async {
    dev.log('WORLD_CLOCK: Removing city ID: $id');
    state = state.where((c) => c.id != id).toList();
    await _saveCities();
    
    _ref.read(alarmActionProvider.notifier).notify(
      AlarmActionType.delete, 
      true, 
      message: 'City removed',
    );
  }

  Future<void> _saveCities() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSetting(_storageKey, state);
  }
}

final worldClockProvider = StateNotifierProvider<WorldClockNotifier, List<CityModel>>((ref) {
  return WorldClockNotifier(ref);
});
