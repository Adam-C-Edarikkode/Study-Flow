import 'package:study_app/models/flashcard.dart';

extension FlashcardMapper on Flashcard {
  Map<String, dynamic> toMap() => {
        'id': id,
        'front': front,
        'back': back,
        'subjectId': subjectId,
        'chapterId': chapterId,
      };
}

extension FlashcardFromMap on Map<String, dynamic> {
  Flashcard toFlashcard() => Flashcard(
        id: this['id'] as String?,
        front: this['front'] as String,
        back: this['back'] as String,
        subjectId: this['subjectId'] as String?,
        chapterId: this['chapterId'] as String?,
      );
}
