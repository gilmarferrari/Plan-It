import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final Function() onConfirm;

  const CustomDialog(
      {super.key,
      required this.title,
      required this.description,
      required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      titleTextStyle: TextStyle(
          fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.bold),
      content: Text(description),
      contentTextStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
      insetPadding: const EdgeInsets.all(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ),
        Container(
            margin: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirmar',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            )),
      ],
    );
  }
}
