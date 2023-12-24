import 'package:flutter/material.dart';

import '../view_models/bottom_sheet_action.dart';
import 'custom_drawer_button.dart';

class CustomBottomSheet extends StatelessWidget {
  final List<BottomSheetAction> options;

  const CustomBottomSheet({required this.options, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: (options.length * 54),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...options.map((i) => CustomDrawerButton(
                label: i.label,
                icon: Icon(i.icon),
                color: Colors.grey[800],
                onPressed: () => {
                      Navigator.pop(context),
                      i.onPressed(),
                    }))
          ],
        ));
  }
}
