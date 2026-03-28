import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/drawing_provider.dart';
import 'package:study_app/models/drawing.dart';

class DrawingPath {
  final List<Offset> points;
  DrawingPath(this.points);
}

class DrawingEditorScreen extends StatefulWidget {
  final String drawingId;
  const DrawingEditorScreen({super.key, required this.drawingId});

  @override
  State<DrawingEditorScreen> createState() => _DrawingEditorScreenState();
}

class _DrawingEditorScreenState extends State<DrawingEditorScreen> {
  List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final provider = Provider.of<DrawingProvider>(context, listen: false);
       final drawing = provider.drawings.firstWhere((d) => d.id == widget.drawingId);
       _decodePaths(drawing.encodedPaths);
    });
  }

  void _decodePaths(String jsonStr) {
    try {
      final List<dynamic> rawList = jsonDecode(jsonStr);
      List<DrawingPath> parsed = [];
      for (var pathObj in rawList) {
        if (pathObj is List) {
          List<Offset> pts = [];
          for (var ptObj in pathObj) {
            pts.add(Offset((ptObj[0] as num).toDouble(), (ptObj[1] as num).toDouble()));
          }
          parsed.add(DrawingPath(pts));
        }
      }
      setState(() {
        _paths = parsed;
      });
    } catch (e) {
      _paths = [];
    }
  }

  void _saveDrawing() {
    final provider = Provider.of<DrawingProvider>(context, listen: false);
    List<dynamic> jsonList = [];
    for (var path in _paths) {
       jsonList.add(path.points.map((p) => [p.dx, p.dy]).toList());
    }
    provider.updateDrawing(widget.drawingId, jsonEncode(jsonList));
  }

  void _clearCanvas() {
    setState(() {
      _paths.clear();
      _currentPath = null;
    });
    _saveDrawing();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        final drawing = provider.drawings.cast<Drawing?>().firstWhere((d) => d?.id == widget.drawingId, orElse: () => null);
        if (drawing == null) return const Scaffold(body: Center(child: Text('Drawing not found')));

        return Scaffold(
          appBar: AppBar(
            title: Text(drawing.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear Canvas',
                onPressed: _clearCanvas,
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () {
                   if (_paths.isNotEmpty) {
                      setState(() {
                         _paths.removeLast();
                      });
                      _saveDrawing();
                   }
                },
              ),
            ],
          ),
          body: GestureDetector(
            onPanStart: (details) {
               setState(() {
                 _currentPath = DrawingPath([details.localPosition]);
                 _paths.add(_currentPath!);
               });
            },
            onPanUpdate: (details) {
               setState(() {
                 _currentPath?.points.add(details.localPosition);
               });
            },
            onPanEnd: (details) {
               _saveDrawing();
               _currentPath = null;
            },
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: _FreehandPainter(_paths, Theme.of(context).primaryColor),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FreehandPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final Color paintColor;

  _FreehandPainter(this.paths, this.paintColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = paintColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var pathConfig in paths) {
      if (pathConfig.points.isEmpty) continue;
      
      final path = Path();
      path.moveTo(pathConfig.points.first.dx, pathConfig.points.first.dy);
      for (int i = 1; i < pathConfig.points.length; i++) {
        path.lineTo(pathConfig.points[i].dx, pathConfig.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FreehandPainter oldDelegate) => true;
}
