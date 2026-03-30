import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:study_app/models/study_session.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:uuid/uuid.dart';

enum TimeRange { today, yesterday, last7Days, last30Days }

class StudyProvider with ChangeNotifier {
  List<StudySession> _sessions = [];
  final _uuid = const Uuid();

  Timer? _activeTimer;
  int _activeSeconds = 0;
  String? _activeSubjectId;
  String? _activeChapterId;

  List<StudySession> get sessions => _sessions;

  bool get isTimerRunning => _activeTimer != null && _activeTimer!.isActive;
  int get activeSeconds => _activeSeconds;
  String? get activeSubjectId => _activeSubjectId;
  String? get activeChapterId => _activeChapterId;

  StudyProvider() {
    _loadSessions();
  }

  void startActiveTimer(String subjectId, {String? chapterId}) {
    if (isTimerRunning) return;
    _activeSubjectId = subjectId;
    _activeChapterId = chapterId;
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _activeSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void stopActiveTimer() {
    if (!isTimerRunning) return;
    _activeTimer?.cancel();
    _activeTimer = null;
    
    final mins = _activeSeconds ~/ 60;
    if (mins > 0 && _activeSubjectId != null) {
      addManualSession(_activeSubjectId!, mins, chapterId: _activeChapterId);
    }
    _activeSeconds = 0;
    _activeSubjectId = null;
    _activeChapterId = null;
    notifyListeners();
  }

  void cancelActiveTimer() {
     _activeTimer?.cancel();
     _activeTimer = null;
     _activeSeconds = 0;
     _activeSubjectId = null;
     _activeChapterId = null;
     notifyListeners();
  }

  void _loadSessions() {
    _sessions = HiveService.studyTimeBox.values.toList();
    _sessions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void refresh() {
    _loadSessions();
  }

  void addManualSession(String subjectId, int durationMinutes, {String? chapterId}) {
    final newSession = StudySession(
      id: _uuid.v4(),
      subjectId: subjectId,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
      chapterId: chapterId,
    );

    HiveService.studyTimeBox.put(newSession.id, newSession);
    _loadSessions();
  }

  void deleteSession(String sessionId) {
    HiveService.studyTimeBox.delete(sessionId);
    _loadSessions();
  }

  void deleteSessionsForChapter(String chapterId) {
    final sessionKeysToDelete = HiveService.studyTimeBox.values
        .where((s) => s.chapterId == chapterId)
        .map((s) => s.id)
        .toList();
        
    for (var key in sessionKeysToDelete) {
      HiveService.studyTimeBox.delete(key);
    }
    _loadSessions();
  }

  void deleteSessionsForSubject(String subjectId) {
    final sessionKeysToDelete = HiveService.studyTimeBox.values
        .where((s) => s.subjectId == subjectId)
        .map((s) => s.id)
        .toList();
        
    for (var key in sessionKeysToDelete) {
      HiveService.studyTimeBox.delete(key);
    }
    _loadSessions();
  }

  List<StudySession> getSessionsForSubject(String subjectId) {
    return _sessions.where((s) => s.subjectId == subjectId).toList();
  }

  int getTotalStudyTimeForSubject(String subjectId) {
    return _sessions.where((s) => s.subjectId == subjectId).fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int getTotalStudyTimeAll() {
    return _sessions.fold(0, (sum, item) => sum + item.durationMinutes);
  }

  List<StudySession> _getSessionsForRange(TimeRange range, {String? subjectId, String? chapterId}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _sessions.where((s) {
      if (subjectId != null && s.subjectId != subjectId) return false;
      if (chapterId != null && s.chapterId != chapterId) return false;
      
      final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
      final diff = today.difference(sessionDate).inDays;
      
      switch (range) {
        case TimeRange.today:
          return diff == 0;
        case TimeRange.yesterday:
          return diff == 1;
        case TimeRange.last7Days:
          return diff >= 0 && diff < 7;
        case TimeRange.last30Days:
          return diff >= 0 && diff < 30;
      }
    }).toList();
  }

  // Gets chart data for the selected range.
  List<int> getChartData(TimeRange range, {String? subjectId, String? chapterId}) {
    final sessionsInRange = _getSessionsForRange(range, subjectId: subjectId, chapterId: chapterId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (range == TimeRange.today || range == TimeRange.yesterday) {
      // 24 hours
      List<int> hourlyData = List.filled(24, 0);
      for (var s in sessionsInRange) {
        hourlyData[s.date.hour] += s.durationMinutes;
      }
      return hourlyData;
    } else if (range == TimeRange.last7Days) {
      List<int> weeklyData = List.filled(7, 0);
      for (var s in sessionsInRange) {
        final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
        final diff = today.difference(sessionDate).inDays;
        weeklyData[6 - diff] += s.durationMinutes;
      }
      return weeklyData;
    } else {
      // 30 days
      List<int> monthlyData = List.filled(30, 0);
      for (var s in sessionsInRange) {
        final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
        final diff = today.difference(sessionDate).inDays;
        monthlyData[29 - diff] += s.durationMinutes;
      }
      return monthlyData;
    }
  }
  
  Map<String, int> getSubjectDistribution(TimeRange range) {
    Map<String, int> distribution = {};
    final sessionsInRange = _getSessionsForRange(range);
    
    for (var session in sessionsInRange) {
      if (distribution.containsKey(session.subjectId)) {
        distribution[session.subjectId] = distribution[session.subjectId]! + session.durationMinutes;
      } else {
        distribution[session.subjectId] = session.durationMinutes;
      }
    }
    return distribution;
  }
}
