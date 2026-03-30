import 'package:study_app/models/study_session.dart';

extension StudySessionMapper on StudySession {
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'chapterId': chapterId,
        'durationMinutes': durationMinutes,
        'date': date.toIso8601String(),
      };
}

extension StudySessionFromMap on Map<String, dynamic> {
  StudySession toStudySession() => StudySession(
        id: this['id'] as String,
        subjectId: this['subjectId'] as String,
        chapterId: this['chapterId'] as String?,
        durationMinutes: this['durationMinutes'] as int,
        date: DateTime.parse(this['date'] as String),
      );
}
