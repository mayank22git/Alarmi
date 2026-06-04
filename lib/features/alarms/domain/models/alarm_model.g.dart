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
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.daysOfWeek);
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
