import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBarChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<OrdinalData> records;
  final NumberFormat labelFormat;
  final BarLabelPosition barLabelPosition;
  final BarLabelAnchor barLabelAnchor;
  final String suffix;
  final Color? color;
  final Widget? filter;
  final bool vertical;

  const CustomBarChart(
      {required this.title,
      required this.records,
      required this.labelFormat,
      this.barLabelPosition = BarLabelPosition.outside,
      this.barLabelAnchor = BarLabelAnchor.middle,
      this.suffix = '',
      this.subtitle,
      this.color,
      this.filter,
      this.vertical = true,
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
            child: records.where((r) => r.measure > 0).isNotEmpty
                ? DChartBarO(
                    configRenderBar:
                        ConfigRenderBar(maxBarWidthPx: vertical ? 100 : 25),
                    barLabelValue: (barGroup, barData, index) =>
                        '${labelFormat.format((barData.measure as double).round())}$suffix',
                    barLabelDecorator: BarLabelDecorator(
                        barLabelPosition: barLabelPosition,
                        labelAnchor: barLabelAnchor),
                    outsideBarLabelStyle: (barGroup, barData, index) =>
                        const LabelStyle(fontSize: 11),
                    animate: true,
                    vertical: vertical,
                    measureAxis: const MeasureAxis(
                        showLine: false, desiredMaxTickCount: 3),
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
                  )
                : Center(
                    child: Text(
                    'Sem dados',
                    style: TextStyle(color: Colors.grey[600]),
                  )),
          ),
        ],
      ),
    );
  }
}
