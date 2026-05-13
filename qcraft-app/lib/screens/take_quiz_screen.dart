import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../main.dart';
import '../state/quiz_session.dart';
import '../widgets/ui_bits.dart';
import 'result_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  const TakeQuizScreen({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late final QuizSession _session;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _session = QuizSession(quiz: widget.quiz);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave quiz?'),
        content: const Text('Your answers will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await apiClient.evaluateAttempt(_session.toRequest());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(quiz: widget.quiz, result: result),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: ListenableBuilder(
        listenable: _session,
        builder: (context, _) {
          final q = _session.current;
          final selected = _session.answerFor(q.id);
          return Scaffold(
            appBar: AppBar(
              title: Text('Q ${_session.index + 1} / ${_session.total}'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      '${_session.answeredCount} answered',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_session.index + 1) / _session.total,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Text(
                  q.type,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 6),
                Text(q.question, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _AnswerInput(
                  question: q,
                  value: selected,
                  onChanged: (v) => _session.setAnswer(q.id, v),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: _session.isFirst ? null : _session.previous,
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitting
                            ? null
                            : _session.isLast
                                ? _submit
                                : _session.next,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_session.isLast ? Icons.check : Icons.arrow_forward),
                        label: Text(_session.isLast ? 'Submit' : 'Next'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnswerInput extends StatefulWidget {
  const _AnswerInput({required this.question, required this.value, required this.onChanged});

  final QuizQuestionModel question;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  State<_AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<_AnswerInput> {
  // For text-based answers we own a controller keyed by the question id so the
  // cursor doesn't get reset on every rebuild (the session notifies on every
  // keystroke). When the question changes we rebuild the controller.
  TextEditingController? _controller;
  int? _controllerForQuestionId;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  TextEditingController _ensureController() {
    if (_controllerForQuestionId != widget.question.id) {
      _controller?.dispose();
      _controller = TextEditingController(text: widget.value ?? '');
      _controllerForQuestionId = widget.question.id;
    }
    return _controller!;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.question.type) {
      case 'MCQ':
        return Column(
          children: widget.question.options.map((o) {
            return RadioListTile<String>(
              title: Text(o.value),
              value: o.value,
              groupValue: widget.value,
              onChanged: (v) => widget.onChanged(v ?? ''),
            );
          }).toList(growable: false),
        );
      case 'TrueFalse':
        return Column(
          children: const ['true', 'false']
              .map((v) => RadioListTile<String>(
                    title: Text(v == 'true' ? 'True' : 'False'),
                    value: v,
                    groupValue: widget.value,
                    onChanged: (val) => widget.onChanged(val ?? ''),
                  ))
              .toList(growable: false),
        );
      case 'FillInTheBlank':
      case 'Theory':
      default:
        final ctrl = _ensureController();
        return TextField(
          controller: ctrl,
          maxLines: widget.question.type == 'Theory' ? 6 : 2,
          decoration: const InputDecoration(
            hintText: 'Type your answer…',
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onChanged,
        );
    }
  }
}
