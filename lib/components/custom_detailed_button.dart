import 'package:flutter/material.dart';

class CustomDetailedButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showNextIndicator;
  final void Function()? onPress;
  final void Function()? onLongPress;

  const CustomDetailedButton(
      {super.key,
      required this.label,
      required this.description,
      required this.icon,
      required this.onPress,
      this.onLongPress,
      this.backgroundColor,
      this.foregroundColor,
      this.elevation = 0,
      this.showNextIndicator = true});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Card(
        elevation: elevation,
        child: TextButton(
          onPressed: onPress,
          onLongPress: onLongPress,
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[800],
            backgroundColor: backgroundColor,
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  child: Icon(icon, color: foregroundColor)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: size.width - (showNextIndicator ? 145 : 116),
                  child: Text(label,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: showNextIndicator
                            ? TextOverflow.ellipsis
                            : TextOverflow.clip,
                      )),
                ),
                SizedBox(
                  width: size.width - 145,
                  child: Text(description,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      )),
                )
              ]),
            ]),
            Flexible(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  child: showNextIndicator
                      ? const Icon(Icons.keyboard_arrow_right_rounded, size: 28)
                      : null),
            )
          ]),
        ));
  }
}
