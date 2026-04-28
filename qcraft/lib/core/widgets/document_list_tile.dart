import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/core/model/document_model.dart';

class DocumentListTile extends StatelessWidget {
  final List<DocumentModel> documents;

  const DocumentListTile({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...documents.map(
          (document) => Container(
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
                    document.fileName ?? "File Name",
                    style: TextStyle(
                        fontFamily: "Proxima Nova",
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 4),
                  margin: EdgeInsetsGeometry.only(left: 4),
                  decoration: BoxDecoration(
                      color: CupertinoColors.activeOrange,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    document.formatType?.toUpperCase() ?? "File Name",
                    style: TextStyle(
                        fontFamily: "Proxima Nova",
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
