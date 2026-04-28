import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';

import '../../../injection_container.dart';
import '../bloc/quiz_state.dart';
import '../widgets/quiz_list_view.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({
    super.key,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: BlocProvider<QuizBloc>.value(
        value: sl<QuizBloc>(),
        child: BlocBuilder<QuizBloc, QuizState>(
          buildWhen: (stateA, stateB) {
            if (stateB is RetrievedQuizzes) {
              return true;
            }
            return false;
          },
          builder: (context, state) {
            return QuizListView(
              quizzes: state.quizzes ?? [],
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
