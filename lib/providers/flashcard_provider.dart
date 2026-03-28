import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/models/flashcard.dart';

class FlashcardProvider extends ChangeNotifier {
  final Box<Flashcard> _flashcardsBox = HiveService.flashcardsBox;

  List<Flashcard> get flashcards => _flashcardsBox.values.toList();

  List<Flashcard> getFlashcardsForContext(String? subjectId, String? chapterId) {
    if (subjectId == 'general') {
       return _flashcardsBox.values.where((fc) => fc.subjectId == 'general').toList();
    }
    return _flashcardsBox.values.where((fc) => fc.subjectId == subjectId && fc.chapterId == chapterId).toList();
  }

  Future<void> addFlashcard(String front, String back, String? subjectId, String? chapterId) async {
    final fc = Flashcard(front: front, back: back, subjectId: subjectId, chapterId: chapterId);
    await _flashcardsBox.put(fc.id, fc);
    notifyListeners();
  }

  Future<void> deleteFlashcard(String id) async {
    await _flashcardsBox.delete(id);
    notifyListeners();
  }
}
