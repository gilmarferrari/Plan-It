import 'dart:io';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../components/app_update_dialog.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_pie_chart.dart';
import '../components/import_export_data_bottom_sheet.dart';
import '../components/custom_bar_chart.dart';
import '../components/custom_drawer_button.dart';
import '../components/loading_container.dart';
import '../models/budget_entry.dart';
import '../models/expense.dart';
import '../models/expense_category_amount_dto.dart';
import '../models/incoming.dart';
import '../services/app_versions_service.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/extensions.dart';
import '../utils/local_storage.dart';
import 'tutorial_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<dynamic> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  final AppVersionsService _appVersionsService = AppVersionsService();
  final List<int> _years = [
    for (int i = 2020; i <= DateTime.now().year + 1; i++) i
  ];
  int _incomingsExpensesComparisonYear = DateTime.now().year;
  int _budgetExpensesComparisonYear = DateTime.now().year;
  int _topExpensesPaymentTypesYear = DateTime.now().year;
  int _topExpensesCategoriesYear = DateTime.now().year;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = getDashboardData();

    Future.delayed(const Duration(seconds: 1), () {
      showTutorial();
      checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<Incoming> incomings = snapshot.data[0] ?? [].cast<Incoming>();
            List<Expense> expenses = snapshot.data[1] ?? [].cast<Expense>();
            List<BudgetEntry> budgetEntries =
                snapshot.data[2] ?? [].cast<BudgetEntry>();
            int currentYear = DateTime.now().year;

            List<Incoming> lastFiveYearsIncomings = incomings
                .where((i) =>
                    i.entryDate.year > (currentYear - 3) &&
                    i.entryDate.year <= currentYear)
                .toList();

            List<Expense> lastFiveYearsExpenses = expenses
                .where((e) =>
                    e.entryDate.year > (currentYear - 3) &&
                    e.entryDate.year <= currentYear)
                .toList();

            var topExpensesPaymentTypes = expenses
                .where((e) =>
                    (e.paymentDate != null &&
                                e.paymentDate!.isBefore(e.entryDate)
                            ? e.paymentDate!
                            : e.entryDate)
                        .year ==
                    _topExpensesPaymentTypesYear)
                .map((e) => e.paymentType)
                .toList();

            var topExpensesCategories = expenses
                .where((e) =>
                    (e.paymentDate != null &&
                                e.paymentDate!.isBefore(e.entryDate)
                            ? e.paymentDate!
                            : e.entryDate)
                        .year ==
                    _topExpensesCategoriesYear)
                .map((e) => ExpenseCategoryAmountDTO(
                    budgetCategory: e.budgetCategory, amount: e.amount))
                .toList();

            return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: const Text(
                    'PLAN IT',
                    style: TextStyle(fontSize: 14),
                  ),
                  bottom: TabBar(
                      indicatorColor: Colors.white,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Comparativo'),
                        Tab(text: 'Rendimentos'),
                        Tab(text: 'Despesas'),
                      ]),
                ),
                drawer: Drawer(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Column(children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(15, 55, 25, 30),
                          color: AppConstants.primaryColor,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 10, 5, 15),
                                  child: const Icon(
                                    Icons.person_pin_rounded,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                                const Text(
                                  'Olá, usuário',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )
                              ]),
                        ),
                        Divider(color: Colors.grey[50]),
                        CustomDrawerButton(
                            label: 'Categorias',
                            icon: const Icon(Icons.account_tree, size: 22),
                            color: Colors.grey[800],
                            onPressed: goToCategories),
                        CustomDrawerButton(
                            label: 'Tipos de Pagamento',
                            icon: const Icon(Icons.credit_card, size: 22),
                            color: Colors.grey[800],
                            onPressed: goToPaymentTypes),
                        CustomDrawerButton(
                            label: 'Fontes Pagadoras',
                            icon: const Icon(Icons.apartment, size: 22),
                            color: Colors.grey[800],
                            onPressed: goToPayers),
                        const Divider(indent: 20, endIndent: 20),
                        CustomDrawerButton(
                            label: 'Transações',
                            icon: const Icon(Icons.timeline, size: 22),
                            color: Colors.grey[800],
                            onPressed: goToTransactions),
                        CustomDrawerButton(
                            label: 'Relatórios',
                            icon: const Icon(Icons.bar_chart, size: 22),
                            color: Colors.grey[800],
                            onPressed: goToReports),
                        const Divider(indent: 20, endIndent: 20),
                        CustomDrawerButton(
                            label: 'Importar Dados',
                            icon: const Icon(Icons.cloud_upload, size: 22),
                            color: Colors.grey[800],
                            onPressed: () => importData(context)),
                        CustomDrawerButton(
                            label: 'Exportar Dados',
                            icon: const Icon(Icons.file_download_outlined,
                                size: 22),
                            color: Colors.grey[800],
                            onPressed: () => exportData(context)),
                      ])
                    ])),
                floatingActionButtonLocation: ExpandableFab.location,
                floatingActionButton: ExpandableFab(
                  type: ExpandableFabType.up,
                  distance: 60,
                  openButtonBuilder: RotateFloatingActionButtonBuilder(
                    backgroundColor: AppConstants.primaryColor,
                    child: const Icon(Icons.menu),
                    fabSize: ExpandableFabSize.regular,
                    shape: const CircleBorder(),
                  ),
                  closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                    backgroundColor: AppConstants.primaryColor,
                    child: const Icon(Icons.close),
                    fabSize: ExpandableFabSize.small,
                    shape: const CircleBorder(),
                  ),
                  children: [
                    FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppConstants.primaryColor,
                      label: Row(children: [
                        const Icon(Icons.local_mall),
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text('Despesas'))
                      ]),
                      onPressed: goToExpenses,
                    ),
                    FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppConstants.primaryColor,
                      label: Row(children: [
                        const Icon(Icons.attach_money),
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text('Orçamentos'))
                      ]),
                      onPressed: goToBudgets,
                    ),
                    FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: AppConstants.primaryColor,
                      label: Row(children: [
                        const Icon(Icons.account_balance_wallet),
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text('Rendimentos'))
                      ]),
                      onPressed: goToIncomings,
                    ),
                  ],
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    Tab(
                      height: double.infinity,
                      child: ListView(children: [
                        CustomPieChart(
                          title: 'Rendimentos x Despesas',
                          labelFormat:
                              NumberFormat.compactSimpleCurrency(locale: 'pt'),
                          records: [
                            OrdinalData(
                              color: const Color.fromRGBO(0, 155, 114, 1),
                              domain: 'Rendimentos',
                              measure: incomings
                                  .where((i) =>
                                      i.entryDate.year ==
                                      _incomingsExpensesComparisonYear)
                                  .map((i) => i.grossAmount - i.discounts)
                                  .fold<double>(0, (a, b) => a + b),
                            ),
                            OrdinalData(
                              color: const Color.fromRGBO(255, 152, 0, 1),
                              domain: 'Despesas',
                              measure: expenses
                                  .where((e) =>
                                      (e.paymentDate != null &&
                                                  e.paymentDate!
                                                      .isBefore(e.entryDate)
                                              ? e.paymentDate!
                                              : e.entryDate)
                                          .year ==
                                      _incomingsExpensesComparisonYear)
                                  .map((e) => e.amount)
                                  .fold<double>(0, (a, b) => a + b),
                            ),
                          ],
                          filter: CustomDropdown(
                            title: 'Ano de Referência',
                            icon: Icons.calendar_month,
                            value: _incomingsExpensesComparisonYear,
                            options: _years,
                            backgroundColor: Colors.grey[200],
                            onChanged: (dynamic year) {
                              setState(() =>
                                  _incomingsExpensesComparisonYear = year);
                            },
                          ),
                        ),
                        CustomPieChart(
                          title: 'Orçamento x Despesas',
                          labelFormat:
                              NumberFormat.compactSimpleCurrency(locale: 'pt'),
                          records: [
                            OrdinalData(
                              color: Colors.blueGrey,
                              domain: 'Orçamento',
                              measure: budgetEntries
                                  .where((i) =>
                                      i.entryDate.year ==
                                      _budgetExpensesComparisonYear)
                                  .map((e) => e.amount)
                                  .fold<double>(0, (a, b) => a + b),
                            ),
                            OrdinalData(
                              color: const Color.fromRGBO(255, 152, 0, 1),
                              domain: 'Despesas',
                              measure: expenses
                                  .where((e) =>
                                      (e.paymentDate != null &&
                                                  e.paymentDate!
                                                      .isBefore(e.entryDate)
                                              ? e.paymentDate!
                                              : e.entryDate)
                                          .year ==
                                      _budgetExpensesComparisonYear)
                                  .map((e) => e.amount)
                                  .fold<double>(0, (a, b) => a + b),
                            ),
                          ],
                          filter: CustomDropdown(
                            title: 'Ano de Referência',
                            icon: Icons.calendar_month,
                            value: _budgetExpensesComparisonYear,
                            options: _years,
                            backgroundColor: Colors.grey[200],
                            onChanged: (dynamic year) {
                              setState(
                                  () => _budgetExpensesComparisonYear = year);
                            },
                          ),
                        )
                      ]),
                    ),
                    Tab(
                      height: double.infinity,
                      child: ListView(children: [
                        CustomBarChart(
                          title: 'Rendimento Bruto por Ano',
                          subtitle: 'Últimos 3 anos',
                          color: const Color.fromRGBO(80, 160, 80, 1),
                          labelFormat:
                              NumberFormat.simpleCurrency(locale: 'pt'),
                          records: [
                            ...lastFiveYearsIncomings.map((i) => OrdinalData(
                                  domain: '${i.entryDate.year}',
                                  measure: incomings
                                      .where((x) =>
                                          x.entryDate.year == i.entryDate.year)
                                      .map((x) => x.grossAmount)
                                      .fold<double>(0, (a, b) => a + b),
                                ))
                          ],
                        ),
                        CustomBarChart(
                          title: 'Rendimento Líquido por Ano',
                          subtitle: 'Últimos 3 anos',
                          color: const Color.fromRGBO(0, 155, 114, 1),
                          labelFormat:
                              NumberFormat.simpleCurrency(locale: 'pt'),
                          records: [
                            ...lastFiveYearsIncomings.map((i) => OrdinalData(
                                  domain: '${i.entryDate.year}',
                                  measure: incomings
                                      .where((x) =>
                                          x.entryDate.year == i.entryDate.year)
                                      .map((x) => x.grossAmount - x.discounts)
                                      .fold<double>(0, (a, b) => a + b),
                                ))
                          ],
                        ),
                        CustomBarChart(
                          title: 'Descontos por Ano',
                          subtitle: 'Últimos 3 anos',
                          color: const Color.fromRGBO(242, 100, 48, 1),
                          labelFormat:
                              NumberFormat.simpleCurrency(locale: 'pt'),
                          records: [
                            ...lastFiveYearsIncomings.map((i) => OrdinalData(
                                  domain: '${i.entryDate.year}',
                                  measure: incomings
                                      .where((x) =>
                                          x.entryDate.year == i.entryDate.year)
                                      .map((x) => x.discounts)
                                      .fold<double>(0, (a, b) => a + b),
                                ))
                          ],
                        )
                      ]),
                    ),
                    Tab(
                      height: double.infinity,
                      child: ListView(children: [
                        CustomBarChart(
                          title: 'Despesas por Ano',
                          subtitle: 'Últimos 3 anos',
                          color: const Color.fromRGBO(255, 152, 0, 1),
                          labelFormat:
                              NumberFormat.simpleCurrency(locale: 'pt'),
                          records: [
                            ...lastFiveYearsExpenses.map((i) => OrdinalData(
                                  domain: '${i.entryDate.year}',
                                  measure: expenses
                                      .where((x) =>
                                          (x.paymentDate != null &&
                                                      x.paymentDate!
                                                          .isBefore(x.entryDate)
                                                  ? x.paymentDate!
                                                  : x.entryDate)
                                              .year ==
                                          i.entryDate.year)
                                      .map((x) => x.amount)
                                      .fold<double>(0, (a, b) => a + b),
                                ))
                          ],
                        ),
                        CustomBarChart(
                          title: 'Tipos de Pagamento',
                          subtitle: '5 mais utilizados',
                          labelFormat: NumberFormat.compact(locale: 'pt'),
                          color: Colors.purple[400],
                          vertical: false,
                          barLabelPosition: BarLabelPosition.inside,
                          barLabelAnchor: BarLabelAnchor.end,
                          suffix: '%',
                          records: [
                            ...Extensions.mostFrequent(
                                    topExpensesPaymentTypes, (e) => e.id, 5)
                                .entries
                                .map((t) => OrdinalData(
                                      domain: t.key.description,
                                      measure: ((t.value /
                                                  topExpensesPaymentTypes
                                                      .length) *
                                              100)
                                          .toDouble(),
                                    ))
                          ],
                          filter: CustomDropdown(
                            title: 'Ano de Referência',
                            icon: Icons.calendar_month,
                            value: _topExpensesPaymentTypesYear,
                            options: _years,
                            backgroundColor: Colors.grey[200],
                            onChanged: (dynamic year) {
                              setState(
                                  () => _topExpensesPaymentTypesYear = year);
                            },
                          ),
                        ),
                        CustomBarChart(
                          title: 'Custo por Categoria',
                          subtitle: '5 com maior custo',
                          labelFormat:
                              NumberFormat.compactSimpleCurrency(locale: 'pt'),
                          color: Colors.yellow[700],
                          vertical: false,
                          barLabelPosition: BarLabelPosition.auto,
                          barLabelAnchor: BarLabelAnchor.end,
                          records: [
                            ...Extensions.highestValue(
                                    topExpensesCategories,
                                    (e) => e.budgetCategory.id,
                                    (e) => e.amount,
                                    5)
                                .entries
                                .map((t) => OrdinalData(
                                      domain: t.key.budgetCategory.description,
                                      measure: t.value,
                                    ))
                          ],
                          filter: CustomDropdown(
                            title: 'Ano de Referência',
                            icon: Icons.calendar_month,
                            value: _topExpensesCategoriesYear,
                            options: _years,
                            backgroundColor: Colors.grey[200],
                            onChanged: (dynamic year) {
                              setState(() => _topExpensesCategoriesYear = year);
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],
                ));
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<dynamic> getDashboardData() async {
    return [
      await _localDatabase.getIncomings(paidOnly: true),
      await _localDatabase.getExpenses(paidOnly: true),
      await _localDatabase.getBudgetEntries()
    ];
  }

  onBack() {
    _future = getDashboardData();
    setState(() {});
  }

  goToBudgets() {
    Navigator.pushNamed(context, AppRoutes.BUDGETS).then((_) => onBack());
  }

  goToExpenses() {
    Navigator.pushNamed(context, AppRoutes.EXPENSES).then((_) => onBack());
  }

  goToIncomings() {
    Navigator.pushNamed(context, AppRoutes.INCOMINGS).then((_) => onBack());
  }

  goToCategories() {
    Navigator.pushNamed(context, AppRoutes.CATEGORIES);
  }

  goToPayers() {
    Navigator.pushNamed(context, AppRoutes.PAYERS);
  }

  goToPaymentTypes() {
    Navigator.pushNamed(context, AppRoutes.PAYMENT_TYPES);
  }

  goToTransactions() {
    Navigator.pushNamed(context, AppRoutes.TRANSACTIONS);
  }

  goToReports() {
    Navigator.pushNamed(context, AppRoutes.REPORTS);
  }

  exportData(BuildContext context) async {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (builder) {
          return const ImportExportDataBottomSheet(
            actionType: ActionType.ExportData,
          );
        });
  }

  importData(BuildContext context) async {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (builder) {
          return const ImportExportDataBottomSheet(
            actionType: ActionType.ImportData,
          );
        });
  }

  Future<void> showTutorial() async {
    await LocalStorage.getBool(AppConstants.isTutorialCompleteKey)
        .then((isTutorialComplete) {
      if (!isTutorialComplete) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const TutorialPage(),
                  )),
            );
          },
        );
      }
    });
  }

  checkForUpdates() async {
    if (Platform.isAndroid) {
      try {
        var packageInfo = await PackageInfo.fromPlatform();
        var currentVersionCode = int.parse(packageInfo.buildNumber);

        await _appVersionsService
            .getLatestAppVersion()
            .then((gitHubRelease) async {
          if ((gitHubRelease?.getApkAsset().getVersionCode() ?? 0) >
              currentVersionCode) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  child: AppUpdateDialog(
                    downloadUrl: '${gitHubRelease?.getApkAsset().downloadUrl}',
                    fileName: '${gitHubRelease?.getApkAsset().name}',
                    size: gitHubRelease?.getApkAsset().size ?? 0,
                  ),
                );
              },
            );
          }
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
}
