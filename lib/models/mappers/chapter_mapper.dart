import 'package:study_app/models/chapter.dart';

extension ChapterMapper on Chapter {
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'title': title,
        'description': description,
        'createdDate': createdDate.toIso8601String(),
      };
}

extension ChapterFromMap on Map<String, dynamic> {
  Chapter toChapter() => Chapter(
        id: this['id'] as String,
        subjectId: this['subjectId'] as String,
        title: this['title'] as String,
        description: this['description'] as String? ?? '',
        createdDate: DateTime.parse(this['createdDate'] as String),
      );
}
