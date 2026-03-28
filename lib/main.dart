import 'package:flutter/material.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/screens/global/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:study_app/database/hive_service.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/note_provider.dart';
import 'package:study_app/providers/theme_provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/todo_provider.dart';
import 'package:study_app/providers/flashcard_provider.dart';
import 'package:study_app/providers/mind_map_provider.dart';
import 'package:study_app/providers/drawing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => ChapterProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => MindMapProvider()),
        ChangeNotifierProvider(create: (_) => DrawingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const StudyApp(),
    ),
  );
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Study Productivity App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
