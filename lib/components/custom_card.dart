import 'package:flutter/material.dart';
import '../view_models/bottom_sheet_action.dart';
import 'custom_bottom_sheet.dart';

class CustomCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final double elevation;
  final Color? iconColor;
  final bool clipText;
  final bool showOptionsButton;
  final List<BottomSheetAction> options;

  const CustomCard(
      {super.key,
      required this.label,
      required this.description,
      required this.options,
      required this.icon,
      this.iconColor,
      this.clipText = false,
      this.showOptionsButton = true,
      this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Card(
        elevation: elevation,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 15, 15, 15),
              child: Icon(icon, color: iconColor),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: size.width - 130,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: size.width - 130,
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                  overflow:
                      clipText ? TextOverflow.clip : TextOverflow.ellipsis,
                ),
              )
            ]),
          ]),
          Container(
              padding: const EdgeInsets.all(10),
              child: showOptionsButton
                  ? IconButton(
                      splashRadius: 20,
                      onPressed: () => displayOptions(context),
                      icon: const Icon(Icons.more_vert),
                    )
                  : const Padding(padding: EdgeInsets.symmetric(vertical: 24)))
        ]));
  }

  displayOptions(context) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (builder) {
          return CustomBottomSheet(options: options);
        });
  }
}
