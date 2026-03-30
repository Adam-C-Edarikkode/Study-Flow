import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/screens/chapter/chapter_shell.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/note_provider.dart';

class SubjectChaptersTab extends StatelessWidget {
  final String subjectId;

  const SubjectChaptersTab({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChapterProvider>(
        builder: (context, chapterProvider, child) {
          final chapters = chapterProvider.getChaptersForSubject(subjectId);

          if (chapters.isEmpty) {
            return const Center(child: Text("No chapters yet. Add one!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterShell(
                          chapter: chapter,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => _showDeleteChapterDialog(context, chapter),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Consumer<NoteProvider>(
                              builder: (context, noteProvider, child) {
                                final notesCount = noteProvider.getNotesForChapter(chapter.id).length;
                                return Text(
                                  '$notesCount note${notesCount == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            // In a full implementation, you'd calculate progress here
                            /* LinearProgressIndicator(
                              value: 0.0, // Default to 0 for now
                              backgroundColor: Colors.grey[200],
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ), */
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteChapterDialog(context, chapter),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddChapterDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddChapterDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Chapter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Chapter Title'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Provider.of<ChapterProvider>(context, listen: false).addChapter(
                    subjectId,
                    titleController.text,
                    '',
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

  void _showDeleteChapterDialog(BuildContext context, dynamic chapter) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chapter?'),
          content: Text('Are you sure you want to delete "${chapter.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Provider.of<ChapterProvider>(context, listen: false).deleteChapter(chapter.id);
                Provider.of<StudyProvider>(context, listen: false).deleteSessionsForChapter(chapter.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
