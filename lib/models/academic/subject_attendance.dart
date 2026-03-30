import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'subject_attendance.g.dart';

@HiveType(typeId: 12)
class SubjectAttendance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String subjectName;

  @HiveField(2)
  int totalClasses;

  @HiveField(3)
  int attendedClasses;

  @HiveField(4)
  double requiredPercentage;

  @HiveField(5)
  final DateTime createdAt;

  SubjectAttendance({
    String? id,
    required this.subjectName,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.requiredPercentage = 75.0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get missedClasses => totalClasses - attendedClasses;

  double get attendancePercentage =>
      totalClasses == 0 ? 100.0 : (attendedClasses / totalClasses) * 100;

  bool get isSafe => attendancePercentage >= requiredPercentage;

  /// How many more classes can be missed while staying at or above requiredPercentage.
  /// Formula: attended / (total + x) >= req/100  =>  x <= (attended*100/req) - total
  int get classesCanMiss {
    if (totalClasses == 0) return 0;
    final maxTotal = (attendedClasses * 100 / requiredPercentage).floor();
    final canMiss = maxTotal - totalClasses;
    return canMiss < 0 ? 0 : canMiss;
  }
}
