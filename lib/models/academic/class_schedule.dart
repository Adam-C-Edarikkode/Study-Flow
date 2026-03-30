import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'class_schedule.g.dart';

@HiveType(typeId: 14)
class ClassSchedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final int dayOfWeek; // 1=Monday, 7=Sunday

  @HiveField(3)
  final String startTime; // e.g. '09:00'

  @HiveField(4)
  final String endTime; // e.g. '10:00'

  @HiveField(5)
  final String? room;

  ClassSchedule({
    String? id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  }) : id = id ?? const Uuid().v4();
}
