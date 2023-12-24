import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/decimal_input_formatter.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final bool displayFloatingLabel;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool expands;

  const CustomFormField(
      {super.key,
      required this.label,
      required this.controller,
      required this.icon,
      this.keyboardType,
      this.displayFloatingLabel = false,
      this.obscureText = false,
      this.enabled = true,
      this.maxLength,
      this.focusNode,
      this.expands = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
          maxLength: maxLength,
          minLines: null,
          maxLines: expands ? null : 1,
          expands: expands,
          focusNode: focusNode,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: keyboardType ==
                  const TextInputType.numberWithOptions(decimal: true)
              ? [
                  DecimalInputFormatter(range: 2),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ]
              : null,
          enabled: enabled,
          decoration: InputDecoration(
            fillColor: Colors.black12,
            hintText: !displayFloatingLabel ? label : null,
            labelText: displayFloatingLabel ? label : null,
            prefixIcon: Icon(
              icon,
              color: Colors.black54,
              size: 22,
            ),
            border: InputBorder.none,
          )),
    );
  }
}
