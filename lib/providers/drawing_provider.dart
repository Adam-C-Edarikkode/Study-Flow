import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/models/drawing.dart';

class DrawingProvider extends ChangeNotifier {
  final Box<Drawing> _drawingsBox = HiveService.drawingsBox;

  List<Drawing> get drawings => _drawingsBox.values.toList();

  List<Drawing> getDrawingsForContext(String? subjectId, String? chapterId) {
    if (subjectId == 'general') {
       return _drawingsBox.values.where((d) => d.subjectId == 'general').toList();
    }
    return _drawingsBox.values.where((d) => d.subjectId == subjectId && d.chapterId == chapterId).toList();
  }

  Future<void> addDrawing(String title, String? subjectId, String? chapterId, String encodedPaths) async {
    final d = Drawing(title: title, subjectId: subjectId, chapterId: chapterId, encodedPaths: encodedPaths);
    await _drawingsBox.put(d.id, d);
    notifyListeners();
  }

  Future<void> updateDrawing(String id, String encodedPaths) async {
    final d = _drawingsBox.get(id);
    if (d != null) {
      d.encodedPaths = encodedPaths;
      await d.save();
      notifyListeners();
    }
  }

  Future<void> deleteDrawing(String id) async {
    await _drawingsBox.delete(id);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
