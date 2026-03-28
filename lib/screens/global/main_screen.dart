import 'package:flutter/material.dart';
import 'package:study_app/screens/global/home_screen.dart';
import 'package:study_app/screens/global/tools_page.dart';
import 'package:study_app/screens/global/performance_page.dart';
import 'package:study_app/screens/global/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int get _pageIndex => _currentIndex > 2 ? _currentIndex - 1 : _currentIndex;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ToolsPage(),
    const PerformancePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            if (index == 2) {
              _showAddBottomSheet(context);
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Tools',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded, size: 36),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Add',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.book, color: Theme.of(context).primaryColor),
                ),
                title: const Text('Add Subject'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSubjectDialog(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark, color: Colors.orange),
                ),
                title: const Text('Add Chapter'),
                onTap: () {
                  Navigator.pop(context);
                  _showSelectSubjectForChapterDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = AppTheme.primaryColor.value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _colorOption(context, AppTheme.primaryColor.value, selectedColor, (val) => selectedColor = val),
                   _colorOption(context, AppTheme.cardGradient1.colors.first.value, selectedColor, (val) => selectedColor = val),
                   _colorOption(context, AppTheme.cardGradient2.colors.first.value, selectedColor, (val) => selectedColor = val),
                   _colorOption(context, AppTheme.cardGradient3.colors.first.value, selectedColor, (val) => selectedColor = val),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Provider.of<SubjectProvider>(context, listen: false).addSubject(
                    nameController.text,
                    selectedColor,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(BuildContext context, int colorValue, int selectedValue, Function(int) onSelect) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            onSelect(colorValue);
            setState(() {});
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedValue == colorValue ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }
    );
  }

  void _showSelectSubjectForChapterDialog(BuildContext context) {
    final subjects = Provider.of<SubjectProvider>(context, listen: false).subjects;
    if (subjects.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a subject first!')));
       return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Subject'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(subjects[index].name),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddChapterDialog(context, subjects[index].id);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddChapterDialog(BuildContext context, String subjectId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Chapter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Chapter Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Provider.of<ChapterProvider>(context, listen: false).addChapter(
                    subjectId,
                    titleController.text,
                    descriptionController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
