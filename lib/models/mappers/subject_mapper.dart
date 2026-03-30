import 'package:study_app/models/subject.dart';

extension SubjectMapper on Subject {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdDate': createdDate.toIso8601String(),
      };
}

extension SubjectFromMap on Map<String, dynamic> {
  Subject toSubject() => Subject(
        id: this['id'] as String,
        name: this['name'] as String,
        colorValue: this['colorValue'] as int,
        createdDate: DateTime.parse(this['createdDate'] as String),
      );
}
