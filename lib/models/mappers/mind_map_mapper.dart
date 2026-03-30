import 'package:study_app/models/mind_map.dart';

extension MindMapMapper on MindMap {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'nodes': nodes.map((n) => n.toMap()).toList(),
    };
  }
}

extension MindMapNodeMapper on MindMapNode {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'x': x,
      'y': y,
      'parentId': parentId,
    };
  }
}

extension MindMapFromMap on Map<String, dynamic> {
  MindMap toMindMap() {
    return MindMap(
      id: this['id'],
      title: this['title'],
      subjectId: this['subjectId'],
      chapterId: this['chapterId'],
      nodes: (this['nodes'] as List<dynamic>?)
          ?.map((n) => (n as Map<String, dynamic>).toMindMapNode())
          .toList(),
    );
  }

  MindMapNode toMindMapNode() {
    return MindMapNode(
      id: this['id'],
      text: this['text'],
      x: (this['x'] as num).toDouble(),
      y: (this['y'] as num).toDouble(),
      parentId: this['parentId'],
    );
  }
}
