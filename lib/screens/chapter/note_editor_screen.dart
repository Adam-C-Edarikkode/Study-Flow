import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/note_provider.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/services/pdf_export_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;
  
  const NoteEditorScreen({super.key, required this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  bool _isExporting = false;

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
              if (_isExporting)
                const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
              if (!_isExporting)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Export as PDF',
                  onPressed: () async {
                    setState(() => _isExporting = true);
                    try {
                      _titleFocus.unfocus();
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (note != null) {
                         await PdfExportService.exportNoteToPdf(note);
                      }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                    } finally {
                      if (mounted) setState(() => _isExporting = false);
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                   Provider.of<NoteProvider>(context, listen: false).deleteNote(widget.noteId);
                   Navigator.pop(context);
                },
              ),
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
                      return Dismissible(
                        key: ValueKey(block.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          Provider.of<NoteProvider>(context, listen: false)
                              .deleteBlock(widget.noteId, block.id);
                        },
                        child: _BlockEditor(block: block, noteId: widget.noteId),
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
              _toolbarBtn(Icons.title, 'H1', () => provider.addBlockToNote(widget.noteId, BlockType.heading, "")),
              _toolbarBtn(Icons.short_text, 'Text', () => provider.addBlockToNote(widget.noteId, BlockType.text, "")),
              _toolbarBtn(Icons.format_list_bulleted, 'Bullet', () => provider.addBlockToNote(widget.noteId, BlockType.bullet, "")),
              _toolbarBtn(Icons.subdirectory_arrow_right, 'Sub-bullet', () => provider.addBlockToNote(widget.noteId, BlockType.subBullet, "")),
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

class _BlockEditor extends StatefulWidget {
  final Block block;
  final String noteId;

  const _BlockEditor({required this.block, required this.noteId});

  @override
  State<_BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<_BlockEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_BlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.id != widget.block.id) {
      _controller.text = widget.block.content;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Provider.of<NoteProvider>(context, listen: false)
          .updateBlockContent(widget.noteId, widget.block.id, _controller.text);
    }
    setState(() {}); // Rebuild to toggle delete icon visibility
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);
    Widget contentWidget;

    switch (widget.block.type) {
      case BlockType.heading:
        contentWidget = TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.headlineMedium,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Heading...'),
          textInputAction: TextInputAction.done,
          onSubmitted: (val) {
            provider.updateBlockContent(widget.noteId, widget.block.id, val);
            FocusScope.of(context).unfocus();
          },
        );
        break;
      case BlockType.text:
         contentWidget = Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Text...', isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 2.0)),
          ),
         );
        break;
      case BlockType.bullet:
        contentWidget = Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 6.0, right: 8.0), child: Text("•", style: TextStyle(fontSize: 18))),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Bullet point...', isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 2.0)),
                ),
              ),
            ],
          ),
        );
        break;
      case BlockType.subBullet:
        contentWidget = Padding(
          padding: const EdgeInsets.only(left: 36.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 6.0, right: 8.0), child: Text("◦", style: TextStyle(fontSize: 18))),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Sub-bullet...', isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 2.0)),
                ),
              ),
            ],
          ),
        );
        break;
      case BlockType.checkbox:
        contentWidget = Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: widget.block.isChecked,
                onChanged: (val) {
                  provider.toggleCheckboxBlock(widget.noteId, widget.block.id);
                  setState(() => widget.block.isChecked = val ?? false);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: widget.block.isChecked ? TextDecoration.lineThrough : null,
                    color: widget.block.isChecked ? Colors.grey : null,
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Task...'),
                ),
              ),
            ],
          ),
        );
        break;
      case BlockType.link:
        contentWidget = Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            children: [
              const Icon(Icons.link, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.blue),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Link...'),
                ),
              ),
            ],
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: contentWidget),
          if (_focusNode.hasFocus || _controller.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                onPressed: () => provider.deleteBlock(widget.noteId, widget.block.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }
}
