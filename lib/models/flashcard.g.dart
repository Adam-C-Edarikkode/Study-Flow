// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 8;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      id: fields[0] as String?,
      front: fields[1] as String,
      back: fields[2] as String,
      subjectId: fields[3] as String?,
      chapterId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.front)
      ..writeByte(2)
      ..write(obj.back)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.chapterId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
