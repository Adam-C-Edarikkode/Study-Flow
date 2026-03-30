// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timestamp.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 16;

  @override
  Timestamp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Timestamp(
      id: fields[0] as String,
      videoId: fields[1] as String,
      label: fields[2] as String,
      seconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoId)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.seconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimestampAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
