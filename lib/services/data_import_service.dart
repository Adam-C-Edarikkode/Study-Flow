import 'dart:convert';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/models/mappers/subject_mapper.dart';
import 'package:study_app/models/mappers/chapter_mapper.dart';
import 'package:study_app/models/mappers/note_mapper.dart';
import 'package:study_app/models/mappers/study_session_mapper.dart';
import 'package:study_app/models/mappers/flashcard_mapper.dart';
import 'package:study_app/models/mappers/todo_mapper.dart';
import 'package:study_app/models/mappers/academic_mapper.dart';
import 'package:study_app/models/mappers/timestamp_mapper.dart';
import 'package:study_app/models/mappers/mind_map_mapper.dart';
import 'package:study_app/models/mappers/drawing_mapper.dart';

class ImportResult {
  final bool success;
  final String message;
  final Map<String, int> counts;

  const ImportResult({
    required this.success,
    required this.message,
    this.counts = const {},
  });
}

class DataImportService {
  static const int supportedVersion = 1;

  /// Parse and import data from a JSON string.
  ///
  /// If [clearFirst] is true, all existing Hive data is removed before import.
  static Future<ImportResult> importFromJsonString(
    String jsonString, {
    bool clearFirst = true,
  }) async {
    // ── Parse ──────────────────────────────────────────────────────────────
    Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return const ImportResult(
          success: false, message: 'Invalid JSON — please check your input.');
    }

    // ── Validate version ───────────────────────────────────────────────────
    final version = data['version'];
    if (version == null) {
      return const ImportResult(
          success: false, message: 'Missing "version" field in backup file.');
    }
    if (version is! int || version > supportedVersion) {
      return ImportResult(
          success: false,
          message:
              'Unsupported backup version "$version". This app supports version $supportedVersion.');
    }

    // ── Validate required keys ─────────────────────────────────────────────
    for (final key in ['subjects', 'chapters', 'notes']) {
      if (data[key] == null) {
        return ImportResult(
            success: false,
            message: 'Backup is missing required section "$key".');
      }
    }

    // ── Clear existing data ────────────────────────────────────────────────
    if (clearFirst) {
      await HiveService.subjectsBox.clear();
      await HiveService.chaptersBox.clear();
      await HiveService.notesBox.clear();
      await HiveService.studyTimeBox.clear();
      await HiveService.flashcardsBox.clear();
      await HiveService.todosBox.clear();
      await HiveService.academicSubjectsBox.clear();
      await HiveService.attendanceRecordsBox.clear();
      await HiveService.classSchedulesBox.clear();
      await HiveService.timestampsBox.clear();
      await HiveService.mindMapsBox.clear();
      await HiveService.drawingsBox.clear();
    }

    // ── Helper to safely cast list ─────────────────────────────────────────
    List<Map<String, dynamic>> asList(String key) {
      final raw = data[key];
      if (raw == null) return [];
      return (raw as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    final counts = <String, int>{};

    // ── Import in dependency order ─────────────────────────────────────────
    try {
      // Subjects
      final subjects = asList('subjects');
      for (final m in subjects) {
        final s = m.toSubject();
        await HiveService.subjectsBox.put(s.id, s);
      }
      counts['subjects'] = subjects.length;

      // Chapters
      final chapters = asList('chapters');
      for (final m in chapters) {
        final c = m.toChapter();
        await HiveService.chaptersBox.put(c.id, c);
      }
      counts['chapters'] = chapters.length;

      // Notes (includes blocks)
      final notes = asList('notes');
      for (final m in notes) {
        final n = m.toNote();
        await HiveService.notesBox.put(n.id, n);
      }
      counts['notes'] = notes.length;

      // Study Sessions
      final sessions = asList('studySessions');
      for (final m in sessions) {
        final s = m.toStudySession();
        await HiveService.studyTimeBox.put(s.id, s);
      }
      counts['studySessions'] = sessions.length;

      // Flashcards
      final flashcards = asList('flashcards');
      for (final m in flashcards) {
        final f = m.toFlashcard();
        await HiveService.flashcardsBox.put(f.id, f);
      }
      counts['flashcards'] = flashcards.length;

      // Todos (includes sub-tasks)
      final todos = asList('todos');
      for (final m in todos) {
        final t = m.toTodo();
        await HiveService.todosBox.put(t.id, t);
      }
      counts['todos'] = todos.length;

      // Academic Subjects
      final academicSubjects = asList('academicSubjects');
      for (final m in academicSubjects) {
        final a = m.toSubjectAttendance();
        await HiveService.academicSubjectsBox.put(a.id, a);
      }
      counts['academicSubjects'] = academicSubjects.length;

      // Attendance Records
      final records = asList('attendanceRecords');
      for (final m in records) {
        final r = m.toAttendanceRecord();
        await HiveService.attendanceRecordsBox.put(r.id, r);
      }
      counts['attendanceRecords'] = records.length;

      // Class Schedules
      final schedules = asList('classSchedules');
      for (final m in schedules) {
        final s = m.toClassSchedule();
        await HiveService.classSchedulesBox.put(s.id, s);
      }
      counts['classSchedules'] = schedules.length;

      // Timestamps
      final timestamps = asList('timestamps');
      for (final m in timestamps) {
        final t = m.toTimestamp();
        await HiveService.timestampsBox.put(t.id, t);
      }
      counts['timestamps'] = timestamps.length;

      // Mind Maps
      final mindMaps = asList('mindMaps');
      for (final m in mindMaps) {
        final mm = m.toMindMap();
        await HiveService.mindMapsBox.put(mm.id, mm);
      }
      counts['mindMaps'] = mindMaps.length;

      // Drawings
      final drawings = asList('drawings');
      for (final m in drawings) {
        final d = m.toDrawing();
        await HiveService.drawingsBox.put(d.id, d);
      }
      counts['drawings'] = drawings.length;

      // Settings
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        await HiveService.settingsBox.clear();
        await HiveService.settingsBox.putAll(settings);
      }
    } catch (e) {
      return ImportResult(
          success: false,
          message: 'Import failed while restoring data: $e');
    }

    final total = counts.values.fold(0, (a, b) => a + b);
    return ImportResult(
      success: true,
      message: 'Successfully imported $total items.',
      counts: counts,
    );
  }
}
