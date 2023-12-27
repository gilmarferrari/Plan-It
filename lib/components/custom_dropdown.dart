import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final IconData icon;
  final List<dynamic> options;
  final dynamic value;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? title;
  final String prefix;
  final Function(dynamic value) onChanged;
  final double elevation;

  const CustomDropdown(
      {super.key,
      required this.icon,
      required this.options,
      required this.value,
      required this.onChanged,
      this.title,
      this.prefix = '',
      this.backgroundColor,
      this.iconColor,
      this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: backgroundColor ?? Colors.grey[100],
        elevation: 0,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          Stack(children: [
            Positioned(
              top: 5,
              child: Container(
                child: title != null
                    ? Text(title!,
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ))
                    : null,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: title != null ? 10 : 0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: value,
                    hint: const Text('Selecione uma opção'),
                    items: [
                      ...options.map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            '$prefix $v',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          )))
                    ],
                    onChanged: (dynamic v) => onChanged(v)),
              ),
            ),
          ])
        ]));
  }
}
