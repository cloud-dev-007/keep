import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/model/document_model.dart';
import '../../../home/widgets/document_info_sheet.dart';

class SelectedNoteItem extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onRemove;
  final bool canRemove;

  const SelectedNoteItem({
    super.key,
    required this.document,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        CupertinoSheetRoute(
          builder: (context) => DocumentInfoSheet(
            document: document,
            actionText: canRemove ? "Remove" : "",
            actionButton: canRemove ? onRemove : null,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 8),
        margin: EdgeInsetsGeometry.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: CupertinoColors.systemBrown,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(
              Icons.file_present_rounded,
              color: Colors.white,
              size: 32,
            ),
            Expanded(
              child: Text(
                document.title ?? "Title",
                style: TextStyle(
                    fontFamily: "Proxima Nova",
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            if (canRemove)
              IconButton(onPressed: onRemove, icon: Icon(Icons.close))
          ],
        ),
      ),
    );
  }
}
