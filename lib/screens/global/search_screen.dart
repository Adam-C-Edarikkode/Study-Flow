import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/providers/chapter_provider.dart';
import 'package:study_app/providers/note_provider.dart';
import 'package:study_app/providers/todo_provider.dart';

import 'package:study_app/screens/subject/subject_shell.dart';
import 'package:study_app/screens/chapter/chapter_shell.dart';
import 'package:study_app/screens/chapter/note_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {
      _query = text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_query.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search subjects, chapters, notes...',
              border: InputBorder.none,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        body: const Center(child: Text('Type to search for content.')),
      );
    }

    final subjects = Provider.of<SubjectProvider>(context, listen: false).subjects;
    final chapters = Provider.of<ChapterProvider>(context, listen: false).chapters;
    final notes = Provider.of<NoteProvider>(context, listen: false).allNotes;
    final todos = Provider.of<TodoProvider>(context, listen: false).todos;

    final matchedSubjects = subjects.where((s) => s.name.toLowerCase().contains(_query)).toList();
    final matchedChapters = chapters.where((c) => c.title.toLowerCase().contains(_query)).toList();
    final matchedNotes = notes.where((n) {
      if (n.title.toLowerCase().contains(_query)) return true;
      for (var b in n.blocks) {
        if (b.content.toLowerCase().contains(_query)) return true;
      }
      return false;
    }).toList();
    final matchedTodos = todos.where((t) => t.task.toLowerCase().contains(_query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search subjects, chapters, notes, tasks...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          )
        ],
      ),
      body: ListView(
        children: [
          if (matchedSubjects.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(16), child: Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
            ...matchedSubjects.map((s) => ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: Text(s.name),
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectShell(subject: s)));
              },
            ))
          ],

          if (matchedChapters.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(16), child: Text('Chapters', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
            ...matchedChapters.map((c) {
              final parentSub = subjects.cast<dynamic>().firstWhere((s) => s.id == c.subjectId, orElse: () => null);
              return ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.orange),
                title: Text(c.title),
                subtitle: Text(parentSub?.name ?? 'Unknown Subject'),
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterShell(chapter: c)));
                },
              );
            })
          ],

          if (matchedNotes.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(16), child: Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
            ...matchedNotes.map((n) {
              return ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.green),
                title: Text(n.title.isEmpty ? 'Untitled Note' : n.title),
                subtitle: Text('${n.blocks.length} blocks'),
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: n.id)));
                },
              );
            })
          ],
          
          if (matchedTodos.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.all(16), child: Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
            ...matchedTodos.map((t) {
              return ListTile(
                leading: const Icon(Icons.check_box, color: Colors.purple),
                title: Text(t.task),
              );
            })
          ],
          
          if (matchedSubjects.isEmpty && matchedChapters.isEmpty && matchedNotes.isEmpty && matchedTodos.isEmpty)
             const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No results found.')))
        ],
      ),
    );
  }
}
