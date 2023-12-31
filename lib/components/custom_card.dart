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
  final List<BottomSheetAction> options;
  final Function() onTap;

  const CustomCard(
      {super.key,
      required this.label,
      required this.description,
      required this.options,
      required this.onTap,
      required this.icon,
      this.iconColor,
      this.clipText = false,
      this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => displayOptions(context),
      child: Card(
          elevation: elevation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 15, 20, 15),
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: iconColor ?? Colors.grey,
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 16,
                    )),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 12),
                        overflow: clipText
                            ? TextOverflow.clip
                            : TextOverflow.ellipsis,
                      )
                    ]),
              ),
            ]),
          )),
    );
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
