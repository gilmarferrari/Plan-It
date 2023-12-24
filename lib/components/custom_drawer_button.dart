import 'package:flutter/material.dart';

class CustomDrawerButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final void Function()? onPressed;
  final Color? color;

  const CustomDrawerButton(
      {super.key,
      required this.label,
      required this.icon,
      this.onPressed,
      this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.all(15),
      ),
      onPressed: onPressed,
      child: Row(children: [
        icon,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ]),
    );
  }
}
