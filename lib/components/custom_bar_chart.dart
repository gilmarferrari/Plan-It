import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBarChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<OrdinalData> records;
  final Color? color;
  final Widget? filter;

  const CustomBarChart(
      {required this.title,
      required this.records,
      this.subtitle,
      this.color,
      this.filter,
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
          Container(
              padding: EdgeInsets.symmetric(vertical: filter != null ? 5 : 0),
              child: filter),
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(10),
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
      ),
    );
  }
}
