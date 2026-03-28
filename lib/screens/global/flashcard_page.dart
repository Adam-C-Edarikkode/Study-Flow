import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/providers/flashcard_provider.dart';

class FlashcardPage extends StatefulWidget {
  final String? subjectId;
  final String? chapterId;
  const FlashcardPage({super.key, this.subjectId, this.chapterId});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int _currentIndex = 0;
  bool _showBack = false;

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _nextCard(int total) {
    if (total == 0) return;
    setState(() {
      _showBack = false;
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  void _prevCard(int total) {
    if (total == 0) return;
    setState(() {
      _showBack = false;
      _currentIndex = (_currentIndex - 1 + total) % total;
    });
  }

  void _showAddDialog() {
    final frontCtrl = TextEditingController();
    final backCtrl = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontCtrl, decoration: const InputDecoration(labelText: 'Front')),
            const SizedBox(height: 8),
            TextField(controller: backCtrl, decoration: const InputDecoration(labelText: 'Back')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (frontCtrl.text.isNotEmpty && backCtrl.text.isNotEmpty) {
                 Provider.of<FlashcardProvider>(context, listen: false).addFlashcard(
                    frontCtrl.text, backCtrl.text, widget.subjectId, widget.chapterId
                 );
                 Navigator.pop(context);
              }
            },
            child: const Text('Add')
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final cards = provider.getFlashcardsForContext(widget.subjectId, widget.chapterId);
        
        // Adjust index if out of bounds after deletion
        if (_currentIndex >= cards.length && cards.isNotEmpty) {
           _currentIndex = cards.length - 1;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flashcards'),
            actions: [
              if (cards.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    provider.deleteFlashcard(cards[_currentIndex].id);
                    setState(() => _showBack = false);
                  },
                )
            ],
          ),
          body: cards.isEmpty 
              ? const Center(child: Text('No flashcards here. Add one!'))
              : Column(
                  children: [
                    const SizedBox(height: 24),
                    Text('Card ${_currentIndex + 1} of ${cards.length}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: GestureDetector(
                          onTap: _flipCard,
                          child: CustomCard(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  _showBack ? cards[_currentIndex].back : cards[_currentIndex].front,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: _showBack ? 24 : 32,
                                    color: _showBack ? AppTheme.primaryColor : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => _prevCard(cards.length)),
                        ElevatedButton(onPressed: _flipCard, child: Text(_showBack ? 'Hide Answer' : 'Show Answer')),
                        IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded), onPressed: () => _nextCard(cards.length)),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
