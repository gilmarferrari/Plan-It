import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/bottom_sheet_action.dart';
import 'custom_bottom_sheet.dart';

class CustomGoalCard extends StatelessWidget {
  final String label;
  final double goal;
  final double progress;
  final IconData icon;
  final double elevation;
  final Color? iconColor;
  final bool clipText;
  final List<BottomSheetAction> options;
  final Function() onTap;

  const CustomGoalCard(
      {super.key,
      required this.label,
      required this.goal,
      required this.progress,
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
                  child: Container(
                padding: const EdgeInsets.only(top: 5, right: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            NumberFormat.simpleCurrency(locale: 'pt')
                                .format(goal),
                            style: const TextStyle(fontSize: 12),
                            overflow: clipText
                                ? TextOverflow.clip
                                : TextOverflow.ellipsis,
                          )
                        ]),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SliderTheme(
                          data: SliderThemeData(
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbShape: SliderComponentShape.noOverlay,
                              disabledActiveTrackColor:
                                  isOverflowing() ? Colors.red : Colors.green),
                          child: Slider(value: getProgress(), onChanged: null)),
                    ),
                    Text(
                      'Realizado: ${NumberFormat.simpleCurrency(locale: 'pt').format(progress)} (${NumberFormat.decimalPercentPattern(locale: 'pt').format(getProgress(limitToGoal: false))})',
                      style: const TextStyle(fontSize: 11),
                      overflow:
                          clipText ? TextOverflow.clip : TextOverflow.ellipsis,
                    )
                  ],
                ),
              )),
            ]),
          )),
    );
  }

  bool isOverflowing() {
    return progress > goal;
  }

  double getProgress({bool limitToGoal = true}) {
    return (progress > 0
            ? (progress <= goal || (goal > 0 && !limitToGoal)
                ? (progress / goal)
                : 1)
            : 0)
        .toDouble();
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
