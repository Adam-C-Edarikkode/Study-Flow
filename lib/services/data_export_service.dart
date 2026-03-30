import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

class DataExportService {
  static const int exportVersion = 1;

  /// Build a JSON-serializable map of all app data.
  static Map<String, dynamic> buildExportMap() {
    return {
      'version': exportVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'subjects':
          HiveService.subjectsBox.values.map((s) => s.toMap()).toList(),
      'chapters':
          HiveService.chaptersBox.values.map((c) => c.toMap()).toList(),
      'notes': HiveService.notesBox.values.map((n) => n.toMap()).toList(),
      'studySessions':
          HiveService.studyTimeBox.values.map((s) => s.toMap()).toList(),
      'flashcards':
          HiveService.flashcardsBox.values.map((f) => f.toMap()).toList(),
      'todos': HiveService.todosBox.values.map((t) => t.toMap()).toList(),
      'academicSubjects':
          HiveService.academicSubjectsBox.values.map((a) => a.toMap()).toList(),
      'attendanceRecords': HiveService.attendanceRecordsBox.values
          .map((r) => r.toMap())
          .toList(),
      'classSchedules':
          HiveService.classSchedulesBox.values.map((s) => s.toMap()).toList(),
      'timestamps':
          HiveService.timestampsBox.values.map((t) => t.toMap()).toList(),
      'mindMaps':
          HiveService.mindMapsBox.values.map((m) => m.toMap()).toList(),
      'drawings':
          HiveService.drawingsBox.values.map((d) => d.toMap()).toList(),
      'settings': HiveService.settingsBox.toMap(),
    };
  }

  /// Encode the export map as a JSON string.
  static String exportToJsonString() {
    return const JsonEncoder.withIndent('  ').convert(buildExportMap());
  }

  /// Copy the JSON string to the system clipboard.
  static Future<void> exportToClipboard() async {
    final json = exportToJsonString();
    await Clipboard.setData(ClipboardData(text: json));
  }

  /// Write JSON to a temp file and open the system share sheet.
  static Future<void> exportToFile() async {
    final json = exportToJsonString();
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName =
        'studyflow_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Study Flow Backup',
    );
  }
}
