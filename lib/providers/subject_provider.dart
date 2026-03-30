import 'package:flutter/foundation.dart';
import 'package:study_app/models/subject.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:uuid/uuid.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  final _uuid = const Uuid();

  List<Subject> get subjects => _subjects;

  SubjectProvider() {
    _loadSubjects();
  }

  void _loadSubjects() {
    _subjects = HiveService.subjectsBox.values.toList();
    _subjects.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    notifyListeners();
  }

  void refresh() {
    _loadSubjects();
  }

  void addSubject(String name, int colorValue) {
    final newSubject = Subject(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      createdDate: DateTime.now(),
    );

    HiveService.subjectsBox.put(newSubject.id, newSubject);
    _loadSubjects();
  }

  void updateSubject(String id, String newName, int newColorValue) {
    if (HiveService.subjectsBox.containsKey(id)) {
      final subject = HiveService.subjectsBox.get(id);
      if (subject != null) {
        subject.name = newName;
        subject.colorValue = newColorValue;
        subject.save();
        _loadSubjects();
      }
    }
  }

  void deleteSubject(String id) {
    HiveService.subjectsBox.delete(id);
    // Note: Would also need to clean up associated chapters/notes here in production
    _loadSubjects();
  }
}
