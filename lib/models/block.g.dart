// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockAdapter extends TypeAdapter<Block> {
  @override
  final int typeId = 4;

  @override
  Block read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Block(
      id: fields[0] as String,
      type: fields[1] as BlockType,
      content: fields[2] as String,
      order: fields[3] as int,
      isChecked: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Block obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BlockTypeAdapter extends TypeAdapter<BlockType> {
  @override
  final int typeId = 3;

  @override
  BlockType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BlockType.heading;
      case 1:
        return BlockType.text;
      case 2:
        return BlockType.bullet;
      case 3:
        return BlockType.checkbox;
      case 4:
        return BlockType.link;
      default:
        return BlockType.heading;
    }
  }

  @override
  void write(BinaryWriter writer, BlockType obj) {
    switch (obj) {
      case BlockType.heading:
        writer.writeByte(0);
        break;
      case BlockType.text:
        writer.writeByte(1);
        break;
      case BlockType.bullet:
        writer.writeByte(2);
        break;
      case BlockType.checkbox:
        writer.writeByte(3);
        break;
      case BlockType.link:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
