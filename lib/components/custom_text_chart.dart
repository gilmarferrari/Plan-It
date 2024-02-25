import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_constants.dart';

class CustomTextChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double amount;
  final NumberFormat labelFormat;
  final String suffix;

  const CustomTextChart(
      {required this.title,
      required this.amount,
      required this.labelFormat,
      this.suffix = '',
      this.subtitle,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 15, bottom: 5),
                child: Column(
                  children: [
                    Text(title),
                    Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: subtitle != null
                            ? Text(
                                subtitle!,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87),
                              )
                            : null),
                  ],
                )),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Center(
                  child: Text(
                labelFormat.format(amount),
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
            ),
          ],
        ));
  }
}
