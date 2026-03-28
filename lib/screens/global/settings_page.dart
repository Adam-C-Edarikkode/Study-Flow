import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/database/hive_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController(
    text: HiveService.settingsBox.get('student_name', defaultValue: 'Student User')
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.isNotEmpty) {
      HiveService.settingsBox.put('student_name', _nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated successfully')));
    }
  }

  void _confirmWipeData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wipe All Data?'),
        content: const Text('This will delete all subjects, chapters, notes, tools, and study sessions permanently. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await HiveService.subjectsBox.clear();
              await HiveService.chaptersBox.clear();
              await HiveService.notesBox.clear();
              await HiveService.studyTimeBox.clear();
              await HiveService.todosBox.clear();
              await HiveService.flashcardsBox.clear();
              await HiveService.mindMapsBox.clear();
              await HiveService.drawingsBox.clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            child: const Text('Wipe Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Student Name'),
            subtitle: TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter your name'),
              onSubmitted: (_) => _saveName(),
            ),
            trailing: IconButton(icon: const Icon(Icons.check), onPressed: _saveName),
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          const Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wipe All Database Content', style: TextStyle(color: Colors.red)),
            onTap: _confirmWipeData,
          ),
        ],
      ),
    );
  }
}
