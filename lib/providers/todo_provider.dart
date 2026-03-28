import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final Box<Todo> _todosBox = HiveService.todosBox;

  List<Todo> get todos => _todosBox.values.toList();

  List<Todo> getTodosForContext(String? subjectId, String? chapterId) {
    if (subjectId == 'general') {
        return _todosBox.values.where((todo) => todo.subjectId == 'general').toList();
    }
    return _todosBox.values.where((todo) => todo.subjectId == subjectId && todo.chapterId == chapterId).toList();
  }

  Future<void> addTodo(String task, String? subjectId, String? chapterId) async {
    final todo = Todo(task: task, subjectId: subjectId, chapterId: chapterId);
    await _todosBox.put(todo.id, todo);
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final todo = _todosBox.get(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      await todo.save();
      notifyListeners();
    }
  }

  Future<void> toggleReminder(String id) async {
    final todo = _todosBox.get(id);
    if (todo != null) {
      todo.reminder = !todo.reminder;
      await todo.save();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    final todo = _todosBox.get(id);
    if (todo != null) {
      await todo.delete();
      notifyListeners();
    }
  }
}
