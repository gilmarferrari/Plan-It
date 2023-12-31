import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_list_month_header.dart';
import '../components/custom_search_field.dart';
import '../components/edit_budget_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/budget_category.dart';
import '../models/budget_entry.dart';
import '../services/local_database.dart';
import '../view_models/bottom_sheet_action.dart';
import '../view_models/month.dart';
import '../utils/app_constants.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  final List<int> _years = [
    for (int i = 2020; i <= DateTime.now().year + 1; i++) i
  ];
  int _year = DateTime.now().year;
  final List<Month> _months = [
    Month(description: 'Janeiro', value: 1),
    Month(description: 'Fevereiro', value: 2),
    Month(description: 'Março', value: 3),
    Month(description: 'Abril', value: 4),
    Month(description: 'Maio', value: 5),
    Month(description: 'Junho', value: 6),
    Month(description: 'Julho', value: 7),
    Month(description: 'Agosto', value: 8),
    Month(description: 'Setembro', value: 9),
    Month(description: 'Outubro', value: 10),
    Month(description: 'Novembro', value: 11),
    Month(description: 'Dezembro', value: 12),
  ];
  bool _isLoading = false;
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getBudgetEntries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<BudgetCategory> budgetCategories =
                snapshot.data[0] ?? [].cast<BudgetCategory>();
            List<BudgetEntry> budgetEntries =
                snapshot.data[1] ?? [].cast<BudgetEntry>();

            budgetCategories = budgetCategories
                .where((c) => (_searchTerm == null ||
                    c.description.toLowerCase().contains(_searchTerm!)))
                .toList();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: _isSearchMode
                    ? CustomSearchField(
                        initialText: _searchTerm,
                        onChanged: (String searchTerm) {
                          setState(
                              () => _searchTerm = searchTerm.toLowerCase());
                        })
                    : const Text(
                        'ORÇAMENTOS',
                        style: TextStyle(fontSize: 14),
                      ),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() => _isSearchMode = !_isSearchMode);

                        if (!_isSearchMode) {
                          setState(() => _searchTerm = null);
                        }
                      },
                      splashRadius: 20,
                      icon: Icon(
                        _isSearchMode ? Icons.close : Icons.search,
                        size: 20,
                      ))
                ],
              ),
              body: Column(
                children: [
                  Card(
                    color: AppConstants.primaryColor,
                    margin: const EdgeInsets.all(5),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL ORÇADO',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          Text(
                            NumberFormat.simpleCurrency(locale: 'pt').format(
                                budgetEntries
                                    .map((i) => i.amount)
                                    .fold<double>(0, (a, b) => a + b)),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  CustomDropdown(
                    icon: Icons.calendar_month,
                    value: _year,
                    options: _years,
                    prefix: 'Orçamento',
                    backgroundColor: Colors.white,
                    onChanged: (dynamic year) {
                      setState(() {
                        _year = year;
                        _future = getBudgetEntries();
                      });
                    },
                  ),
                  Flexible(
                    child: ListView.builder(
                        key: PageStorageKey(widget.key),
                        itemCount: _months.length,
                        itemBuilder: (ctx, index) {
                          var month = _months[index];
                          var monthBudgeted = budgetEntries
                              .where((b) =>
                                  b.entryDate.year == _year &&
                                  b.entryDate.month == month.value)
                              .map((b) => b.amount)
                              .fold<double>(0, (a, b) => a + b);

                          return Column(children: [
                            CustomListMonthHeader(
                              month: month.description,
                              amount: monthBudgeted,
                            ),
                            ...budgetCategories.map((budgetCategory) {
                              var budgetedAmount = budgetEntries
                                  .where((e) =>
                                      e.budgetCategory.id ==
                                          budgetCategory.id &&
                                      e.entryDate.month == month.value)
                                  .map((e) => e.amount)
                                  .fold<double>(0, (a, b) => a + b);

                              return CustomCard(
                                label: budgetCategory.description,
                                description:
                                    'Orçado: ${NumberFormat.simpleCurrency(locale: 'pt').format(budgetedAmount)}',
                                icon: Icons.attach_money,
                                onTap: () => editBudget(context, budgetCategory,
                                    month, budgetedAmount),
                                options: budgetedAmount > 0
                                    ? [
                                        BottomSheetAction(
                                            label: 'Editar',
                                            icon: Icons.edit,
                                            onPressed: () => editBudget(
                                                context,
                                                budgetCategory,
                                                month,
                                                budgetedAmount)),
                                        BottomSheetAction(
                                            label: 'Reiniciar',
                                            icon: Icons.restart_alt,
                                            onPressed: () => restartBudget(
                                                context,
                                                budgetCategory,
                                                month)),
                                      ]
                                    : [
                                        BottomSheetAction(
                                            label: 'Editar',
                                            icon: Icons.edit,
                                            onPressed: () => editBudget(
                                                context,
                                                budgetCategory,
                                                month,
                                                budgetedAmount)),
                                      ],
                              );
                            })
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

  Future<List<List<dynamic>>> getBudgetEntries() async {
    return [
      await _localDatabase.getBudgetCategories(activeOnly: true),
      await _localDatabase.getBudgetEntries(year: _year)
    ];
  }

  editBudget(BuildContext context, BudgetCategory category, Month month,
      double amount) {
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
          return EditBudgetBottomSheet(
              budgetCategory: category,
              year: _year,
              month: month,
              amount: amount,
              onConfirm: (double amount, int budgetCategoryID) async {
                setState(() => _isLoading = true);
                var budgetEntry = await _localDatabase.getBudgetEntry(
                    year: _year,
                    month: month.value,
                    budgetCategoryID: budgetCategoryID);

                if (budgetEntry != null) {
                  await _localDatabase.updateBudgetEntry(
                      id: budgetEntry.id, amount: amount);
                } else {
                  await _localDatabase.createBudgetEntry(
                      amount: amount,
                      entryDate: DateTime(_year, month.value, 1),
                      budgetCategoryID: budgetCategoryID);
                }

                _future = getBudgetEntries();

                setState(() => _isLoading = false);
              });
        });
  }

  restartBudget(BuildContext context, BudgetCategory category, Month month) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente limpar o valor orçado da categoria "${category.description}" no período ${month.description}/${_year}?',
              description:
                  'Esta ação será definitiva e não poderá ser revertida.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                await _localDatabase.deleteBudgetEntries(
                    year: _year,
                    month: month.value,
                    budgetCategoryID: category.id);

                _future = getBudgetEntries();

                setState(() => _isLoading = false);
              });
        });
  }
}
