// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_subtask.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoSubTaskAdapter extends TypeAdapter<TodoSubTask> {
  @override
  final int typeId = 15;

  @override
  TodoSubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoSubTask(
      id: fields[0] as String?,
      task: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TodoSubTask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.task)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoSubTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
