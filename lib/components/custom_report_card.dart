import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/report.dart';

class CustomReportCard extends StatelessWidget {
  final Report report;
  final double elevation;

  const CustomReportCard({super.key, required this.report, this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Card(
        elevation: elevation,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 15, 20, 15),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: size.width - 130,
              child: Text(
                ((report.breakType == BreakType.Category &&
                        report.description != null)
                    ? '${report.description}'
                    : report.category),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: size.width - 130,
              child: Text(
                NumberFormat.simpleCurrency(locale: 'pt').format(report.amount),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
        ]));
  }
}
