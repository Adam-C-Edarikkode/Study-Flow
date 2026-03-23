import 'package:hive/hive.dart';

part 'block.g.dart';

@HiveType(typeId: 3)
enum BlockType {
  @HiveField(0)
  heading,
  @HiveField(1)
  text,
  @HiveField(2)
  bullet,
  @HiveField(3)
  checkbox,
  @HiveField(4)
  link
}

@HiveType(typeId: 4)
class Block extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  BlockType type;

  @HiveField(2)
  String content;

  @HiveField(3)
  int order;

  @HiveField(4)
  bool isChecked; // Only used if type == BlockType.checkbox

  Block({
    required this.id,
    required this.type,
    required this.content,
    required this.order,
    this.isChecked = false,
  });
}
