import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/services/data_export_service.dart';
import 'package:study_app/services/data_import_service.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/academic_provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/mind_map_provider.dart';
import 'package:study_app/providers/drawing_provider.dart';

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
              await HiveService.timestampsBox.clear();
              
              if (mounted) {
                Provider.of<SubjectProvider>(context, listen: false).refresh();
                Provider.of<ChapterProvider>(context, listen: false).refresh();
                Provider.of<StudyProvider>(context, listen: false).refresh();
                Provider.of<MindMapProvider>(context, listen: false).refresh();
                Provider.of<DrawingProvider>(context, listen: false).refresh();
                await Provider.of<AcademicProvider>(context, listen: false).clearAllData();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
              }
            },
            child: const Text('Wipe Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              onTap: () async {
                Navigator.pop(ctx);
                await DataExportService.exportToClipboard();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data exported to clipboard!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export to File'),
              onTap: () async {
                Navigator.pop(ctx);
                await DataExportService.exportToFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('Paste from Clipboard'),
              onTap: () async {
                Navigator.pop(ctx);
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null && data!.text!.trim().isNotEmpty) {
                  _confirmImport(data.text!);
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clipboard is empty!')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmImport(String jsonString) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('This will OVERWRITE all existing app data and cannot be undone. Are you sure you want to proceed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await DataImportService.importFromJsonString(jsonString, clearFirst: true);
              if (mounted) {
                 Provider.of<SubjectProvider>(context, listen: false).refresh();
                 Provider.of<ChapterProvider>(context, listen: false).refresh();
                 Provider.of<StudyProvider>(context, listen: false).refresh();
                 Provider.of<MindMapProvider>(context, listen: false).refresh();
                 Provider.of<DrawingProvider>(context, listen: false).refresh();
                 Provider.of<AcademicProvider>(context, listen: false).refresh();
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
              }
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
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

          const Text('Data Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('Export Data'),
            subtitle: const Text('Backup all data to JSON'),
            onTap: _showExportOptions,
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Import Data'),
            subtitle: const Text('Restore data from JSON'),
            onTap: _showImportOptions,
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
