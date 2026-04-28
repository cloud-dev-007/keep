import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/core/model/quiz_setup_model.dart';
import 'package:qcraft/core/enums/quiz_type.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_state.dart';
import 'package:qcraft/features/quiz/screens/quiz_loading_screen.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_difficulty_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_duration_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_length_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_scope_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_type_widget.dart';

import '../../../injection_container.dart';
import '../bloc/quiz_event.dart';
import '../../../core/widgets/primary_button.dart';

class QuizSetupScreen extends StatefulWidget {
  final List<DocumentModel> selectedDocuments;

  const QuizSetupScreen({super.key, required this.selectedDocuments});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late List<DocumentModel> documents;
  late ValueNotifier<QuizSetupModel> quizSetup;

  @override
  void initState() {
    documents = widget.selectedDocuments;
    super.initState();
    quizSetup = ValueNotifier<QuizSetupModel>(QuizSetupModel(
        documentIds: documents.map((document) => document.id!).toList(),
        difficulty: 4,
        questions: 10,
        type: QuizType.mcq));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>.value(
      value: sl<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (stateA, stateB) {
          if (stateB is QuizCreated) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizLoadingScreen(stateB.id),
                ));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Start Quiz"),
          ),
          body: SingleChildScrollView(
            padding:
                EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 24.0),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  QuizScopeWidget(
                    selectedDocuments: documents,
                    onUpdate: (docs) {
                      documents = docs;
                      quizSetup.value.documentIds =
                          documents.map((document) => document.id!).toList();
                    },
                  ),
                  QuizLengthWidget(
                    onUpdate: (questions) {
                      quizSetup.value.questions = questions;
                    },
                  ),
                  QuizDifficultyWidget(
                    onUpdate: (difficulty) {
                      quizSetup.value.difficulty = difficulty;
                    },
                  ),
                  QuizDurationWidget(
                    onUpdate: (duration) {
                      quizSetup.value.duration = duration;
                    },
                  ),
                  QuizTypeWidget(
                    onUpdate: (type) {
                      quizSetup.value.type = type;
                    },
                  ),
                  PrimaryButton(
                    "Generate Quiz",
                    onPressed: () => sl<QuizBloc>().add(
                      CreateQuiz(setupModel: quizSetup.value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
