import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_category.dart';
import '../models/expense.dart';
import '../models/payment_type.dart';
import '../services/local_database.dart';
import 'custom_button.dart';
import 'custom_detailed_button.dart';
import 'custom_dropdown.dart';
import 'custom_form_field.dart';

class EditExpenseBottomSheet extends StatefulWidget {
  final Expense? expense;
  final void Function(int, int, DateTime, DateTime?, String?, double) onConfirm;

  const EditExpenseBottomSheet(
      {super.key, required this.onConfirm, this.expense});

  @override
  State<EditExpenseBottomSheet> createState() => _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState extends State<EditExpenseBottomSheet> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.expense?.description);
  late DateTime _entryDate = widget.expense?.entryDate ?? DateTime.now();
  late DateTime? _paymentDate = widget.expense?.paymentDate;
  late final TextEditingController _amountController = TextEditingController(
      text: widget.expense != null && widget.expense!.amount > 0
          ? widget.expense!.amount.toStringAsFixed(2)
          : '');
  late BudgetCategory? _budgetCategory = widget.expense?.budgetCategory;
  late PaymentType? _paymentType = widget.expense?.paymentType;

  @override
  void initState() {
    super.initState();
    _future = getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<BudgetCategory> budgetCategories =
                snapshot.data[0] ?? [].cast<BudgetCategory>();
            List<PaymentType> paymentTypes =
                snapshot.data[1] ?? [].cast<PaymentType>();

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: 515,
                child: Column(children: [
                  CustomFormField(
                      label: 'Descrição',
                      controller: _descriptionController,
                      displayFloatingLabel: true,
                      icon: Icons.edit_note),
                  CustomDropdown(
                    title: 'Catergoria',
                    icon: Icons.account_tree,
                    iconColor: Colors.black54,
                    value:
                        budgetCategories.any((c) => c.id == _budgetCategory?.id)
                            ? budgetCategories
                                .firstWhere((c) => c.id == _budgetCategory?.id)
                            : null,
                    options: budgetCategories,
                    onChanged: (dynamic category) {
                      setState(() {
                        _budgetCategory = category;
                      });
                    },
                  ),
                  CustomDropdown(
                    title: 'Tipo de Pagamento',
                    icon: Icons.credit_card,
                    iconColor: Colors.black54,
                    value: paymentTypes.any((t) => t.id == _paymentType?.id)
                        ? paymentTypes
                            .firstWhere((t) => t.id == _paymentType?.id)
                        : null,
                    options: paymentTypes,
                    onChanged: (dynamic type) {
                      setState(() {
                        _paymentType = type;
                      });
                    },
                  ),
                  CustomDetailedButton(
                      icon: Icons.calendar_month,
                      label: DateFormat('dd/MM/yyyy').format(_entryDate),
                      description: 'Data de entrada',
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black54,
                      onPress: () => selectEntryDate(context)),
                  CustomDetailedButton(
                      icon: Icons.calendar_month,
                      label: _paymentDate != null
                          ? DateFormat('dd/MM/yyyy').format(_paymentDate!)
                          : 'Selecione uma data',
                      description: 'Data de pagamento',
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black54,
                      onPress: () => selectPaymentDate(context)),
                  CustomFormField(
                      label: 'Valor',
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      displayFloatingLabel: true,
                      icon: Icons.attach_money),
                  CustomButton(
                      label: 'Salvar',
                      onSubmit: () => save(context),
                      height: 15),
                ]),
              ),
            );
          } else {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  Future<List<List<dynamic>>> getInitialData() async {
    return [
      await _localDatabase.getBudgetCategories(activeOnly: true),
      await _localDatabase.getPaymentTypes(activeOnly: true)
    ];
  }

  selectEntryDate(BuildContext context) async {
    var date = await showDatePicker(
        locale: const Locale("pt", "BR"),
        context: context,
        initialDate: _entryDate,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31));

    if (date != null) {
      setState(() => _entryDate = date);
    }
  }

  selectPaymentDate(BuildContext context) async {
    var date = await showDatePicker(
        locale: const Locale("pt", "BR"),
        context: context,
        initialDate: _entryDate,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31));

    if (date != null) {
      setState(() => _paymentDate = date);
    }
  }

  save(BuildContext context) {
    var description = _descriptionController.value.text;
    var amount = double.tryParse(_amountController.value.text);

    if (amount == null ||
        amount <= 0 ||
        _budgetCategory == null ||
        _paymentType == null) {
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(_budgetCategory!.id, _paymentType!.id, _entryDate,
        _paymentDate, description, amount);
  }
}
