import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 13)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String status; // 'present' or 'absent'

  @HiveField(4)
  final String? note;

  AttendanceRecord({
    String? id,
    required this.subjectId,
    DateTime? date,
    required this.status,
    this.note,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();
}
