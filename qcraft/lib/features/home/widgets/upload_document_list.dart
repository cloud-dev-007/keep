import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/core/widgets/primary_button.dart';
import 'package:qcraft/features/home/bloc/upload_bloc.dart';
import 'package:qcraft/features/home/widgets/upload_document_list_item.dart';

import '../bloc/upload_state.dart';
import 'continue_button.dart';

class UploadDocumentList extends StatefulWidget {
  final List<DocumentModel> documents;

  const UploadDocumentList({
    super.key,
    required this.documents,
  });

  @override
  State<UploadDocumentList> createState() => _UploadDocumentListState();
}

class _UploadDocumentListState extends State<UploadDocumentList> {
  List<num> selectedIds = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadBloc, UploadState>(
        listener: (BuildContext context, state) {
      if (state is SelectedDocumentState) {
        if (selectedIds.contains(state.id)) {
          selectedIds.remove(state.id);
        } else {
          selectedIds.add(state.id);
        }
      }
    }, buildWhen: (stateA, stateB) {
      if (stateB is SelectedDocumentState) {
        return true;
      }
      return false;
    }, builder: (context, state) {
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.documents.length,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  final document = widget.documents[index];
                  return UploadDocumentListItem(
                    document: document,
                    selected: selectedIds.contains(document.id),
                  );
                },
              ),
            ),
            SizedBox(
              height: 24,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: widget.documents.isEmpty
                  ? SizedBox()
                  : ContinueButton(
                      onTap: () {
                        // setState(() {
                        //   selectedIds.clear();
                        // });
                      },
                      selectedDocuments: widget.documents
                          .where(
                              (document) => selectedIds.contains(document.id!))
                          .toList(),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

// PrimaryButton("Continue",)
