import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_list_month_header.dart';
import '../components/custom_report_card.dart';
import '../components/loading_container.dart';
import '../models/budget_entry.dart';
import '../models/expense.dart';
import '../models/incoming.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../utils/extensions.dart';
import '../view_models/enum_entry.dart';
import '../view_models/report.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  final List<EnumEntry<ReportType>> _reportTypes = [
    EnumEntry(description: 'Rendimentos', value: ReportType.Incomings),
    EnumEntry(description: 'Despesas', value: ReportType.Expenses),
    EnumEntry(
        description: 'Despesas Pendentes', value: ReportType.PendingExpenses),
    EnumEntry(
        description: 'Despesas Agendadas', value: ReportType.ScheduledExpenses),
    EnumEntry(description: 'Orçamento', value: ReportType.Budgets),
  ];
  late EnumEntry<ReportType> _reportType = _reportTypes.first;
  final List<EnumEntry<BreakType>> _breakTypes = [
    EnumEntry(description: 'Por Mês', value: BreakType.Month),
    EnumEntry(description: 'Por Categoria', value: BreakType.Category),
  ];
  late EnumEntry<BreakType> _breakType = _breakTypes.first;
  final List<int> _years = [
    for (int i = 2020; i <= DateTime.now().year + 1; i++) i
  ];
  int _year = DateTime.now().year;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _future = getReportData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<Report> records = [];

            switch (_reportType.value) {
              case ReportType.Incomings:
                records = (snapshot.data[0] as List<Incoming>)
                    .map((x) => Report(
                        breakType: _breakType.value,
                        entryDate: x.entryDate,
                        amount: x.grossAmount,
                        category: x.incomingCategory.description))
                    .toList();
                break;
              case ReportType.Expenses:
                records = (snapshot.data[0] as List<Expense>)
                    .map((x) => Report(
                        breakType: _breakType.value,
                        entryDate: (x.paymentDate ?? x.entryDate),
                        amount: x.amount,
                        category: x.budgetCategory.description,
                        description: x.description))
                    .toList();
                break;
              case ReportType.PendingExpenses:
                records = (snapshot.data[0] as List<Expense>)
                    .map((x) => Report(
                        breakType: _breakType.value,
                        entryDate: (x.paymentDate ?? x.entryDate),
                        amount: x.amount,
                        category: x.budgetCategory.description,
                        description: x.description))
                    .toList();
                break;
              case ReportType.ScheduledExpenses:
                records = (snapshot.data[0] as List<Expense>)
                    .map((x) => Report(
                        breakType: _breakType.value,
                        entryDate: (x.paymentDate ?? x.entryDate),
                        amount: x.amount,
                        category: x.budgetCategory.description,
                        description: x.description))
                    .toList();
                break;
              case ReportType.Budgets:
                records = (snapshot.data[0] as List<BudgetEntry>)
                    .map((x) => Report(
                        breakType: _breakType.value,
                        entryDate: x.entryDate,
                        amount: x.amount,
                        category: x.budgetCategory.description))
                    .toList();
                break;
            }

            records.sort((a, b) => a.entryDate.isAfter(b.entryDate) ? -1 : 1);

            var sections = [];

            switch (_breakType.value) {
              case BreakType.Month:
                sections = records
                    .map((r) =>
                        DateFormat('MMMM/yyyy', 'pt').format(r.entryDate))
                    .toSet()
                    .toList();
                break;
              case BreakType.Category:
                sections = records.map((r) => r.category).toSet().toList();
                break;
            }

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'RELATÓRIOS',
                  style: TextStyle(fontSize: 14),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() => _showFilters = !_showFilters);
                      },
                      splashRadius: 20,
                      icon: Icon(
                        _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                        size: 20,
                      ))
                ],
              ),
              body: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _showFilters ? 220 : 0,
                    child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          CustomDropdown(
                            title: 'Tipo de Relatório',
                            icon: Icons.bar_chart,
                            value: _reportType,
                            options: _reportTypes,
                            backgroundColor: Colors.white,
                            onChanged: (dynamic type) {
                              setState(() {
                                _reportType = type;
                                _future = getReportData();
                              });
                            },
                          ),
                          CustomDropdown(
                            title: 'Tipo de Quebra',
                            icon: Icons.insert_page_break,
                            value: _breakType,
                            options: _breakTypes,
                            backgroundColor: Colors.white,
                            onChanged: (dynamic type) {
                              setState(() {
                                _breakType = type;
                                _future = getReportData();
                              });
                            },
                          ),
                          CustomDropdown(
                            title: 'Ano de Referência',
                            icon: Icons.calendar_month,
                            value: _year,
                            options: _years,
                            backgroundColor: Colors.white,
                            enabled: isYearSelectionEnabled(),
                            disabledText: 'Todos',
                            onChanged: (dynamic year) {
                              setState(() {
                                _year = year;
                                _future = getReportData();
                              });
                            },
                          ),
                        ]),
                  ),
                  Container(
                    child: !_showFilters
                        ? Card(
                            color: AppConstants.primaryColor,
                            elevation: 0,
                            margin: const EdgeInsets.all(5),
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TOTAL',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    ),
                                    Text(
                                      NumberFormat.simpleCurrency(locale: 'pt')
                                          .format(records
                                              .map((i) => i.amount)
                                              .fold<double>(
                                                  0, (a, b) => a + b)),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    )
                                  ],
                                )),
                          )
                        : null,
                  ),
                  Flexible(
                    child: ListView.builder(
                        itemCount: sections.length,
                        itemBuilder: (ctx, index) {
                          var section = sections[index];
                          var sectionRecords =
                              getSectionRecords(records, section);

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomListMonthHeader(
                                    month: section,
                                    amount: sectionRecords
                                        .map((i) => i.amount)
                                        .fold<double>(0, (a, b) => a + b)),
                                ...sectionRecords
                                    .map((r) => CustomReportCard(report: r))
                              ]);
                        }),
                  ),
                ],
              ),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<List<dynamic>>> getReportData() async {
    switch (_reportType.value) {
      case ReportType.Incomings:
        return [await _localDatabase.getIncomings(year: _year)];
      case ReportType.Expenses:
        return [await _localDatabase.getExpenses(year: _year)];
      case ReportType.PendingExpenses:
        return [
          await _localDatabase.getExpenses(year: _year, unpaidOnly: true)
        ];
      case ReportType.ScheduledExpenses:
        return [
          await _localDatabase.getExpenses(year: _year, scheduledOnly: true)
        ];
      case ReportType.Budgets:
        return [await _localDatabase.getBudgetEntries(year: _year)];
    }
  }

  List<Report> getSectionRecords(List<Report> records, String section) {
    switch (_breakType.value) {
      case BreakType.Month:
        return Extensions.groupBy<Report>(
                records
                    .where((r) =>
                        DateFormat('MMMM/yyyy', 'pt').format(r.entryDate) ==
                        section)
                    .toList(),
                (r) => r.category)
            .entries
            .toList()
            .map((e) => Report(
                breakType: e.value.first.breakType,
                entryDate: e.value.first.entryDate,
                amount: e.value
                    .map((v) => v.amount)
                    .fold<double>(0, (a, b) => a + b),
                category: e.key))
            .toList();
      case BreakType.Category:
        return records.where((r) => r.category == section).toList();
    }
  }

  bool isYearSelectionEnabled() {
    return _reportType.value != ReportType.PendingExpenses &&
        _reportType.value != ReportType.ScheduledExpenses;
  }
}
