import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../main.dart';
import '../widgets/ui_bits.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  late Future<List<DocumentModel>> _docsFuture;
  final Set<int> _selectedDocIds = <int>{};
  int _questions = 10;
  int _difficulty = 3;
  QuizType _type = QuizType.mcq;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _docsFuture = apiClient.getDocuments();
  }

  Future<void> _submit() async {
    if (_selectedDocIds.isEmpty) {
      showSnack(context, 'Pick at least one document', error: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final created = await apiClient.createQuiz(QuizSetupRequest(
        documentIds: _selectedDocIds.toList(),
        questions: _questions,
        difficulty: _difficulty,
        type: _type,
      ));
      if (!mounted) return;
      showSnack(context, 'Quiz created. Generate questions next.');
      Navigator.of(context).pop(created);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New quiz')),
      body: FutureBuilder<List<DocumentModel>>(
        future: _docsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snap.hasError) {
            final msg = snap.error is ApiException
                ? (snap.error as ApiException).message
                : 'Could not load documents';
            return ErrorView(
              message: msg,
              onRetry: () => setState(() {
                _docsFuture = apiClient.getDocuments();
              }),
            );
          }
          final docs = snap.data ?? const [];
          if (docs.isEmpty) {
            return const EmptyView(
              icon: Icons.upload_file,
              title: 'No documents available',
              message: 'Upload a document first from the Documents tab.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              Text('Source documents', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Pick one or more. Questions will be drawn only from these.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...docs.map((d) => CheckboxListTile(
                    title: Text(d.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(d.formatType.replaceAll('.', '').toUpperCase()),
                    value: _selectedDocIds.contains(d.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedDocIds.add(d.id);
                      } else {
                        _selectedDocIds.remove(d.id);
                      }
                    }),
                  )),
              const SizedBox(height: 16),
              Text('Question type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: QuizType.values.map((t) {
                  return ChoiceChip(
                    label: Text(t.label),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Number of questions',
                value: _questions.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                trailing: '$_questions',
                onChanged: (v) => setState(() => _questions = v.round()),
              ),
              _SliderRow(
                label: 'Difficulty (Bloom level)',
                value: _difficulty.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                trailing: '$_difficulty / 10',
                onChanged: (v) => setState(() => _difficulty = v.round()),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Create quiz'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.trailing,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String trailing;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
            Text(trailing, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
