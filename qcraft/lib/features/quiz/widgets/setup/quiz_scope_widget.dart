import 'package:flutter/material.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_setup_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/selected_note_item.dart';

class QuizScopeWidget extends StatefulWidget {
  final List<DocumentModel> selectedDocuments;
  final Function(List<DocumentModel> documents) onUpdate;

  const QuizScopeWidget(
      {super.key, required this.selectedDocuments, required this.onUpdate});

  @override
  State<QuizScopeWidget> createState() => _QuizScopeWidgetState();
}

class _QuizScopeWidgetState extends State<QuizScopeWidget> {
  late List<DocumentModel> documents;

  @override
  void initState() {
    documents = widget.selectedDocuments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return QuizSetupWidget(
      leading: "QUIZ SCOPE",
      trailing: "${documents.length} Document(s)",
      child: Column(
        children: widget.selectedDocuments
            .map((docs) => SelectedNoteItem(
                  document: docs,
                  canRemove: documents.length > 1,
                  onRemove: () {
                    setState(() {
                      documents
                          .removeWhere((document) => document.id == docs.id);
                    });

                    widget.onUpdate(documents);
                  },
                ))
            .toList(),
      ),
    );
  }
}
