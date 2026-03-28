import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/providers/todo_provider.dart';

class TodoListPage extends StatefulWidget {
  final String? subjectId;
  final String? chapterId;
  const TodoListPage({super.key, this.subjectId, this.chapterId});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _controller = TextEditingController();

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      Provider.of<TodoProvider>(context, listen: false)
          .addTodo(_controller.text, widget.subjectId, widget.chapterId);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _addTodo,
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final todos = provider.getTodosForContext(widget.subjectId, widget.chapterId);
                if (todos.isEmpty) {
                  return const Center(child: Text('No tasks here yet.'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Dismissible(
                      key: ValueKey(todo.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        provider.deleteTodo(todo.id);
                      },
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) {
                            provider.toggleTodo(todo.id);
                          },
                        ),
                        title: Text(
                          todo.task,
                          style: TextStyle(
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            todo.reminder ? Icons.notifications_active : Icons.notifications_none,
                            color: todo.reminder ? AppTheme.primaryColor : Colors.grey,
                          ),
                          onPressed: () {
                            provider.toggleReminder(todo.id);
                            final status = !todo.reminder ? 'Reminder set' : 'Reminder removed';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status), duration: const Duration(seconds: 1)));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
