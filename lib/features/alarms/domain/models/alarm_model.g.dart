// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 0;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as int,
      dateTime: fields[1] as DateTime,
      assetAudioPath: fields[2] as String,
      label: fields[3] as String,
      enabled: fields[4] as bool,
      vibrate: fields[5] as bool,
      volume: fields[6] as double,
      loopAudio: fields[7] as bool,
      fadeDuration: fields[8] as double,
      daysOfWeek: (fields[9] as List).cast<int>(),
      ringtoneTitle: fields[10] != null ? fields[10] as String : 'Default',
      isCustomRingtone: fields[11] != null ? fields[11] as bool : false,
      isCLocked: fields[12] != null ? fields[12] as bool : false,
      autoSnoozeMinutes: fields[13] != null ? fields[13] as int : 3,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.assetAudioPath)
      ..writeByte(3)
      ..write(obj.label)
      ..writeByte(4)
      ..write(obj.enabled)
      ..writeByte(5)
      ..write(obj.vibrate)
      ..writeByte(6)
      ..write(obj.volume)
      ..writeByte(7)
      ..write(obj.loopAudio)
      ..writeByte(8)
      ..write(obj.fadeDuration)
      ..writeByte(9)
      ..write(obj.daysOfWeek)
      ..writeByte(10)
      ..write(obj.ringtoneTitle)
      ..writeByte(11)
      ..write(obj.isCustomRingtone)
      ..writeByte(12)
      ..write(obj.isCLocked)
      ..writeByte(13)
      ..write(obj.autoSnoozeMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
