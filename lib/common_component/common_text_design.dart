import 'package:flutter/material.dart';

class CommonTextDesign extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color color;

  const CommonTextDesign({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,


      ),
    );
  }
}
