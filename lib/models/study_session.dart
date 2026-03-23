import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 5)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  DateTime date;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.durationMinutes,
    required this.date,
  });
}
