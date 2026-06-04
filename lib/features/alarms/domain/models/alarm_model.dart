import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class AlarmModel extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final DateTime dateTime;
  @HiveField(2)
  final String assetAudioPath;
  @HiveField(3)
  final String label;
  @HiveField(4)
  final bool enabled;
  @HiveField(5)
  final bool vibrate;
  @HiveField(6)
  final double volume;
  @HiveField(7)
  final bool loopAudio;
  @HiveField(8)
  final double fadeDuration;
  @HiveField(9)
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday

  const AlarmModel({
    required this.id,
    required this.dateTime,
    required this.assetAudioPath,
    this.label = '',
    this.enabled = true,
    this.vibrate = true,
    this.volume = 0.7,
    this.loopAudio = true,
    this.fadeDuration = 0.0,
    this.daysOfWeek = const [],
  });

  AlarmModel copyWith({
    int? id,
    DateTime? dateTime,
    String? assetAudioPath,
    String? label,
    bool? enabled,
    bool? vibrate,
    double? volume,
    bool? loopAudio,
    double? fadeDuration,
    List<int>? daysOfWeek,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      assetAudioPath: assetAudioPath ?? this.assetAudioPath,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      vibrate: vibrate ?? this.vibrate,
      volume: volume ?? this.volume,
      loopAudio: loopAudio ?? this.loopAudio,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dateTime,
        assetAudioPath,
        label,
        enabled,
        vibrate,
        volume,
        loopAudio,
        fadeDuration,
        daysOfWeek,
      ];
}
