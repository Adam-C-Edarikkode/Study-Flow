import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/mind_map_provider.dart';
import 'package:study_app/models/mind_map.dart';

class MindMapEditorScreen extends StatefulWidget {
  final String mindMapId;
  const MindMapEditorScreen({super.key, required this.mindMapId});

  @override
  State<MindMapEditorScreen> createState() => _MindMapEditorScreenState();
}

class _MindMapEditorScreenState extends State<MindMapEditorScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _initialized = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _addNode(BuildContext context, MindMapProvider provider, MindMap map, {String? parentId, double? parentX, double? parentY}) {
    int siblings = map.nodes.where((n) => parentId != null ? n.parentId == parentId : n.parentId == null).length;
    double dy = 0;
    if (siblings > 0) {
      int factor = ((siblings + 1) ~/ 2);
      int sign = siblings % 2 == 1 ? 1 : -1;
      dy = factor * 100.0 * sign; // Scatter by 100 vertical units
    }

    final node = MindMapNode(
      text: '',
      x: parentX != null ? parentX + 200 : 5000, 
      y: parentY != null ? parentY + dy : 5000,
      parentId: parentId,
    );
    provider.updateMindMapNode(map.id, node);
    _editNodeText(context, provider, map, node, isNew: true);
  }

  void _editNodeText(BuildContext context, MindMapProvider provider, MindMap map, MindMapNode node, {bool isNew = false}) {
     final ctrl = TextEditingController(text: node.text);
     showDialog(context: context, builder: (ctx) {
       return AlertDialog(
         title: Text(isNew ? 'New Node' : 'Edit Node'),
         content: TextField(
            controller: ctrl, 
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Node content...')
         ),
         actions: [
           TextButton(
             onPressed: () {
                if (isNew) provider.deleteMindMapNode(map.id, node.id);
                Navigator.pop(ctx);
             }, 
             child: const Text('Cancel')
           ),
           ElevatedButton(
             onPressed: () {
                if (ctrl.text.trim().isEmpty) {
                   provider.deleteMindMapNode(map.id, node.id);
                } else {
                   node.text = ctrl.text;
                   provider.updateMindMapNode(map.id, node);
                }
                Navigator.pop(ctx);
             }, 
             child: const Text('Save')
           )
         ],
       );
     });
  }

  void _showNodeOptions(BuildContext context, MindMapProvider provider, MindMap map, MindMapNode node) {
     showModalBottomSheet(
       context: context,
       builder: (ctx) {
         return SafeArea(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               ListTile(
                 leading: const Icon(Icons.edit),
                 title: const Text('Edit Text'),
                 onTap: () {
                   Navigator.pop(ctx);
                   _editNodeText(context, provider, map, node);
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.account_tree),
                 title: const Text('Add Child Node'),
                 onTap: () {
                   Navigator.pop(ctx);
                   _addNode(context, provider, map, parentId: node.id, parentX: node.x, parentY: node.y);
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.delete, color: Colors.red),
                 title: const Text('Delete Node', style: TextStyle(color: Colors.red)),
                 onTap: () {
                   Navigator.pop(ctx);
                   provider.deleteMindMapNode(map.id, node.id);
                 },
               ),
             ],
           ),
         );
       }
     );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindMapProvider>(
      builder: (context, provider, child) {
        final map = provider.mindMaps.cast<MindMap?>().firstWhere((m) => m?.id == widget.mindMapId, orElse: () => null);
        if (map == null) return const Scaffold(body: Center(child: Text('Map not found')));

        if (!_initialized) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (map.nodes.isNotEmpty) {
                final first = map.nodes.first;
                final screenCenter = MediaQuery.of(context).size / 2;
                _transformationController.value = Matrix4.identity()
                  ..translate(-first.x + screenCenter.width, -first.y + screenCenter.height);
             } else {
                final screenCenter = MediaQuery.of(context).size / 2;
                _transformationController.value = Matrix4.identity()
                  ..translate(-5000.0 + screenCenter.width, -5000.0 + screenCenter.height);
             }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(map.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Root Node',
                onPressed: () => _addNode(context, provider, map),
              )
            ],
          ),
          body: InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(10000),
            minScale: 0.1,
            maxScale: 2.0,
            child: SizedBox(
              width: 10000,
              height: 10000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MindMapPainter(map.nodes),
                    ),
                  ),
                  ...map.nodes.map((node) {
                     return Positioned(
                       left: node.x,
                       top: node.y,
                       child: GestureDetector(
                         onPanUpdate: (details) {
                           node.x += details.delta.dx;
                           node.y += details.delta.dy;
                           provider.updateMindMapNode(map.id, node);
                         },
                         onTap: () => _showNodeOptions(context, provider, map, node),
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           decoration: BoxDecoration(
                             color: Theme.of(context).cardColor,
                             border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                             borderRadius: BorderRadius.circular(16),
                             boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                             ]
                           ),
                           child: Text(
                             node.text,
                             style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
                           ),
                         ),
                       ),
                     );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MindMapPainter extends CustomPainter {
  final List<MindMapNode> nodes;

  _MindMapPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var node in nodes) {
      if (node.parentId != null) {
        final parent = nodes.cast<MindMapNode?>().firstWhere((n) => n?.id == node.parentId, orElse: () => null);
        if (parent != null) {
          // Draw line between roughly the centers of the two nodes.
          // Because we don't know text size implicitly in the painter, we estimate a 50x20 offset.
          final p1 = Offset(parent.x + 40, parent.y + 20); 
          final p2 = Offset(node.x + 40, node.y + 20);
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapPainter oldDelegate) => true; 
}
