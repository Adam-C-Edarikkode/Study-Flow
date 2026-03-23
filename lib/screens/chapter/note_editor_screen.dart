import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/note_provider.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/database/hive_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;
  
  const NoteEditorScreen({super.key, required this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize title controller with current title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      final note = _getNote(provider);
      if (note != null) {
        _titleController.text = note.title;
      }
    });

    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus) {
        // Save title when focus is lost
        Provider.of<NoteProvider>(context, listen: false).updateNoteTitle(
          widget.noteId,
          _titleController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Note? _getNote(NoteProvider provider) {
    try {
      // Find note across all chapters (NoteProvider loads all notes initially)
      return provider.getNotesForChapter("").firstWhere((n) => n.id == widget.noteId, orElse: () => throw Exception());
    } catch (_) {
      // Fallback: search raw list
      // This is a bit hacky but works for this demo
      
    }
    
    // Better approach: Provider needs a getNoteById method. I will add that next.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) { // We need getNoteById
        // Workaround to find the note:
        Note? note;
        for (var rawNote in HiveService.notesBox.values) {
          if (rawNote.id == widget.noteId) note = rawNote;
        }

        if (note == null) return const Scaffold(body: Center(child: Text("Note not found")));

        // Ensure blocks are sorted by order
        final blocks = List<Block>.from(note.blocks)..sort((a, b) => a.order.compareTo(b.order));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Note'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  _titleFocus.unfocus(); // Saves title
                  FocusScope.of(context).unfocus(); // Unfocuses any active block editors
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Saved')));
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  style: Theme.of(context).textTheme.displaySmall,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Note Title',
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      // Reusable block editor tile
                      return Container(
                        key: ValueKey(block.id),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(25), // slight highlight
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildBlockWidget(context, block, noteProvider),
                      );
                    },
                  ),
                ),
                /* Expanded(
                  child: ReorderableListView.builder(
                    itemCount: blocks.length,
                    onReorder: (oldIndex, newIndex) {
                      noteProvider.reorderBlocks(widget.noteId, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      // Reusable block editor tile
                      return Container(
                        key: ValueKey(block.id),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(25), // slight highlight
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildBlockWidget(context, block, noteProvider),
                      );
                    },
                  ),
                ), */
              ],
            ),
          ),
          bottomNavigationBar: _buildBlockToolbar(context, noteProvider),
        );
      },
    );
  }

  Widget _buildBlockWidget(BuildContext context, Block block, NoteProvider provider) {
    final TextEditingController textController = TextEditingController(text: block.content);
    
    Widget contentWidget;

    switch (block.type) {
      case BlockType.heading:
        contentWidget = TextField(
          controller: textController,
          style: Theme.of(context).textTheme.headlineMedium,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Heading...'),
          onSubmitted: (val) => provider.updateBlockContent(widget.noteId, block.id, val),
        );
        break;
      case BlockType.text:
         contentWidget = TextField(
          controller: textController,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: null,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Text...'),
          onSubmitted: (val) => provider.updateBlockContent(widget.noteId, block.id, val),
        );
        break;
      case BlockType.bullet:
        contentWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 8.0, right: 8.0), child: Text("•", style: TextStyle(fontSize: 18))),
            Expanded(
              child: TextField(
                controller: textController,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: null,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Bullet point...'),
                onSubmitted: (val) => provider.updateBlockContent(widget.noteId, block.id, val),
              ),
            ),
          ],
        );
        break;
      case BlockType.checkbox:
        contentWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: block.isChecked,
              onChanged: (val) => provider.toggleCheckboxBlock(widget.noteId, block.id),
            ),
            Expanded(
              child: TextField(
                controller: textController,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: block.isChecked ? TextDecoration.lineThrough : null,
                  color: block.isChecked ? Colors.grey : null,
                ),
                maxLines: null,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Task...'),
                onSubmitted: (val) => provider.updateBlockContent(widget.noteId, block.id, val),
              ),
            ),
          ],
        );
        break;
      case BlockType.link:
        contentWidget = Row(
          children: [
            const Icon(Icons.link, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: textController,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Link...'),
                onSubmitted: (val) => provider.updateBlockContent(widget.noteId, block.id, val),
              ),
            ),
          ],
        );
        break;
    }

    // Need a manual save button for textfields or rely on focus nodes per block (complex).
    // For simplicity, we add a save icon to each block.
    /* return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0, right: 8.0),
          child: Icon(Icons.drag_indicator, color: Colors.grey),
        ),
        Expanded(child: contentWidget),
        IconButton(
          icon: const Icon(Icons.save_outlined, size: 20, color: Colors.grey),
          onPressed: () {
            provider.updateBlockContent(widget.noteId, block.id, textController.text);
            FocusScope.of(context).unfocus();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          onPressed: () => provider.deleteBlock(widget.noteId, block.id),
        ),
      ],
    ); */

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0, right: 8.0),
        ),
        Expanded(child: contentWidget),
      ],
    );
  }

  Widget _buildBlockToolbar(BuildContext context, NoteProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolbarBtn(Icons.title, 'H1', () => provider.addBlockToNote(widget.noteId, BlockType.heading, "New Heading")),
              _toolbarBtn(Icons.short_text, 'Text', () => provider.addBlockToNote(widget.noteId, BlockType.text, "")),
              _toolbarBtn(Icons.format_list_bulleted, 'Bullet', () => provider.addBlockToNote(widget.noteId, BlockType.bullet, "")),
              _toolbarBtn(Icons.check_box_outlined, 'Task', () => provider.addBlockToNote(widget.noteId, BlockType.checkbox, "")),
              _toolbarBtn(Icons.link, 'Link', () => provider.addBlockToNote(widget.noteId, BlockType.link, "")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
