// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_attendance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAttendanceAdapter extends TypeAdapter<SubjectAttendance> {
  @override
  final int typeId = 12;

  @override
  SubjectAttendance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectAttendance(
      id: fields[0] as String?,
      subjectName: fields[1] as String,
      totalClasses: fields[2] as int,
      attendedClasses: fields[3] as int,
      requiredPercentage: fields[4] as double,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectAttendance obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.totalClasses)
      ..writeByte(3)
      ..write(obj.attendedClasses)
      ..writeByte(4)
      ..write(obj.requiredPercentage)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAttendanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
