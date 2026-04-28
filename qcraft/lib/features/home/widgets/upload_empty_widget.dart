import 'package:flutter/material.dart';
import 'package:qcraft/features/home/bloc/upload_bloc.dart';
import 'package:qcraft/features/home/bloc/upload_event.dart';

import '../../../core/constants/app_colors.dart';
import '../../../injection_container.dart';
import '../painter/dashed_border_painter.dart';

class UploadDocumentEmptyWidget extends StatelessWidget {
  const UploadDocumentEmptyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => sl<UploadBloc>().add(UploadDocumentEvent()),
      child: CustomPaint(
        painter: DashedRoundedBorderPainter(
          color: AppColors.primary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          dashLength: 10,
          gapLength: 6,
          strokeWidth: 2,
        ),
        child: Container(
          padding: EdgeInsets.all(12.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_present_rounded,
                size: 90,
                color: AppColors.primary.withOpacity(0.6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Upload Documents\n(PDF, DOCX, PPTX)",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
