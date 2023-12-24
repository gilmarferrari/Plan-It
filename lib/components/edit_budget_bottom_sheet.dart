import 'package:flutter/material.dart';
import '../models/budget_category.dart';
import '../view_models/month.dart';
import 'custom_button.dart';
import 'custom_form_field.dart';

class EditBudgetBottomSheet extends StatefulWidget {
  final BudgetCategory budgetCategory;
  final int year;
  final Month month;
  final double amount;
  final Function(double, int) onConfirm;

  const EditBudgetBottomSheet({
    super.key,
    required this.budgetCategory,
    required this.year,
    required this.month,
    required this.onConfirm,
    required this.amount,
  });

  @override
  State<EditBudgetBottomSheet> createState() => _EditBudgetBottomSheetState();
}

class _EditBudgetBottomSheetState extends State<EditBudgetBottomSheet> {
  late final TextEditingController _categoryController =
      TextEditingController(text: widget.budgetCategory.description);
  late final TextEditingController _amountController = TextEditingController(
      text: widget.amount > 0 ? widget.amount.toStringAsFixed(2) : '');
  late final TextEditingController _periodController =
      TextEditingController(text: '${widget.month.description}/${widget.year}');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 255,
        child: Column(children: [
          CustomFormField(
              label: 'Categoria',
              controller: _categoryController,
              icon: Icons.account_tree,
              displayFloatingLabel: true,
              enabled: false),
          CustomFormField(
              label: 'Período',
              controller: _periodController,
              icon: Icons.calendar_month,
              displayFloatingLabel: true,
              enabled: false),
          CustomFormField(
              label: 'Valor',
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              focusNode: _focusNode,
              displayFloatingLabel: true,
              icon: Icons.attach_money),
          CustomButton(
              label: 'Salvar', onSubmit: () => save(context), height: 15),
        ]),
      ),
    );
  }

  save(BuildContext context) {
    var amount = double.tryParse(_amountController.value.text);

    if (amount == null || amount <= 0) {
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(amount, widget.budgetCategory.id);
  }
}
