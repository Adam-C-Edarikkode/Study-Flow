import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/providers/todo_provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';

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

  void _editTodo(String id, String currentTask) {
    final editController = TextEditingController(text: currentTask);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Task name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  Provider.of<TodoProvider>(context, listen: false)
                      .updateTodo(id, editController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addSubTask(String todoId) {
    final subCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sub-task'),
        content: TextField(
          controller: subCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Sub-task name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (subCtrl.text.isNotEmpty) {
                Provider.of<TodoProvider>(context, listen: false).addSubTask(todoId, subCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String subText = '';
    if (widget.subjectId != null) {
      try {
        final subject = Provider.of<SubjectProvider>(context, listen: false).subjects.firstWhere((s) => s.id == widget.subjectId);
        subText = subject.name;
        if (widget.chapterId != null) {
          final chapter = Provider.of<ChapterProvider>(context, listen: false).chapters.firstWhere((c) => c.id == widget.chapterId);
          subText += ' > ${chapter.title}';
        }
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('To-do List'),
            if (subText.isNotEmpty)
              Text(subText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
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
                  heroTag: null,
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
                      child: Column(
                        children: [
                          ListTile(
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
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
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editTodo(todo.id, todo.task);
                                    } else if (value == 'delete') {
                                      provider.deleteTodo(todo.id);
                                    } else if (value == 'add_sub') {
                                      _addSubTask(todo.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'add_sub',
                                      child: ListTile(
                                        leading: Icon(Icons.add_circle_outline),
                                        title: Text('Add Sub-task'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Sub-tasks
                          if (todo.subTasks.isNotEmpty)
                            ...todo.subTasks.map((st) => Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: ListTile(
                                dense: true,
                                leading: Checkbox(
                                  value: st.isCompleted,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (_) => provider.toggleSubTask(todo.id, st.id),
                                ),
                                title: Text(
                                  st.task,
                                  style: TextStyle(
                                    fontSize: 13,
                                    decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                                    color: st.isCompleted ? Colors.grey : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => provider.deleteSubTask(todo.id, st.id),
                                ),
                              ),
                            )),
                          const Divider(height: 1),
                        ],
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
