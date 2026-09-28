import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

class ChipsRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const ChipsRow({super.key, required this.labels, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final on = index == selected;
          return ChoiceChip(
            label: Text(labels[index]),
            selected: on,
            showCheckmark: false,
            onSelected: (_) => onSelected(index),
            backgroundColor: c.card,
            selectedColor: c.primary,
            shape: const StadiumBorder(),
            side: BorderSide(color: on ? c.primary : c.border),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: on ? Colors.white : c.textSecondary,
            ),
          );
        },
      ),
    );
  }
}