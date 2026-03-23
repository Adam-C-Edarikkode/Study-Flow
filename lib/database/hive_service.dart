import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/models/chapter.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:study_app/models/study_session.dart';

class HiveService {
  static const String subjectsBoxName = 'subjectsBox';
  static const String chaptersBoxName = 'chaptersBox';
  static const String notesBoxName = 'notesBox';
  static const String studyTimeBoxName = 'studyTimeBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(BlockTypeAdapter());
    Hive.registerAdapter(BlockAdapter());
    Hive.registerAdapter(StudySessionAdapter());

    // Open Boxes
    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<Chapter>(chaptersBoxName);
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<StudySession>(studyTimeBoxName);
  }

  static Box<Subject> get subjectsBox => Hive.box<Subject>(subjectsBoxName);
  static Box<Chapter> get chaptersBox => Hive.box<Chapter>(chaptersBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(notesBoxName);
  static Box<StudySession> get studyTimeBox => Hive.box<StudySession>(studyTimeBoxName);
}
