import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';

class CustomChartLegend extends StatelessWidget {
  final List<OrdinalData> records;

  const CustomChartLegend({required this.records, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 15),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ...records.map((r) => Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                      color: r.color, borderRadius: BorderRadius.circular(1)),
                  margin: const EdgeInsets.only(left: 10, right: 6),
                ),
                Text('${r.domain} (${getPercentage(r.measure)}%)',
                    style: const TextStyle(fontSize: 11))
              ],
            ))
      ]),
    );
  }

  int getPercentage(num measure) {
    if (measure <= 0) {
      return 0;
    }

    return ((measure /
                records
                    .map((r) => r.measure)
                    .fold<double>(0, (a, b) => a + b)) *
            100)
        .round();
  }
}
