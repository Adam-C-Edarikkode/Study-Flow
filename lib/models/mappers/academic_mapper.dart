import 'package:study_app/models/academic/subject_attendance.dart';
import 'package:study_app/models/academic/attendance_record.dart';
import 'package:study_app/models/academic/class_schedule.dart';

// SubjectAttendance
extension SubjectAttendanceMapper on SubjectAttendance {
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectName': subjectName,
        'totalClasses': totalClasses,
        'attendedClasses': attendedClasses,
        'requiredPercentage': requiredPercentage,
        'createdAt': createdAt.toIso8601String(),
      };
}

extension SubjectAttendanceFromMap on Map<String, dynamic> {
  SubjectAttendance toSubjectAttendance() => SubjectAttendance(
        id: this['id'] as String?,
        subjectName: this['subjectName'] as String,
        totalClasses: this['totalClasses'] as int? ?? 0,
        attendedClasses: this['attendedClasses'] as int? ?? 0,
        requiredPercentage: (this['requiredPercentage'] as num?)?.toDouble() ?? 75.0,
        createdAt: this['createdAt'] != null
            ? DateTime.parse(this['createdAt'] as String)
            : null,
      );
}

// AttendanceRecord
extension AttendanceRecordMapper on AttendanceRecord {
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'date': date.toIso8601String(),
        'status': status,
        'note': note,
      };
}

extension AttendanceRecordFromMap on Map<String, dynamic> {
  AttendanceRecord toAttendanceRecord() => AttendanceRecord(
        id: this['id'] as String?,
        subjectId: this['subjectId'] as String,
        date: this['date'] != null ? DateTime.parse(this['date'] as String) : null,
        status: this['status'] as String,
        note: this['note'] as String?,
      );
}

// ClassSchedule
extension ClassScheduleMapper on ClassSchedule {
  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
      };
}

extension ClassScheduleFromMap on Map<String, dynamic> {
  ClassSchedule toClassSchedule() => ClassSchedule(
        id: this['id'] as String?,
        subjectId: this['subjectId'] as String,
        dayOfWeek: this['dayOfWeek'] as int,
        startTime: this['startTime'] as String,
        endTime: this['endTime'] as String,
        room: this['room'] as String?,
      );
}
