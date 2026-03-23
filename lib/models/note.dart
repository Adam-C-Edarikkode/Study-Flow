import 'package:hive/hive.dart';
import 'block.dart';

part 'note.g.dart';

@HiveType(typeId: 2)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String chapterId;

  @HiveField(2)
  String title;

  @HiveField(3)
  List<Block> blocks;

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  DateTime lastEdited;

  Note({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.blocks,
    required this.createdDate,
    required this.lastEdited,
  });
}
