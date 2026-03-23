import 'package:flutter/foundation.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:uuid/uuid.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _allNotes = [];
  final _uuid = const Uuid();

  NoteProvider() {
    _loadAllNotes();
  }

  void _loadAllNotes() {
    _allNotes = HiveService.notesBox.values.toList();
    _allNotes.sort((a, b) => b.lastEdited.compareTo(a.lastEdited)); // Newest edited first
    notifyListeners();
  }

  List<Note> getNotesForChapter(String chapterId) {
    return _allNotes.where((n) => n.chapterId == chapterId).toList();
  }

  void addNote(String chapterId, String title) {
    final newNote = Note(
      id: _uuid.v4(),
      chapterId: chapterId,
      title: title,
      blocks: [], // Empty block list to start
      createdDate: DateTime.now(),
      lastEdited: DateTime.now(),
    );

    HiveService.notesBox.put(newNote.id, newNote);
    _loadAllNotes();
  }

  void updateNoteTitle(String noteId, String newTitle) {
    final note = HiveService.notesBox.get(noteId);
    if (note != null) {
      note.title = newTitle;
      note.lastEdited = DateTime.now();
      note.save();
      _loadAllNotes();
    }
  }

  void deleteNote(String noteId) {
    HiveService.notesBox.delete(noteId);
    _loadAllNotes();
  }

  // --- Block Management --- //

  void addBlockToNote(String noteId, BlockType type, String content) {
    final note = HiveService.notesBox.get(noteId);
    if (note != null) {
      final newBlock = Block(
        id: _uuid.v4(),
        type: type,
        content: content,
        order: note.blocks.length, // Append to end
      );
      note.blocks.add(newBlock);
      note.lastEdited = DateTime.now();
      note.save();
      _loadAllNotes();
    }
  }

  void updateBlockContent(String noteId, String blockId, String newContent) {
    final note = HiveService.notesBox.get(noteId);
    if (note != null) {
      final blockIndex = note.blocks.indexWhere((b) => b.id == blockId);
      if (blockIndex != -1) {
        note.blocks[blockIndex].content = newContent;
        note.lastEdited = DateTime.now();
        note.save();
        _loadAllNotes();
      }
    }
  }

  void toggleCheckboxBlock(String noteId, String blockId) {
    final note = HiveService.notesBox.get(noteId);
    if (note != null) {
      final blockIndex = note.blocks.indexWhere((b) => b.id == blockId);
      if (blockIndex != -1 && note.blocks[blockIndex].type == BlockType.checkbox) {
        note.blocks[blockIndex].isChecked = !note.blocks[blockIndex].isChecked;
        note.lastEdited = DateTime.now();
        note.save();
        _loadAllNotes();
      }
    }
  }

  void deleteBlock(String noteId, String blockId) {
    final note = HiveService.notesBox.get(noteId);
    if (note != null) {
      note.blocks.removeWhere((b) => b.id == blockId);
      // Re-index orders
      for (int i = 0; i < note.blocks.length; i++) {
        note.blocks[i].order = i;
      }
      note.lastEdited = DateTime.now();
      note.save();
      _loadAllNotes();
    }
  }

  void reorderBlocks(String noteId, int oldIndex, int newIndex) {
    final note = HiveService.notesBox.get(noteId);
    if (note == null) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final item = note.blocks.removeAt(oldIndex);
    note.blocks.insert(newIndex, item);
    
    // Re-index
    for (int i = 0; i < note.blocks.length; i++) {
      note.blocks[i].order = i;
    }

    note.lastEdited = DateTime.now();
    note.save();
    _loadAllNotes();
  }
}
