import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 8)
class Flashcard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String front;

  @HiveField(2)
  final String back;

  @HiveField(3)
  final String? subjectId;

  @HiveField(4)
  final String? chapterId;

  Flashcard({
    String? id,
    required this.front,
    required this.back,
    this.subjectId,
    this.chapterId,
  }) : id = id ?? const Uuid().v4();
}
