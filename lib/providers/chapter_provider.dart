import 'package:flutter/foundation.dart';
import 'package:study_app/models/chapter.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:uuid/uuid.dart';

class ChapterProvider with ChangeNotifier {
  List<Chapter> _allChapters = [];
  final _uuid = const Uuid();

  ChapterProvider() {
    _loadAllChapters();
  }

  List<Chapter> get chapters => _allChapters;

  void _loadAllChapters() {
    _allChapters = HiveService.chaptersBox.values.toList();
    _allChapters.sort((a, b) => a.createdDate.compareTo(b.createdDate));
    notifyListeners();
  }

  List<Chapter> getChaptersForSubject(String subjectId) {
    return _allChapters.where((c) => c.subjectId == subjectId).toList();
  }

  void addChapter(String subjectId, String title, String description) {
    final newChapter = Chapter(
      id: _uuid.v4(),
      subjectId: subjectId,
      title: title,
      description: description,
      createdDate: DateTime.now(),
    );

    HiveService.chaptersBox.put(newChapter.id, newChapter);
    _loadAllChapters();
  }

  void updateChapter(String id, String title, String description) {
    final chapter = HiveService.chaptersBox.get(id);
    if (chapter != null) {
      chapter.title = title;
      chapter.description = description;
      chapter.save();
      _loadAllChapters();
    }
  }

  void deleteChapter(String id) {
    HiveService.chaptersBox.delete(id);
    _loadAllChapters();
  }

  void deleteChaptersForSubject(String subjectId) {
    final keysToDelete = HiveService.chaptersBox.values
        .where((c) => c.subjectId == subjectId)
        .map((c) => c.id)
        .toList();
    for (var key in keysToDelete) {
      HiveService.chaptersBox.delete(key);
    }
    _loadAllChapters();
  }
}
