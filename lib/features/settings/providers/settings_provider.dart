import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import 'dart:developer' as dev;

enum ButtonAction {
  snooze,
  dismiss,
}

class SettingsState {
  final ThemeMode themeMode;
  final bool is24HourFormat;
  final String defaultRingtone;
  final String defaultRingtoneTitle;
  final int snoozeDuration;
  final ButtonAction powerButtonAction;
  final ButtonAction volumeButtonAction;

  SettingsState({
    required this.themeMode,
    required this.is24HourFormat,
    required this.defaultRingtone,
    required this.defaultRingtoneTitle,
    required this.snoozeDuration,
    this.powerButtonAction = ButtonAction.snooze,
    this.volumeButtonAction = ButtonAction.snooze,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? is24HourFormat,
    String? defaultRingtone,
    String? defaultRingtoneTitle,
    int? snoozeDuration,
    ButtonAction? powerButtonAction,
    ButtonAction? volumeButtonAction,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      defaultRingtone: defaultRingtone ?? this.defaultRingtone,
      defaultRingtoneTitle: defaultRingtoneTitle ?? this.defaultRingtoneTitle,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      powerButtonAction: powerButtonAction ?? this.powerButtonAction,
      volumeButtonAction: volumeButtonAction ?? this.volumeButtonAction,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(SettingsState(
          themeMode: ThemeMode.dark,
          is24HourFormat: true,
          defaultRingtone: 'assets/audio/Ringing.mp3',
          defaultRingtoneTitle: 'Default',
          snoozeDuration: 5,
          powerButtonAction: ButtonAction.snooze,
          volumeButtonAction: ButtonAction.snooze,
        )) {
    _loadSettings();
  }

  void _loadSettings() {
    final storage = _ref.read(storageServiceProvider);
    final themeIndex = storage.getSetting('themeMode', defaultValue: 2); // Dark
    final is24h = storage.getSetting('is24HourFormat', defaultValue: true);
    final ringtone = storage.getSetting('defaultRingtone', defaultValue: 'assets/audio/Ringing.mp3');
    final ringtoneTitle = storage.getSetting('defaultRingtoneTitle', defaultValue: 'Default');
    final snooze = storage.getSetting('snoozeDuration', defaultValue: 5);
    final powerActionIndex = storage.getSetting('powerButtonAction', defaultValue: ButtonAction.snooze.index);
    final volumeActionIndex = storage.getSetting('volumeButtonAction', defaultValue: ButtonAction.snooze.index);

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      is24HourFormat: is24h,
      defaultRingtone: ringtone,
      defaultRingtoneTitle: ringtoneTitle,
      snoozeDuration: snooze,
      powerButtonAction: ButtonAction.values[powerActionIndex],
      volumeButtonAction: ButtonAction.values[volumeActionIndex],
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

  Future<void> setDefaultRingtone(String path, String title) async {
    state = state.copyWith(defaultRingtone: path, defaultRingtoneTitle: title);
    await _ref.read(storageServiceProvider).saveSetting('defaultRingtone', path);
    await _ref.read(storageServiceProvider).saveSetting('defaultRingtoneTitle', title);
  }

  Future<void> setSnoozeDuration(int minutes) async {
    state = state.copyWith(snoozeDuration: minutes);
    await _ref.read(storageServiceProvider).saveSetting('snoozeDuration', minutes);
  }

  Future<void> setPowerButtonAction(ButtonAction action) async {
    state = state.copyWith(powerButtonAction: action);
    await _ref.read(storageServiceProvider).saveSetting('powerButtonAction', action.index);
  }

  Future<void> setVolumeButtonAction(ButtonAction action) async {
    state = state.copyWith(volumeButtonAction: action);
    await _ref.read(storageServiceProvider).saveSetting('volumeButtonAction', action.index);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
