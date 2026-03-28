// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mind_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindMapNodeAdapter extends TypeAdapter<MindMapNode> {
  @override
  final int typeId = 10;

  @override
  MindMapNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindMapNode(
      id: fields[0] as String?,
      text: fields[1] as String,
      x: fields[2] as double,
      y: fields[3] as double,
      parentId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MindMapNode obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.x)
      ..writeByte(3)
      ..write(obj.y)
      ..writeByte(4)
      ..write(obj.parentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindMapNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MindMapAdapter extends TypeAdapter<MindMap> {
  @override
  final int typeId = 9;

  @override
  MindMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindMap(
      id: fields[0] as String?,
      title: fields[1] as String,
      subjectId: fields[2] as String?,
      chapterId: fields[3] as String?,
      nodes: (fields[4] as List?)?.cast<MindMapNode>(),
    );
  }

  @override
  void write(BinaryWriter writer, MindMap obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.chapterId)
      ..writeByte(4)
      ..write(obj.nodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
