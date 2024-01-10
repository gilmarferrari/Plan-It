import 'package:flutter/material.dart';

class CustomTutorialEntry {
  CustomTutorialEntry(
    List<RRect> rRectList,
    this.text,
    this.alignment,
  );

  final String text;
  final Alignment alignment;
}
