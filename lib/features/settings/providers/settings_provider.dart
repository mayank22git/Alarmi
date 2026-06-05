import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import 'dart:developer' as dev;

class SettingsState {
  final ThemeMode themeMode;
  final bool is24HourFormat;
  final String defaultRingtone;
  final int snoozeDuration;

  SettingsState({
    required this.themeMode,
    required this.is24HourFormat,
    required this.defaultRingtone,
    required this.snoozeDuration,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? is24HourFormat,
    String? defaultRingtone,
    int? snoozeDuration,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      defaultRingtone: defaultRingtone ?? this.defaultRingtone,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(SettingsState(
          themeMode: ThemeMode.dark,
          is24HourFormat: true,
          defaultRingtone: 'assets/audio/alarm.mp3',
          snoozeDuration: 5,
        )) {
    _loadSettings();
  }

  void _loadSettings() {
    final storage = _ref.read(storageServiceProvider);
    final themeIndex = storage.getSetting('themeMode', defaultValue: 2); // Dark
    final is24h = storage.getSetting('is24HourFormat', defaultValue: true);
    final ringtone = storage.getSetting('defaultRingtone', defaultValue: 'assets/audio/alarm.mp3');
    final snooze = storage.getSetting('snoozeDuration', defaultValue: 5);

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      is24HourFormat: is24h,
      defaultRingtone: ringtone,
      snoozeDuration: snooze,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    dev.log('Setting theme mode to: $mode');
    state = state.copyWith(themeMode: mode);
    await _ref.read(storageServiceProvider).saveSetting('themeMode', mode.index);
  }

  Future<void> set24HourFormat(bool value) async {
    dev.log('Setting 24-hour format to: $value');
    state = state.copyWith(is24HourFormat: value);
    await _ref.read(storageServiceProvider).saveSetting('is24HourFormat', value);
  }

  Future<void> setDefaultRingtone(String path) async {
    state = state.copyWith(defaultRingtone: path);
    await _ref.read(storageServiceProvider).saveSetting('defaultRingtone', path);
  }

  Future<void> setSnoozeDuration(int minutes) async {
    state = state.copyWith(snoozeDuration: minutes);
    await _ref.read(storageServiceProvider).saveSetting('snoozeDuration', minutes);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
