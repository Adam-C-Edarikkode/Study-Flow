import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/widgets/custom_card.dart';

class ChapterAddTimeTab extends StatefulWidget {
  final String subjectId;

  const ChapterAddTimeTab({super.key, required this.subjectId});

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
        CustomCard(
          child: Column(
            children: [
              Text('Active Timer', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Text(
                '00:00:00',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'play',
                    onPressed: () {},
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.play_arrow),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'stop',
                    onPressed: () {},
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.stop),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
