import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incoming.dart';
import '../models/incoming_category.dart';
import '../models/payer.dart';
import '../services/local_database.dart';
import 'custom_button.dart';
import 'custom_detailed_button.dart';
import 'custom_dropdown.dart';
import 'custom_form_field.dart';

class EditIncomingBottomSheet extends StatefulWidget {
  final Incoming? incoming;
  final void Function(int, int?, DateTime, double, double) onConfirm;

  const EditIncomingBottomSheet(
      {super.key, required this.onConfirm, this.incoming});

  @override
  State<EditIncomingBottomSheet> createState() =>
      _EditIncomingBottomSheetState();
}

class _EditIncomingBottomSheetState extends State<EditIncomingBottomSheet> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  late DateTime _entryDate = widget.incoming?.entryDate ?? DateTime.now();
  late final TextEditingController _grossAmountController =
      TextEditingController(
          text: widget.incoming != null && widget.incoming!.grossAmount > 0
              ? widget.incoming!.grossAmount.toStringAsFixed(2)
              : '');
  late final TextEditingController _discountsController = TextEditingController(
      text: widget.incoming != null
          ? widget.incoming!.discounts.toStringAsFixed(2)
          : '');
  late IncomingCategory? _incomingCategory = widget.incoming?.incomingCategory;
  late Payer? _payer = widget.incoming?.payer;

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
            List<IncomingCategory> incomingCategories =
                snapshot.data[0] ?? [].cast<IncomingCategory>();
            List<Payer> payers = snapshot.data[1] ?? [].cast<Payer>();

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: 435,
                child: Column(children: [
                  CustomDropdown(
                    title: 'Categoria',
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.black54,
                    value: incomingCategories
                            .any((c) => c.id == _incomingCategory?.id)
                        ? incomingCategories
                            .firstWhere((c) => c.id == _incomingCategory?.id)
                        : null,
                    options: incomingCategories,
                    onChanged: (dynamic category) {
                      setState(() {
                        _incomingCategory = category;
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
                  CustomFormField(
                      label: 'Valor Bruto',
                      controller: _grossAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      displayFloatingLabel: true,
                      icon: Icons.attach_money),
                  CustomFormField(
                      label: 'Descontos',
                      controller: _discountsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      displayFloatingLabel: true,
                      icon: Icons.discount),
                  CustomDropdown(
                    title: 'Fonte Pagadora (opcional)',
                    icon: Icons.apartment,
                    iconColor: Colors.black54,
                    value: payers.any((c) => c.id == _payer?.id)
                        ? payers.firstWhere((c) => c.id == _payer?.id)
                        : null,
                    options: [Payer.empty(), ...payers],
                    onChanged: (dynamic payer) {
                      setState(() {
                        _payer = payer;
                      });
                    },
                  ),
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
      await _localDatabase.getIncomingCategories(activeOnly: true),
      await _localDatabase.getPayers(activeOnly: true)
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

  save(BuildContext context) {
    var grossAmount = double.tryParse(_grossAmountController.value.text);
    var discounts = double.tryParse(_discountsController.value.text) ?? 0;

    if (grossAmount == null ||
        grossAmount <= 0 ||
        discounts < 0 ||
        _incomingCategory == null) {
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(
        _incomingCategory!.id, _payer?.id, _entryDate, grossAmount, discounts);
  }
}
