import 'package:flutter/material.dart';
import 'package:study_app/models/chapter.dart';
import 'package:study_app/screens/chapter/tabs/chapter_notes_tab.dart';
import 'package:study_app/screens/chapter/tabs/chapter_add_time_tab.dart';
import 'package:study_app/screens/chapter/tabs/chapter_performance_tab.dart';
import 'package:study_app/screens/global/tools_page.dart';

class ChapterShell extends StatelessWidget {
  final Chapter chapter;

  const ChapterShell({
    super.key,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              // We could pass the Subject name down too, or just use a placeholder
              Text(
                'Chapter Dashboard', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C63FF),
                    ),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Notes'),
              Tab(text: 'Tools'),
              Tab(text: 'Add Time'),
              Tab(text: 'Performance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChapterNotesTab(chapterId: chapter.id),
            ToolsGrid(specificSubjectId: chapter.subjectId, specificChapterId: chapter.id),
            ChapterAddTimeTab(subjectId: chapter.subjectId, chapterId: chapter.id),
            ChapterPerformanceTab(subjectId: chapter.subjectId, chapterId: chapter.id),
          ],
        ),
      ),
    );
  }
}


