import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime createdDate;

  Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.createdDate,
  });
}
