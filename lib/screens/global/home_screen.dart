import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/screens/subject/subject_shell.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/note_provider.dart';
import 'package:study_app/providers/todo_provider.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/screens/global/search_screen.dart';
import 'package:study_app/widgets/notification_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: Consumer<SubjectProvider>(
        builder: (context, subjectProvider, child) {
          final subjects = subjectProvider.subjects;

          if (subjects.isEmpty) {
            return const Center(child: Text("No subjects yet. Add one!"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(context, subject);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddSubjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    // Generate a vibrant gradient based on the selected color
    final baseColor = Color(subject.colorValue);
    final hsl = HSLColor.fromColor(baseColor);
    final gradient = LinearGradient(
      colors: [
        hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
        hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Consumer<ChapterProvider>(
      builder: (context, chapterProvider, child) {
        final chaptersCount = chapterProvider.getChaptersForSubject(subject.id).length;
        
        return CustomCard(
          gradient: gradient,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubjectShell(
                  subject: subject,
                ),
              ),
            );
          },
          onLongPress: () => _showDeleteSubjectDialog(context, subject),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => _showDeleteSubjectDialog(context, subject),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatChip(context, Icons.menu_book_rounded, '$chaptersCount Chapters'),
                  const SizedBox(width: 12),
                  // Will connect StudyTime later dynamically
                  Consumer<StudyProvider>(
                    builder: (context, studyProvider, child) {
                      final mins = studyProvider.getTotalStudyTimeForSubject(subject.id);
                      final hoursStr = mins >= 60 ? '${mins ~/ 60}h ${mins % 60}m' : '${mins}m';
                      return _buildStatChip(context, Icons.timer_rounded, hoursStr);
                    },
                  ), 
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppTheme.primaryColor.value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              const SizedBox(height: 16),
              // Simple Color Picker Mock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _colorOption(context, AppTheme.primaryColor.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(context, AppTheme.cardGradient1.colors.first.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(context, AppTheme.cardGradient2.colors.first.value, selectedColor, (val) => selectedColor = val),
                  _colorOption(context, AppTheme.cardGradient3.colors.first.value, selectedColor, (val) => selectedColor = val),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Provider.of<SubjectProvider>(context, listen: false).addSubject(
                    nameController.text,
                    selectedColor,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(BuildContext context, int colorValue, int selectedValue, Function(int) onSelect) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            onSelect(colorValue);
            setState(() {});
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedValue == colorValue ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }
    );
  }

  void _showDeleteSubjectDialog(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject?'),
          content: Text('Are you sure you want to delete "${subject.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                final subjectId = subject.id;
                
                // Get all chapters to delete their specific data
                final chapterIds = Provider.of<ChapterProvider>(context, listen: false)
                    .getChaptersForSubject(subjectId)
                    .map((c) => c.id)
                    .toList();
                
                // Delete notes and sessions for each chapter
                for (final cId in chapterIds) {
                  Provider.of<NoteProvider>(context, listen: false).deleteNotesForChapter(cId);
                  Provider.of<StudyProvider>(context, listen: false).deleteSessionsForChapter(cId);
                }
                
                // Delete subject-level notes
                Provider.of<NoteProvider>(context, listen: false).deleteNotesForChapter(subjectId);
                
                // Delete subject-level sessions
                Provider.of<StudyProvider>(context, listen: false).deleteSessionsForSubject(subjectId);
                
                // Delete all chapters in subject
                Provider.of<ChapterProvider>(context, listen: false).deleteChaptersForSubject(subjectId);

                // Finally delete subject
                Provider.of<SubjectProvider>(context, listen: false).deleteSubject(subjectId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    NotificationSheet.show(context);
  }
}
