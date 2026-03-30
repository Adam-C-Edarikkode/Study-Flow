import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/models/mappers/block_mapper.dart';

extension NoteMapper on Note {
  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'title': title,
        'createdDate': createdDate.toIso8601String(),
        'lastEdited': lastEdited.toIso8601String(),
        'blocks': blocks.map((b) => b.toMap()).toList(),
      };
}

extension NoteFromMap on Map<String, dynamic> {
  Note toNote() {
    final rawBlocks = (this['blocks'] as List<dynamic>?) ?? [];
    final blocks = rawBlocks
        .map((b) => (b as Map<String, dynamic>).toBlock())
        .toList();
    return Note(
      id: this['id'] as String,
      chapterId: this['chapterId'] as String,
      title: this['title'] as String,
      blocks: blocks,
      createdDate: DateTime.parse(this['createdDate'] as String),
      lastEdited: DateTime.parse(this['lastEdited'] as String),
    );
  }
}
