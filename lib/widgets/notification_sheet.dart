import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/providers/todo_provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/academic_provider.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/models/chapter.dart';
import 'package:study_app/models/academic/subject_attendance.dart';

class NotificationSheet extends StatelessWidget {
  final ScrollController scrollController;
  const NotificationSheet({super.key, required this.scrollController});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return NotificationSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<TodoProvider, SubjectProvider, ChapterProvider, AcademicProvider>(
      builder: (context, todoProvider, subProvider, chapProvider, acadProvider, child) {
        final pendingTodos = todoProvider.todos.where((t) => !t.isCompleted && t.reminder).toList();
        final dangerSubjects = acadProvider.subjects.where((s) => !s.isSafe).toList();

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (dangerSubjects.isNotEmpty) ...[
                    _sectionHeader(context, 'Attendance Alerts', Icons.warning_amber_rounded, AppTheme.error),
                    ...dangerSubjects.map((s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.school, color: AppTheme.error),
                      title: Text(s.subjectName),
                      subtitle: Text('At Risk: ${s.attendancePercentage.toStringAsFixed(s.attendancePercentage % 1 == 0 ? 0 : 1)}%'),
                      trailing: Text('Can miss: ${s.classesCanMiss}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                    const SizedBox(height: 24),
                  ],
                  _sectionHeader(context, 'Pending Tasks', Icons.checklist_rtl_rounded, AppTheme.primaryColor),
                  if (pendingTodos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('All tasks completed!')),
                    )
                  else
                    ...pendingTodos.map((task) {
                      String contextInfo = '';
                      if (task.subjectId == 'general') {
                        contextInfo = 'General';
                      } else if (task.subjectId != null) {
                        final Subject? sub = subProvider.subjects.cast<Subject?>().firstWhere((s) => s?.id == task.subjectId, orElse: () => null);
                        final String sName = sub?.name ?? 'Unknown';
                        if (task.chapterId != null) {
                          final Chapter? chap = chapProvider.chapters.cast<Chapter?>().firstWhere((c) => c?.id == task.chapterId, orElse: () => null);
                          final String cName = chap?.title ?? 'Unknown';
                          contextInfo = '$sName > $cName';
                        } else {
                          contextInfo = sName;
                        }
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.circle_outlined, color: Colors.grey),
                        title: Text(task.task),
                        subtitle: contextInfo.isNotEmpty 
                          ? Text(contextInfo, style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor)) 
                          : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                          onPressed: () => todoProvider.toggleTodo(task.id),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
