import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class CustomRoundedButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final bool stroked;
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;

  const CustomRoundedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.stroked = false,
    this.marginLeft = 0,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),
      child: TextButton(
        style: stroked
            ? ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 15))
            : ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 15)),
        onPressed: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
            child: Text(label)),
      ),
    );
  }
}
