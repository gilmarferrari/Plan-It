import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  final void Function(String) onChanged;
  final String? initialText;

  const CustomSearchField(
      {super.key, required this.onChanged, this.initialText});

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  final FocusNode focusNode = FocusNode();
  late final TextEditingController controller =
      TextEditingController(text: widget.initialText);

  @override
  initState() {
    super.initState();

    focusNode.requestFocus();
  }

  @override
  dispose() {
    focusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(120, 120, 120, 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
          controller: controller,
          onChanged: (value) => widget.onChanged(value),
          textAlignVertical: TextAlignVertical.center,
          cursorColor: Colors.white,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Pesquisar...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          )),
    );
  }
}
