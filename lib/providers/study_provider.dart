import 'package:flutter/foundation.dart';
import 'package:study_app/models/study_session.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:uuid/uuid.dart';

class StudyProvider with ChangeNotifier {
  List<StudySession> _sessions = [];
  final _uuid = const Uuid();

  List<StudySession> get sessions => _sessions;

  StudyProvider() {
    _loadSessions();
  }

  void _loadSessions() {
    _sessions = HiveService.studyTimeBox.values.toList();
    _sessions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void addManualSession(String subjectId, int durationMinutes) {
    final newSession = StudySession(
      id: _uuid.v4(),
      subjectId: subjectId,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
    );

    HiveService.studyTimeBox.put(newSession.id, newSession);
    _loadSessions();
  }

  int getTotalStudyTimeForSubject(String subjectId) {
    return _sessions.where((s) => s.subjectId == subjectId).fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int getTotalStudyTimeAll() {
    return _sessions.fold(0, (sum, item) => sum + item.durationMinutes);
  }

  // Gets the last 7 days of study time in an ordered array (Today = index 6, Yesterday = 5, etc.)
  List<int> getWeeklyStudyData() {
    List<int> weeklyData = List.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var session in _sessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      final diff = today.difference(sessionDate).inDays;
      if (diff >= 0 && diff < 7) {
        weeklyData[6 - diff] += session.durationMinutes;
      }
    }
    
    return weeklyData;
  }
  
  Map<String, int> getSubjectDistribution() {
    Map<String, int> distribution = {};
    for (var session in _sessions) {
      if (distribution.containsKey(session.subjectId)) {
        distribution[session.subjectId] = distribution[session.subjectId]! + session.durationMinutes;
      } else {
        distribution[session.subjectId] = session.durationMinutes;
      }
    }
    return distribution;
  }
}
