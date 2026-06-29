import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../main.dart';
import '../widgets/ui_bits.dart';
import 'create_quiz_screen.dart';
import 'take_quiz_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  late Future<List<QuizModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = apiClient.getQuizzes();
  }

  void _reload() {
    setState(() {
      _future = apiClient.getQuizzes();
    });
  }

  Future<void> _newQuiz() async {
    final created = await Navigator.of(context).push<QuizModel>(
      MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
    );
    if (created != null) _reload();
  }

  Future<void> _open(QuizModel quiz) async {
    // If the quiz has no questions yet, generate them first.
    QuizModel ready = quiz;
    if (!quiz.hasQuestions) {
      final generated = await _generateWithDialog(quiz.id);
      if (generated == null) return;
      ready = generated;
    }
    if (!mounted) return;
    if (ready.questions.isEmpty) {
      showSnack(context, 'No questions could be generated for this quiz.', error: true);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: ready)),
    );
    _reload();
  }

  Future<QuizModel?> _generateWithDialog(int quizId) async {
    final completer = Future<QuizModel>.microtask(() => apiClient.generateQuiz(quizId));
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(width: 16),
              Expanded(child: Text('Generating questions…\nThis can take a minute.')),
            ],
          ),
        ),
      ),
    );
    try {
      final q = await completer;
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return q;
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showSnack(context, e.message, error: true);
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          const LogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reload();
          await _future;
        },
        child: FutureBuilder<List<QuizModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingView(label: 'Fetching quizzes…');
            }
            if (snap.hasError) {
              final msg = snap.error is ApiException
                  ? (snap.error as ApiException).message
                  : 'Could not load quizzes';
              return ErrorView(message: msg, onRetry: _reload);
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  EmptyView(
                    icon: Icons.quiz,
                    title: 'No quizzes yet',
                    message: 'Create one from a document you have already uploaded.',
                    action: FilledButton.icon(
                      onPressed: _newQuiz,
                      icon: const Icon(Icons.add),
                      label: const Text('Create quiz'),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) => _QuizCard(quiz: items[i], onTap: () => _open(items[i])),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newQuiz,
        icon: const Icon(Icons.add),
        label: const Text('New quiz'),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz, required this.onTap});

  final QuizModel quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final subtitleParts = <String>[
      '${quiz.noOfQuestions} Q',
      'Diff ${quiz.difficulty}',
      quiz.type.label,
      if (quiz.createdAt != null) DateFormat.yMMMd().format(quiz.createdAt!),
    ];
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: t.colorScheme.primaryContainer,
                child: Text(
                  '${quiz.id}',
                  style: TextStyle(color: t.colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz.displayTitle, style: t.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' • '),
                      style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.outline),
                    ),
                    if (!quiz.hasQuestions) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tap to generate questions',
                        style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
