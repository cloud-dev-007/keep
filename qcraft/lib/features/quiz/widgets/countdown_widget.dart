import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_state.dart';

import '../../../injection_container.dart';

class CountdownWidget extends StatefulWidget {
  final Duration? initialDuration;
  final VoidCallback? onTimerEnd;
  final Function(int) onUpdate;

  const CountdownWidget({
    super.key,
    required this.initialDuration,
    this.onTimerEnd,
    required this.onUpdate,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  late Duration _remainingTime;
  bool _isPaused = false;
  bool _isFinished = false;
  late AnimationController _warningController;
  late Animation<Color?> _warningColorAnimation;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration ?? Duration();

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _warningColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red.shade300,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));
    if (widget.initialDuration != null) {
      _startTimer();
    } else {
      _startStopwatch();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _warningController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isFinished) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds + 1);

          widget.onUpdate(_remainingTime.inSeconds);
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isFinished) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);

            int timeSpent =
                widget.initialDuration!.inSeconds - _remainingTime.inSeconds;

            widget.onUpdate(timeSpent);

            // Start warning animation when 5 minutes left
            if (_remainingTime.inMinutes <= 5 && _remainingTime.inSeconds > 0) {
              if (!_warningController.isAnimating) {
                _warningController.repeat(reverse: true);
              }
            }
          } else {
            _isFinished = true;
            _timer?.cancel();
            _warningController.stop();
            widget.onTimerEnd?.call();
          }
        });
      }
    });
  }

  void _togglePause(bool isPaused) {
    setState(() {
      _isPaused = isPaused;
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  Color _getTimerColor() {
    if (widget.initialDuration != null) {
      if (_isFinished) return Colors.red;
      if (_remainingTime.inMinutes <= 5) {
        return _warningColorAnimation.value ?? Colors.red.shade300;
      }
    }
    if (_isPaused) {
      return Colors.grey;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>.value(
      value: sl<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (stateA, stateB) {
          if (stateB is QuizPaused) {
            _togglePause(stateB.isPaused);
          }
        },
        child: AnimatedBuilder(
          animation: _warningColorAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _isFinished
                    ? Colors.red.withOpacity(0.2)
                    : _getTimerColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTimerColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _formatTime(_remainingTime),
                style: TextStyle(
                  color: _getTimerColor(),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
