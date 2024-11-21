import 'package:flutter/material.dart';

class ChipList extends StatelessWidget {
  final List<String> labels;
  final void Function(String label)? onChipPressed;

  const ChipList({
    Key? key,
    required this.labels,
    this.onChipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: labels.map((label) {
        return ActionChip(
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => onChipPressed?.call(label),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
