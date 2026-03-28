import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:intl/intl.dart';

class ChapterAddTimeTab extends StatefulWidget {
  final String subjectId;
  final String? chapterId;

  const ChapterAddTimeTab({super.key, required this.subjectId, this.chapterId});

  @override
  State<ChapterAddTimeTab> createState() => _ChapterAddTimeTabState();
}

class _ChapterAddTimeTabState extends State<ChapterAddTimeTab> {
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  String _formattedTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manual Time Entry', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes Studied',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final mins = int.tryParse(_timeController.text);
                      if (mins != null && mins > 0) {
                        Provider.of<StudyProvider>(context, listen: false).addManualSession(
                          widget.subjectId,
                          mins,
                          chapterId: widget.chapterId,
                        );
                        _timeController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time recorded!')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Save'),
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Consumer<StudyProvider>(
          builder: (context, studyProvider, child) {
            final isRunningLocal = studyProvider.isTimerRunning && studyProvider.activeSubjectId == widget.subjectId;
            final isRunningAnywhere = studyProvider.isTimerRunning;
            final secondsToDisplay = isRunningLocal ? studyProvider.activeSeconds : 0;
            
            return CustomCard(
              child: Column(
                children: [
                  Text('Active Timer', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  Text(
                    _formattedTime(secondsToDisplay),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'play',
                        onPressed: isRunningAnywhere ? null : () => studyProvider.startActiveTimer(widget.subjectId, chapterId: widget.chapterId),
                        backgroundColor: isRunningAnywhere ? Colors.grey : Colors.green,
                        child: const Icon(Icons.play_arrow),
                      ),
                      const SizedBox(width: 24),
                      FloatingActionButton(
                        heroTag: 'stop',
                        onPressed: !isRunningLocal ? null : () => studyProvider.stopActiveTimer(),
                        backgroundColor: !isRunningLocal ? Colors.grey : Colors.red,
                        child: const Icon(Icons.stop),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Consumer<StudyProvider>(
          builder: (context, studyProvider, child) {
            final sessions = widget.chapterId != null
                ? studyProvider.sessions.where((s) => s.chapterId == widget.chapterId).toList()
                : studyProvider.getSessionsForSubject(widget.subjectId);
            
            if (sessions.isEmpty) {
              return const SizedBox.shrink();
            }

            return CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Sessions', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  ...sessions.take(5).map((session) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.timer_outlined),
                      title: Text('${session.durationMinutes} minutes'),
                      subtitle: Text(DateFormat('MMM d, h:mm a').format(session.date)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteSessionDialog(context, session),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteSessionDialog(BuildContext context, dynamic session) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session?'),
          content: Text('Are you sure you want to delete this ${session.durationMinutes} min study session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Provider.of<StudyProvider>(context, listen: false).deleteSession(session.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
