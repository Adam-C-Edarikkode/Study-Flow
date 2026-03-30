import 'package:study_app/models/drawing.dart';

extension DrawingMapper on Drawing {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'encodedPaths': encodedPaths,
    };
  }
}

extension DrawingFromMap on Map<String, dynamic> {
  Drawing toDrawing() {
    return Drawing(
      id: this['id'],
      title: this['title'],
      subjectId: this['subjectId'],
      chapterId: this['chapterId'],
      encodedPaths: this['encodedPaths'] ?? '[]',
    );
  }
}
