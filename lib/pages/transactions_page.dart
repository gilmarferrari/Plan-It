import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_list_month_header.dart';
import '../components/custom_search_field.dart';
import '../components/custom_transaction_cart.dart';
import '../components/loading_container.dart';
import '../models/expense.dart';
import '../models/incoming.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/transaction.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<Expense> expenses = snapshot.data[0] ?? [].cast<Expense>();
            List<Incoming> incomings = snapshot.data[1] ?? [].cast<Incoming>();

            List<Transaction> transactions = [
              ...expenses.map((e) => Transaction(
                  entryDate: e.entryDate,
                  paymentDate: e.paymentDate,
                  amount: e.amount,
                  type: TransactionType.Expense,
                  description:
                      e.description != null && e.description!.isNotEmpty
                          ? e.description!
                          : e.budgetCategory.description)),
              ...incomings.map((i) => Transaction(
                  entryDate: i.entryDate,
                  amount: i.grossAmount - i.discounts,
                  type: TransactionType.Incoming,
                  description: i.incomingCategory.description))
            ]..sort((a, b) => (a.paymentDate ?? a.entryDate)
                    .isAfter((b.paymentDate ?? b.entryDate))
                ? -1
                : 1);

            transactions = transactions
                .where((t) => (_searchTerm == null ||
                    t.description.toLowerCase().contains(_searchTerm!)))
                .toList();

            var months = transactions
                .map((e) => DateFormat('MMMM/yyyy', 'pt')
                    .format((e.paymentDate ?? e.entryDate)))
                .toSet()
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
                        'TRANSAÇÕES',
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
                  Container(
                    child: !_isSearchMode
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
                                    'SALDO ATUAL',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                  Text(
                                    NumberFormat.simpleCurrency(locale: 'pt')
                                        .format(transactions
                                            .map((i) => i.type ==
                                                    TransactionType.Expense
                                                ? (i.amount * -1)
                                                : i.amount)
                                            .fold<double>(0, (a, b) => a + b)),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          )
                        : null,
                  ),
                  Flexible(
                    child: ListView.builder(
                        key: PageStorageKey(widget.key),
                        itemCount: months.length,
                        itemBuilder: (ctx, index) {
                          var month = months[index];
                          var monthTransactions = transactions
                              .where((e) =>
                                  DateFormat('MMMM/yyyy', 'pt')
                                      .format((e.paymentDate ?? e.entryDate)) ==
                                  month)
                              .toList();

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomListMonthHeader(
                                    month: month,
                                    amount: monthTransactions
                                        .map((i) =>
                                            i.type == TransactionType.Expense
                                                ? (i.amount * -1)
                                                : i.amount)
                                        .fold<double>(0, (a, b) => a + b)),
                                ...monthTransactions.map((t) =>
                                    CustomTransactionCard(transaction: t))
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

  Future<List<List<dynamic>>> getTransactions() async {
    return [
      await _localDatabase.getExpenses(),
      await _localDatabase.getIncomings()
    ];
  }
}
