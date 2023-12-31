import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomListMonthHeader extends StatelessWidget {
  final String month;
  final double amount;

  const CustomListMonthHeader(
      {required this.month, required this.amount, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              month.toUpperCase(),
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              NumberFormat.simpleCurrency(locale: 'pt').format(amount),
              style: const TextStyle(fontSize: 11),
            )
          ],
        ),
      ),
    );
  }
}
