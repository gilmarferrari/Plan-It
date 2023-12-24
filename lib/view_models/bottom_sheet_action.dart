import 'package:flutter/material.dart';

class BottomSheetAction {
  String label;
  IconData icon;
  Function() onPressed;

  BottomSheetAction(
      {required this.label, required this.icon, required this.onPressed});
}
