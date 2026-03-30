import 'package:study_app/models/todo.dart';
import 'package:study_app/models/todo_subtask.dart';

extension TodoSubTaskMapper on TodoSubTask {
  Map<String, dynamic> toMap() => {
        'id': id,
        'task': task,
        'isCompleted': isCompleted,
      };
}

extension TodoSubTaskFromMap on Map<String, dynamic> {
  TodoSubTask toTodoSubTask() => TodoSubTask(
        id: this['id'] as String?,
        task: this['task'] as String,
        isCompleted: this['isCompleted'] as bool? ?? false,
      );
}

extension TodoMapper on Todo {
  Map<String, dynamic> toMap() => {
        'id': id,
        'task': task,
        'isCompleted': isCompleted,
        'reminder': reminder,
        'subjectId': subjectId,
        'chapterId': chapterId,
        'subTasks': subTasks.map((s) => s.toMap()).toList(),
      };
}

extension TodoFromMap on Map<String, dynamic> {
  Todo toTodo() {
    final rawSubTasks = (this['subTasks'] as List<dynamic>?) ?? [];
    final subTasks = rawSubTasks
        .map((s) => (s as Map<String, dynamic>).toTodoSubTask())
        .toList();
    return Todo(
      id: this['id'] as String?,
      task: this['task'] as String,
      isCompleted: this['isCompleted'] as bool? ?? false,
      reminder: this['reminder'] as bool? ?? false,
      subjectId: this['subjectId'] as String?,
      chapterId: this['chapterId'] as String?,
      subTasks: subTasks,
    );
  }
}
