import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/models/academic/subject_attendance.dart';
import 'package:study_app/models/academic/attendance_record.dart';
import 'package:study_app/models/academic/class_schedule.dart';

class AcademicProvider extends ChangeNotifier {
  final Box<SubjectAttendance> _subjectsBox = HiveService.academicSubjectsBox;
  final Box<AttendanceRecord> _recordsBox = HiveService.attendanceRecordsBox;
  final Box<ClassSchedule> _schedulesBox = HiveService.classSchedulesBox;

  // ── Subject CRUD ──

  List<SubjectAttendance> get subjects => _subjectsBox.values.toList();

  Future<void> addSubject(String name, double requiredPercentage) async {
    final s = SubjectAttendance(subjectName: name, requiredPercentage: requiredPercentage);
    await _subjectsBox.put(s.id, s);
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    await _subjectsBox.delete(id);
    // Delete related records & schedules
    final recordKeys = _recordsBox.values.where((r) => r.subjectId == id).map((r) => r.id).toList();
    for (var k in recordKeys) { await _recordsBox.delete(k); }
    final schedKeys = _schedulesBox.values.where((s) => s.subjectId == id).map((s) => s.id).toList();
    for (var k in schedKeys) { await _schedulesBox.delete(k); }
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _subjectsBox.clear();
    await _recordsBox.clear();
    await _schedulesBox.clear();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  // ── Attendance Marking ──

  Future<void> markAttendance(String subjectId, String status, {String? note}) async {
    final subject = _subjectsBox.get(subjectId);
    if (subject == null) return;

    subject.totalClasses++;
    if (status == 'present') subject.attendedClasses++;
    await subject.save();

    final record = AttendanceRecord(subjectId: subjectId, status: status, note: note);
    await _recordsBox.put(record.id, record);
    notifyListeners();
  }

  Future<void> deleteRecord(String recordId) async {
    final record = _recordsBox.get(recordId);
    if (record == null) return;

    final subject = _subjectsBox.get(record.subjectId);
    if (subject != null) {
      subject.totalClasses--;
      if (record.status == 'present') subject.attendedClasses--;
      await subject.save();
    }
    await _recordsBox.delete(recordId);
    notifyListeners();
  }

  List<AttendanceRecord> getRecordsForSubject(String subjectId) {
    final records = _recordsBox.values.where((r) => r.subjectId == subjectId).toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  // ── Schedule CRUD ──

  List<ClassSchedule> get schedules => _schedulesBox.values.toList();

  List<ClassSchedule> getScheduleForDay(int dayOfWeek) {
    final list = _schedulesBox.values.where((s) => s.dayOfWeek == dayOfWeek).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  List<ClassSchedule> getScheduleForSubject(String subjectId) {
    return _schedulesBox.values.where((s) => s.subjectId == subjectId).toList();
  }

  Future<void> addSchedule(String subjectId, int dayOfWeek, String startTime, String endTime, String? room) async {
    final s = ClassSchedule(subjectId: subjectId, dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime, room: room);
    await _schedulesBox.put(s.id, s);
    notifyListeners();
  }

  Future<void> deleteSchedule(String id) async {
    await _schedulesBox.delete(id);
    notifyListeners();
  }

  // ── Dashboard Stats ──

  double get overallAttendance {
    if (subjects.isEmpty) return 100.0;
    int totalAll = 0, attendedAll = 0;
    for (var s in subjects) {
      totalAll += s.totalClasses;
      attendedAll += s.attendedClasses;
    }
    return totalAll == 0 ? 100.0 : (attendedAll / totalAll) * 100;
  }

  int get subjectsAtRisk => subjects.where((s) => !s.isSafe && s.totalClasses > 0).length;

  int get missedThisMonth {
    final now = DateTime.now();
    return _recordsBox.values
        .where((r) => r.status == 'absent' && r.date.year == now.year && r.date.month == now.month)
        .length;
  }

  String? getSubjectName(String subjectId) {
    final s = _subjectsBox.get(subjectId);
    return s?.subjectName;
  }
}
