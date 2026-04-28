import 'package:flutter/material.dart';
import '../constants/app_text_sizes.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton(this.text, {super.key, required this.onPressed});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool isEnabled = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: !isEnabled
          ? null
          : () {
              widget.onPressed();

              setState(() {
                isLoading = true;
                isEnabled = false;
              });
            },
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        // backgroundColor: isEnabled ? null : Colors.blue.shade200,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: isLoading
            ? CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              )
            : Text(
                widget.text,
                style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey.shade200,
                    fontSize: AppTextSizes.body,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
