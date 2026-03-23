import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/screens/subject/tabs/subject_chapters_tab.dart';
// Note: We'll create placeholders for these below or in separate files.

class SubjectShell extends StatelessWidget {
  final Subject subject;

  const SubjectShell({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(subject.colorValue).withAlpha(25), // ~10% opacity
          elevation: 0,
          iconTheme: Theme.of(context).iconTheme.copyWith(color: AppTheme.primaryColor), // Override icon color back to normal
          title: Text(subject.name, style: Theme.of(context).textTheme.headlineMedium),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Chapters'),
              Tab(text: 'Notes'),
              Tab(text: 'Tools'),
              Tab(text: 'Add Time'),
              Tab(text: 'Performance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SubjectChaptersTab(subjectId: subject.id),
            Center(child: Text('Subject General Notes')), // Placeholder
            Center(child: Text('Subject Wide Tools')),    // Placeholder
            Center(child: Text('Add Time to Subject')),     // Placeholder
            Center(child: Text('Subject Performance')),     // Placeholder
          ],
        ),
      ),
    );
  }
}
