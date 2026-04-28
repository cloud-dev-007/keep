import 'package:flutter/material.dart';

import '../../../core/model/option_model.dart';

class OptionSelector extends StatefulWidget {
  final List<OptionModel> options;
  final void Function(OptionModel option) onSelected;

  const OptionSelector({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<OptionSelector> createState() => _OptionSelectorState();
}

class _OptionSelectorState extends State<OptionSelector> {
  num? selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return RadioListTile<num>(
          title: Text(
            option.value ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
          value: option.id!,
          groupValue: selectedId,
          onChanged: (num? value) {
            setState(() {
              selectedId = value;
            });
            if (value != null) {
              OptionModel? selected = widget.options.firstWhere(
                (option) => option.id == value,
              );
              widget.onSelected(selected);
            }
          },
        );
      }).toList(),
    );
  }
}
