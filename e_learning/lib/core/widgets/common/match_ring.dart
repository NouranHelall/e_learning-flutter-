import 'package:e_learning/core/colors/colors.dart';
import 'package:flutter/material.dart';

class MatchRing extends StatelessWidget {
  final int percent;
  final double size;

  const MatchRing({super.key, required this.percent, this.size = 48});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 4,
              backgroundColor: c.primaryLight,
              color: c.secondary,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(fontSize: size * 0.25, fontWeight: FontWeight.w800, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}