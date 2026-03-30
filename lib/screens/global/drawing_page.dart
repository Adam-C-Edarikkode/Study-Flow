import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/drawing_provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/screens/global/drawing_editor_screen.dart';

class DrawingPage extends StatelessWidget {
  final String? subjectId;
  final String? chapterId;
  const DrawingPage({super.key, this.subjectId, this.chapterId});

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('New Canvas'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                 Provider.of<DrawingProvider>(ctx, listen: false)
                    .addDrawing(titleCtrl.text, subjectId, chapterId, '[]');
                 Navigator.pop(ctx);
              }
            },
            child: const Text('Create')
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String subText = '';
    if (subjectId != null) {
      try {
        final subject = Provider.of<SubjectProvider>(context, listen: false).subjects.firstWhere((s) => s.id == subjectId);
        subText = subject.name;
        if (chapterId != null) {
          final chapter = Provider.of<ChapterProvider>(context, listen: false).chapters.firstWhere((c) => c.id == chapterId);
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
            const Text('Freehand Canvas'),
            if (subText.isNotEmpty)
              Text(subText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Consumer<DrawingProvider>(
        builder: (context, provider, child) {
          final items = provider.getDrawingsForContext(subjectId, chapterId);
          if (items.isEmpty) return const Center(child: Text('No drawings yet.'));
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final d = items[index];
              return ListTile(
                leading: const Icon(Icons.brush_rounded),
                title: Text(d.title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.deleteDrawing(d.id),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DrawingEditorScreen(drawingId: d.id)));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
