import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'custom_chart_legend.dart';

class CustomPieChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<OrdinalData> records;
  final NumberFormat labelFormat;
  final BarLabelPosition barLabelPosition;
  final BarLabelAnchor barLabelAnchor;
  final String suffix;
  final Widget? filter;
  final bool vertical;

  const CustomPieChart(
      {required this.title,
      required this.records,
      required this.labelFormat,
      this.barLabelPosition = BarLabelPosition.outside,
      this.barLabelAnchor = BarLabelAnchor.middle,
      this.suffix = '',
      this.subtitle,
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
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.all(10),
                child: records.where((r) => r.measure > 0).isNotEmpty
                    ? DChartPieO(
                        configRenderPie: ConfigRenderPie(
                            arcLabelDecorator: ArcLabelDecorator(
                          labelPosition: ArcLabelPosition.auto,
                          outsideLabelStyle: const LabelStyle(
                              color: Colors.black87, fontSize: 11),
                        )),
                        customLabel: (pieData, index) {
                          return labelFormat
                              .format((pieData.measure as double).round());
                        },
                        animate: true,
                        data: [...records],
                      )
                    : Center(
                        child: Text(
                        'Sem dados',
                        style: TextStyle(color: Colors.grey[600]),
                      )),
              ),
              CustomChartLegend(records: records)
            ],
          ),
        ],
      ),
    );
  }
}
