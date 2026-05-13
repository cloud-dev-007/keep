import 'package:flutter/material.dart';

import '../api/models.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.quiz, required this.result});

  final QuizModel quiz;
  final QuizAttemptResultModel result;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final pct = result.accuracyPct;
    final correct = result.attempts.where((a) => a.correct).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(quiz.displayTitle, style: t.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          strokeWidth: 10,
                          backgroundColor: t.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${pct.toStringAsFixed(0)}%',
                              style: t.textTheme.headlineMedium),
                          Text('$correct / ${result.attempts.length}',
                              style: t.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  if (result.timeTaken != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Time: ${_formatDuration(result.timeTaken!)}',
                      style: t.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (result.weakTopics.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Weak topics', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: result.weakTopics
                  .map((topic) => Chip(label: Text(topic)))
                  .toList(growable: false),
            ),
          ],
          if (result.analysis != null && result.analysis!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Analysis', style: t.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(result.analysis!.trim(), style: t.textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text('Question breakdown', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._buildBreakdown(context),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreakdown(BuildContext context) {
    final byQid = <int, QuestionAttemptResultModel>{
      for (final a in result.attempts)
        if (a.questionId != null) a.questionId!: a,
    };
    // Fallback: align attempts in order if questionId wasn't included.
    final fallback = result.attempts.length == quiz.questions.length;
    final rows = <Widget>[];
    for (var i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      final a = byQid[q.id] ?? (fallback ? result.attempts[i] : null);
      rows.add(_BreakdownRow(index: i + 1, question: q, attempt: a));
    }
    return rows;
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.index, required this.question, required this.attempt});

  final int index;
  final QuizQuestionModel question;
  final QuestionAttemptResultModel? attempt;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final ok = attempt?.correct == true;
    final color = attempt == null
        ? t.colorScheme.outline
        : (ok ? Colors.green : t.colorScheme.error);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  attempt == null ? Icons.help_outline : (ok ? Icons.check_circle : Icons.cancel),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Q$index. ${question.question}',
                    style: t.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (attempt != null) ...[
              const SizedBox(height: 6),
              _kv(context, 'Your answer', attempt!.value.isEmpty ? '—' : attempt!.value),
            ],
            if (question.answer != null && question.answer!.trim().isNotEmpty)
              _kv(context, 'Correct answer', question.answer!.trim()),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          style: t.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$k: ',
              style: TextStyle(color: t.colorScheme.outline),
            ),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }
}
