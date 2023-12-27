import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../components/import_export_data_bottom_sheet.dart';
import '../components/custom_bar_chart.dart';
import '../components/custom_drawer_button.dart';
import '../components/loading_container.dart';
import '../models/expense.dart';
import '../models/incoming.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<dynamic> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();

  @override
  void initState() {
    super.initState();
    _future = getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<Incoming> incomings = snapshot.data[0] ?? [].cast<Incoming>();
            List<Expense> expenses = snapshot.data[1] ?? [].cast<Expense>();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'PLAN IT',
                  style: TextStyle(fontSize: 14),
                ),
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
              body: ListView(children: [
                CustomBarChart(
                  title: 'Rendimento Bruto por Ano',
                  records: [
                    ...incomings.map((i) => OrdinalData(
                          domain: '${i.entryDate.year}',
                          measure: incomings
                              .where(
                                  (x) => x.entryDate.year == i.entryDate.year)
                              .map((x) => x.grossAmount)
                              .fold<double>(0, (a, b) => a + b),
                        ))
                  ],
                ),
                CustomBarChart(
                  title: 'Rendimento Líquido por Ano',
                  color: Colors.green,
                  records: [
                    ...incomings.map((i) => OrdinalData(
                          domain: '${i.entryDate.year}',
                          measure: incomings
                              .where(
                                  (x) => x.entryDate.year == i.entryDate.year)
                              .map((x) => x.grossAmount - x.discounts)
                              .fold<double>(0, (a, b) => a + b),
                        ))
                  ],
                ),
                CustomBarChart(
                  title: 'Rendimento x Despesas (${DateTime.now().year})',
                  color: Colors.orange[600],
                  records: [
                    OrdinalData(
                      domain: 'Rendimentos',
                      measure: incomings
                          .where((i) => i.entryDate.year == DateTime.now().year)
                          .map((i) => i.grossAmount - i.discounts)
                          .fold<double>(0, (a, b) => a + b),
                    ),
                    OrdinalData(
                      domain: 'Despesas',
                      measure: expenses
                          .where((e) =>
                              (e.paymentDate ?? e.entryDate).year ==
                              DateTime.now().year)
                          .map((e) => e.amount)
                          .fold<double>(0, (a, b) => a + b),
                    ),
                  ],
                )
              ]),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<dynamic> getDashboardData() async {
    return [
      await _localDatabase.getIncomings(paidOnly: true),
      await _localDatabase.getExpenses(paidOnly: true),
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
}
