import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/edit_expense_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/expense.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late Future<List<Expense>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _future = getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<Expense> expenses = snapshot.data ?? [].cast<Expense>();
            expenses.sort((a, b) => a.entryDate.isAfter(b.entryDate) ? -1 : 1);

            var months = expenses
                .map((i) => DateFormat('MMMM/yyyy', 'pt')
                    .format(i.entryDate))
                .toSet()
                .toList();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'DESPESAS',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: AppConstants.primaryColor,
                  onPressed: () => addExpense(context),
                  child: const Icon(Icons.add)),
              body: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (ctx, index) {
                    var month = months[index];
                    var monthExpenses = expenses
                        .where((incoming) =>
                            DateFormat('MMMM/yyyy', 'pt')
                                .format(incoming.entryDate) ==
                            month)
                        .toList();

                    monthExpenses.sort(
                        (a, b) => a.entryDate.isAfter(b.entryDate) ? -1 : 1);

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    month.toUpperCase(),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    NumberFormat.simpleCurrency(locale: 'pt')
                                        .format(monthExpenses
                                            .map((i) => i.amount)
                                            .fold<double>(0, (a, b) => a + b)),
                                    style: const TextStyle(fontSize: 11),
                                  )
                                ],
                              ),
                            ),
                          ),
                          ...monthExpenses.map((expense) => CustomCard(
                                  label: expense.budgetCategory.description,
                                  description:
                                      'Descrição: ${expense.description ?? 'Nenhuma'}\nValor: ${NumberFormat.simpleCurrency(locale: 'pt').format(expense.amount)}',
                                  icon: Icons.attach_money,
                                  options: [
                                    BottomSheetAction(
                                        label: 'Editar',
                                        icon: Icons.edit,
                                        onPressed: () =>
                                            editExpense(context, expense)),
                                    BottomSheetAction(
                                        label: 'Excluir',
                                        icon: Icons.delete,
                                        onPressed: () =>
                                            deleteExpense(context, expense)),
                                  ]))
                        ]);
                  }),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Expense>> getExpenses() async {
    return await _localDatabase.getExpenses();
  }

  addExpense(BuildContext context) {
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
          return EditExpenseBottomSheet(onConfirm: (int budgetCategoryID,
              int paymentTypeID,
              DateTime entryDate,
              DateTime? paymentDate,
              String? description,
              double amount) async {
            setState(() => _isLoading = true);

            await _localDatabase.createExpense(
                amount: amount,
                entryDate: entryDate,
                paymentDate: paymentDate,
                description: description,
                budgetCategoryID: budgetCategoryID,
                paymentTypeID: paymentTypeID);

            _future = getExpenses();

            setState(() => _isLoading = false);
          });
        });
  }

  editExpense(BuildContext context, Expense expense) {
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
          return EditExpenseBottomSheet(
              expense: expense,
              onConfirm: (int budgetCategoryID,
                  int paymentTypeID,
                  DateTime entryDate,
                  DateTime? paymentDate,
                  String? description,
                  double amount) async {
                setState(() => _isLoading = true);

                await _localDatabase.updateExpense(
                    id: expense.id,
                    amount: amount,
                    entryDate: entryDate,
                    paymentDate: paymentDate,
                    description: description,
                    budgetCategoryID: budgetCategoryID,
                    paymentTypeID: paymentTypeID);

                _future = getExpenses();

                setState(() => _isLoading = false);
              });
        });
  }

  deleteExpense(BuildContext context, Expense expense) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente excluir a despesa "${expense.budgetCategory.description}"?',
              description:
                  'Esta exclusão somente será realizada caso não haja nenhum registro ligado a este.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                await _localDatabase.deleteExpense(id: expense.id);

                _future = getExpenses();

                setState(() => _isLoading = false);
              });
        });
  }
}
