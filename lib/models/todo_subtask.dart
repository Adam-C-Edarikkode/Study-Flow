import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo_subtask.g.dart';

@HiveType(typeId: 15)
class TodoSubTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String task;

  @HiveField(2)
  bool isCompleted;

  TodoSubTask({
    String? id,
    required this.task,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
}
