import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomTextButton extends StatelessWidget {
  final String label;
  final void Function()? onSubmit;
  final double height;

  const CustomTextButton({
    super.key,
    required this.label,
    required this.onSubmit,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        width: size.width * 0.8,
        child: TextButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    EdgeInsets.symmetric(vertical: height, horizontal: 40)),
            child: Text(
              label,
              style: TextStyle(
                color: AppConstants.primaryColor,
              ),
            )));
  }
}
