import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/drawing_provider.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Freehand Canvas')),
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
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
