import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {'title': 'Mind Map Builder', 'icon': Icons.account_tree_rounded, 'color': Colors.blue},
      {'title': 'Flashcards', 'icon': Icons.style_rounded, 'color': AppTheme.accentColor},
      {'title': 'To-do List', 'icon': Icons.check_circle_outline_rounded, 'color': AppTheme.success},
      {'title': 'Quick Notes', 'icon': Icons.edit_note_rounded, 'color': Colors.orange},
      {'title': 'Study Timer', 'icon': Icons.timer_rounded, 'color': Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tools'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return CustomCard(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tool['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tool['icon'],
                    size: 40,
                    color: tool['color'],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tool['title'],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Tool'),
      ),
    );
  }
}
