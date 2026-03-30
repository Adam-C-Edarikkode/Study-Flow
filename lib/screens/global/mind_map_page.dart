import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/mind_map_provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/screens/global/mind_map_editor_screen.dart';

class MindMapPage extends StatelessWidget {
  final String? subjectId;
  final String? chapterId;
  const MindMapPage({super.key, this.subjectId, this.chapterId});

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('New Mind Map'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                 Provider.of<MindMapProvider>(ctx, listen: false)
                    .addMindMap(titleCtrl.text, subjectId, chapterId);
                 Navigator.pop(ctx);
              }
            },
            child: const Text('Add')
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
            const Text('Mind Maps'),
            if (subText.isNotEmpty)
              Text(subText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Consumer<MindMapProvider>(
        builder: (context, provider, child) {
          final maps = provider.getMindMapsForContext(subjectId, chapterId);
          if (maps.isEmpty) return const Center(child: Text('No mind maps yet.'));
          
          return ListView.builder(
            itemCount: maps.length,
            itemBuilder: (context, index) {
              final mm = maps[index];
              return ListTile(
                leading: const Icon(Icons.account_tree_rounded),
                title: Text(mm.title),
                subtitle: Text('${mm.nodes.length} nodes'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.deleteMindMap(mm.id),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MindMapEditorScreen(mindMapId: mm.id)));
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
