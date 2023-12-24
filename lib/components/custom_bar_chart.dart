import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBarChart extends StatelessWidget {
  final String title;
  final List<OrdinalData> records;
  final Color? color;

  const CustomBarChart(
      {required this.title, required this.records, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 240,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(title)),
            Flexible(
              child: DChartBarO(
                barLabelValue: (barGroup, barData, index) =>
                    NumberFormat.simpleCurrency(locale: 'pt')
                        .format((barData.measure as double).round()),
                barLabelDecorator: BarLabelDecorator(
                    barLabelPosition: BarLabelPosition.outside,
                    labelAnchor: BarLabelAnchor.middle),
                outsideBarLabelStyle: (barGroup, barData, index) =>
                    const LabelStyle(fontSize: 11),
                animate: true,
                measureAxis: const MeasureAxis(showLine: false),
                domainAxis: const DomainAxis(
                  gapAxisToLabel: 16,
                  thickLength: 8,
                  showLine: false,
                ),
                groupList: [
                  OrdinalGroup(
                      id: 'Bar',
                      chartType: ChartType.bar,
                      color: color ?? Colors.blueAccent,
                      data: [...records]),
                ],
              ),
            ),
          ],
        ));
  }
}
