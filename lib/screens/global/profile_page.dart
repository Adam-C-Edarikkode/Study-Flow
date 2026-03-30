import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/screens/global/settings_page.dart';
import 'package:study_app/widgets/notification_sheet.dart';
import 'package:study_app/services/data_export_service.dart';
import 'package:study_app/services/data_import_service.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/academic_provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/mind_map_provider.dart';
import 'package:study_app/providers/drawing_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false; // In a real app, this would be read from a provider

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
               await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
               if (!mounted) return;
               setState(() {}); // Refresh name changes
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_rounded),
                  title: const Text('Backup & Export'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: _showExportOptions,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => NotificationSheet.show(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final last7DaysMinutes = studyProvider.getChartData(TimeRange.last7Days).fold(0, (sum, val) => sum + val);
    final hours = last7DaysMinutes ~/ 60;
    final mins = last7DaysMinutes % 60;

    return CustomCard(
      gradient: AppTheme.primaryGradient,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      HiveService.settingsBox.get('student_name', defaultValue: 'Student User'),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      onPressed: () => _showEditNameDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Study Time (Last 7d): ${hours}h ${mins}m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          )
        ],
      ),
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
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('Import from Clipboard'),
              onTap: () {
                Navigator.pop(ctx);
                _showImportOptions();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportOptions() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      if (!mounted) return;
      _confirmImport(data.text!);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clipboard is empty!')));
    }
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
                 setState(() {}); // Refresh header
              }
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: HiveService.settingsBox.get('student_name', defaultValue: 'Student User'));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Your Name'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  HiveService.settingsBox.put('student_name', controller.text);
                  setState(() {}); // Rebuild header
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
