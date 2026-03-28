import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'drawing.g.dart';

@HiveType(typeId: 11)
class Drawing extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final String? subjectId;

  @HiveField(3)
  final String? chapterId;

  // Stored as JSON string to bypass nested generic lists issues in Hive
  @HiveField(4)
  String encodedPaths;

  Drawing({
    String? id,
    required this.title,
    this.subjectId,
    this.chapterId,
    this.encodedPaths = '[]',
  }) : id = id ?? const Uuid().v4();
}
