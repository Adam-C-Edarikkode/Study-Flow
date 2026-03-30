import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/models/chapter.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/models/study_session.dart';
import 'package:study_app/models/todo.dart';
import 'package:study_app/models/todo_subtask.dart';
import 'package:study_app/models/flashcard.dart';
import 'package:study_app/models/mind_map.dart';
import 'package:study_app/models/drawing.dart';
import 'package:study_app/models/academic/subject_attendance.dart';
import 'package:study_app/models/academic/attendance_record.dart';
import 'package:study_app/models/academic/class_schedule.dart';
import 'package:study_app/models/timestamp.dart';

class HiveService {
  static const String subjectsBoxName = 'subjectsBox';
  static const String chaptersBoxName = 'chaptersBox';
  static const String notesBoxName = 'notesBox';
  static const String studyTimeBoxName = 'studyTimeBox';
  static const String settingsBoxName = 'settingsBox';
  static const String todosBoxName = 'todosBox';
  static const String flashcardsBoxName = 'flashcardsBox';
  static const String mindMapsBoxName = 'mindMapsBox';
  static const String drawingsBoxName = 'drawingsBox';
  static const String academicSubjectsBoxName = 'academicSubjectsBox';
  static const String attendanceRecordsBoxName = 'attendanceRecordsBox';
  static const String classSchedulesBoxName = 'classSchedulesBox';
  static const String timestampsBoxName = 'timestampsBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(BlockTypeAdapter());
    Hive.registerAdapter(BlockAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(TodoSubTaskAdapter());
    Hive.registerAdapter(FlashcardAdapter());
    Hive.registerAdapter(MindMapNodeAdapter());
    Hive.registerAdapter(MindMapAdapter());
    Hive.registerAdapter(DrawingAdapter());
    Hive.registerAdapter(SubjectAttendanceAdapter());
    Hive.registerAdapter(AttendanceRecordAdapter());
    Hive.registerAdapter(ClassScheduleAdapter());
    Hive.registerAdapter(TimestampAdapter());

    // Open Boxes
    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<Chapter>(chaptersBoxName);
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<StudySession>(studyTimeBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<Todo>(todosBoxName);
    await Hive.openBox<Flashcard>(flashcardsBoxName);
    await Hive.openBox<MindMap>(mindMapsBoxName);
    await Hive.openBox<Drawing>(drawingsBoxName);
    await Hive.openBox<SubjectAttendance>(academicSubjectsBoxName);
    await Hive.openBox<AttendanceRecord>(attendanceRecordsBoxName);
    await Hive.openBox<ClassSchedule>(classSchedulesBoxName);
    await Hive.openBox<Timestamp>(timestampsBoxName);
  }

  static Box<Subject> get subjectsBox => Hive.box<Subject>(subjectsBoxName);
  static Box<Chapter> get chaptersBox => Hive.box<Chapter>(chaptersBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(notesBoxName);
  static Box<StudySession> get studyTimeBox => Hive.box<StudySession>(studyTimeBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<Todo> get todosBox => Hive.box<Todo>(todosBoxName);
  static Box<Flashcard> get flashcardsBox => Hive.box<Flashcard>(flashcardsBoxName);
  static Box<MindMap> get mindMapsBox => Hive.box<MindMap>(mindMapsBoxName);
  static Box<Drawing> get drawingsBox => Hive.box<Drawing>(drawingsBoxName);
  static Box<SubjectAttendance> get academicSubjectsBox => Hive.box<SubjectAttendance>(academicSubjectsBoxName);
  static Box<AttendanceRecord> get attendanceRecordsBox => Hive.box<AttendanceRecord>(attendanceRecordsBoxName);
  static Box<ClassSchedule> get classSchedulesBox => Hive.box<ClassSchedule>(classSchedulesBoxName);
  static Box<Timestamp> get timestampsBox => Hive.box<Timestamp>(timestampsBoxName);
}
