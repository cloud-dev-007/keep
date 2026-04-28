import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/features/home/bloc/upload_bloc.dart';
import 'package:qcraft/features/home/bloc/upload_event.dart';
import 'package:qcraft/features/home/widgets/document_info_sheet.dart';

import '../../../injection_container.dart';

class UploadDocumentListItem extends StatelessWidget {
  final DocumentModel document;
  final bool selected;

  const UploadDocumentListItem({
    super.key,
    required this.document,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.file_present_rounded),
      title: Text(
        document.title ?? "No title",
        style: TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 2,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(document.formatType ?? "No extension"),
          Text("${document.pageCount ?? 1} page(s)"),
        ],
      ),
      trailing: Checkbox(
        value: selected,
        onChanged: (value) {
          sl<UploadBloc>().add(SelectDocumentEvent(document.id!));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      onTap: () => Navigator.push(
        context,
        CupertinoSheetRoute(
          builder: (context) => DocumentInfoSheet(
            document: document,
            actionButton: () {
              sl<UploadBloc>().add(SelectDocumentEvent(document.id!));
              Navigator.pop(context);
            },
            actionText: selected ? null : "Select",
          ),
        ),
      ),
    );
  }
}
