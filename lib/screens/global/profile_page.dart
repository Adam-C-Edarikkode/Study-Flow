import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/screens/global/settings_page.dart';

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
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
                  'Total Study Time: 120h',
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
