import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'mind_map.g.dart';

@HiveType(typeId: 10)
class MindMapNode {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  double x;

  @HiveField(3)
  double y;

  @HiveField(4)
  final String? parentId;

  MindMapNode({
    String? id,
    required this.text,
    required this.x,
    required this.y,
    this.parentId,
  }) : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 9)
class MindMap extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final String? subjectId;

  @HiveField(3)
  final String? chapterId;

  @HiveField(4)
  List<MindMapNode> nodes;

  MindMap({
    String? id,
    required this.title,
    this.subjectId,
    this.chapterId,
    List<MindMapNode>? nodes,
  })  : id = id ?? const Uuid().v4(),
        nodes = nodes ?? [];
}
