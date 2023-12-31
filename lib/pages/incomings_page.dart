import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/custom_list_month_header.dart';
import '../components/custom_search_field.dart';
import '../components/edit_incoming_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/incoming.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';

class IncomingsPage extends StatefulWidget {
  const IncomingsPage({super.key});

  @override
  State<IncomingsPage> createState() => _IncomingsPageState();
}

class _IncomingsPageState extends State<IncomingsPage> {
  late Future<List<Incoming>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getIncomings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<Incoming> incomings = snapshot.data ?? [].cast<Incoming>();
            incomings.sort((a, b) => a.entryDate.isAfter(b.entryDate) ? -1 : 1);

            incomings = incomings
                .where((e) => (_searchTerm == null ||
                    ('${e.payer?.description}')
                        .toLowerCase()
                        .contains(_searchTerm!) ||
                    e.incomingCategory.description
                        .toLowerCase()
                        .contains(_searchTerm!)))
                .toList();

            var months = incomings
                .map((i) => DateFormat('MMMM/yyyy', 'pt').format(i.entryDate))
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
                        'RENDIMENTOS',
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
              floatingActionButton: FloatingActionButton(
                  backgroundColor: AppConstants.primaryColor,
                  onPressed: () => addIncoming(context),
                  child: const Icon(Icons.add)),
              body: ListView.builder(
                  key: PageStorageKey(widget.key),
                  itemCount: months.length,
                  itemBuilder: (ctx, index) {
                    var month = months[index];
                    var monthIncomings = incomings
                        .where((i) =>
                            DateFormat('MMMM/yyyy', 'pt').format(i.entryDate) ==
                            month)
                        .toList();

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomListMonthHeader(
                            month: month,
                            amount: monthIncomings
                                .map((i) => i.grossAmount)
                                .fold<double>(0, (a, b) => a + b),
                          ),
                          ...monthIncomings.map((incoming) => CustomCard(
                                  label: incoming.incomingCategory.description,
                                  description:
                                      'Valor Bruto: ${NumberFormat.simpleCurrency(locale: 'pt').format(incoming.grossAmount)}',
                                  icon: Icons.account_balance_wallet,
                                  iconColor:
                                      const Color.fromRGBO(0, 155, 114, 1),
                                  onTap: () => editIncoming(context, incoming),
                                  options: [
                                    BottomSheetAction(
                                        label: 'Editar',
                                        icon: Icons.edit,
                                        onPressed: () =>
                                            editIncoming(context, incoming)),
                                    BottomSheetAction(
                                        label: 'Excluir',
                                        icon: Icons.delete,
                                        onPressed: () =>
                                            deleteIncoming(context, incoming)),
                                  ]))
                        ]);
                  }),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Incoming>> getIncomings() async {
    return await _localDatabase.getIncomings();
  }

  addIncoming(BuildContext context) {
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
          return EditIncomingBottomSheet(onConfirm: (int incomingCategoryID,
              int? payerID,
              DateTime entryDate,
              double grossAmount,
              double discounts) async {
            setState(() => _isLoading = true);

            await _localDatabase.createIncoming(
                grossAmount: grossAmount,
                discounts: discounts,
                entryDate: entryDate,
                incomingCategoryID: incomingCategoryID,
                payerID: payerID);

            _future = getIncomings();

            setState(() => _isLoading = false);
          });
        });
  }

  editIncoming(BuildContext context, Incoming incoming) {
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
          return EditIncomingBottomSheet(
              incoming: incoming,
              onConfirm: (int incomingCategoryID,
                  int? payerID,
                  DateTime entryDate,
                  double grossAmount,
                  double discounts) async {
                setState(() => _isLoading = true);

                await _localDatabase.updateIncoming(
                    id: incoming.id,
                    grossAmount: grossAmount,
                    discounts: discounts,
                    entryDate: entryDate,
                    incomingCategoryID: incomingCategoryID,
                    payerID: payerID);

                _future = getIncomings();

                setState(() => _isLoading = false);
              });
        });
  }

  deleteIncoming(BuildContext context, Incoming incoming) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente excluir o rendimento "${incoming.incomingCategory.description}"?',
              description:
                  'Esta exclusão somente será realizada caso não haja nenhum registro ligado a este.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                await _localDatabase.deleteIncoming(id: incoming.id);

                _future = getIncomings();

                setState(() => _isLoading = false);
              });
        });
  }
}
