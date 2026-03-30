// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassScheduleAdapter extends TypeAdapter<ClassSchedule> {
  @override
  final int typeId = 14;

  @override
  ClassSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassSchedule(
      id: fields[0] as String?,
      subjectId: fields[1] as String,
      dayOfWeek: fields[2] as int,
      startTime: fields[3] as String,
      endTime: fields[4] as String,
      room: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClassSchedule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.dayOfWeek)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.room);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
