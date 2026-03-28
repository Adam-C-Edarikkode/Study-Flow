import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 7)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String task;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  bool reminder;

  @HiveField(4)
  final String? subjectId;

  @HiveField(5)
  final String? chapterId;

  Todo({
    String? id,
    required this.task,
    this.isCompleted = false,
    this.reminder = false,
    this.subjectId,
    this.chapterId,
  }) : id = id ?? const Uuid().v4();
}
