import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/screens/chapter/tabs/chapter_add_time_tab.dart';
import 'package:study_app/screens/subject/tabs/subject_notes_tab.dart';
import 'package:study_app/screens/chapter/tabs/chapter_notes_tab.dart';
import 'package:study_app/screens/global/todo_list_page.dart';
import 'package:study_app/screens/global/flashcard_page.dart';
import 'package:study_app/screens/global/mind_map_page.dart';
import 'package:study_app/screens/global/drawing_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tools'),
      ),
      body: const ToolsGrid(),
    );
  }
}

class ToolsGrid extends StatelessWidget {
  final String? specificSubjectId;
  final String? specificChapterId;
  const ToolsGrid({super.key, this.specificSubjectId, this.specificChapterId});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final List<Map<String, dynamic>> tools = [
      {'title': 'Mind Map Builder', 'icon': Icons.account_tree_rounded, 'color': Colors.blue},
      {'title': 'Flashcards', 'icon': Icons.style_rounded, 'color': AppTheme.accentColor},
      {'title': 'To-do List', 'icon': Icons.check_circle_outline_rounded, 'color': AppTheme.success},
      {'title': 'Quick Notes', 'icon': Icons.edit_note_rounded, 'color': Colors.orange},
      {'title': 'Study Timer', 'icon': Icons.timer_rounded, 'color': Colors.purple},
      {'title': 'Freehand Canvas', 'icon': Icons.brush_rounded, 'color': Colors.red},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return CustomCard(
          onTap: () {
            if (tool['title'] == 'Freehand Canvas') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DrawingPage(subjectId: specificSubjectId, chapterId: specificChapterId)));
              return;
            }
            if (tool['title'] == 'Mind Map Builder') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MindMapPage(subjectId: specificSubjectId, chapterId: specificChapterId)));
              return;
            }
            if (tool['title'] == 'To-do List') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TodoListPage(subjectId: specificSubjectId, chapterId: specificChapterId)));
              return;
            }
            if (tool['title'] == 'Flashcards') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardPage(subjectId: specificSubjectId, chapterId: specificChapterId)));
              return;
            }
            if (tool['title'] == 'Study Timer' || tool['title'] == 'Quick Notes') {
              if (specificSubjectId != null) {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                   appBar: AppBar(title: Text(tool['title'])),
                   body: tool['title'] == 'Study Timer' 
                       ? ChapterAddTimeTab(subjectId: specificSubjectId!, chapterId: specificChapterId)
                       : (specificChapterId != null 
                            ? ChapterNotesTab(chapterId: specificChapterId!) 
                            : SubjectNotesTab(subjectId: specificSubjectId!)),
                 )));
              } else {
                 _showSelectSubjectDialog(context, tool['title'] == 'Study Timer');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tool['title']} coming soon!')));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tool['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tool['icon'],
                  size: 40,
                  color: tool['color'],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tool['title'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelectSubjectDialog(BuildContext context, bool isTimer) {
    final subjects = Provider.of<SubjectProvider>(context, listen: false).subjects;
    if (subjects.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a subject first!')));
       return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTimer ? 'Timer for Subject' : 'Notes for Subject'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(Icons.public, color: AppTheme.primaryColor),
                    title: const Text('General (Not Specified)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTool(context, isTimer, 'general');
                    },
                  );
                }
                final subject = subjects[index - 1];
                return ListTile(
                  title: Text(subject.name),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToTool(context, isTimer, subject.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTool(BuildContext context, bool isTimer, String subjectId) {
    if (isTimer) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Study Timer')),
            body: ChapterAddTimeTab(subjectId: subjectId),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Quick Notes')),
            body: SubjectNotesTab(subjectId: subjectId),
          ),
        ),
      );
    }
  }
}
