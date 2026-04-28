import 'package:flutter/material.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/features/quiz/screens/quiz_setup_screen.dart';

import '../../../core/constants/app_text_sizes.dart';

class ContinueButton extends StatefulWidget {
  final List<DocumentModel> selectedDocuments;
  final VoidCallback onTap;

  const ContinueButton({
    super.key,
    required this.selectedDocuments,
    required this.onTap,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    isEnabled = widget.selectedDocuments.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        onPressed: !isEnabled
            ? null
            : () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizSetupScreen(
                        selectedDocuments: widget.selectedDocuments,
                      ),
                    ));
                widget.onTap();
              },
        style: TextButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
          backgroundColor: isEnabled ? null : Colors.grey.shade400,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          "Continue",
          style: TextStyle(
              color: isEnabled ? Colors.white : Colors.grey.shade200,
              fontSize: AppTextSizes.body,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
