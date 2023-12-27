import 'package:flutter/material.dart';
import '../models/payment_type.dart';
import 'custom_button.dart';
import 'custom_form_field.dart';

class EditPaymentTypeBottomSheet extends StatefulWidget {
  final PaymentType? paymentType;
  final void Function(String, bool) onConfirm;

  const EditPaymentTypeBottomSheet(
      {super.key, required this.onConfirm, this.paymentType});

  @override
  State<EditPaymentTypeBottomSheet> createState() =>
      _EditPaymentTypeBottomSheetState();
}

class _EditPaymentTypeBottomSheetState
    extends State<EditPaymentTypeBottomSheet> {
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.paymentType?.description);
  late bool _isActive = widget.paymentType?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 190,
        child: Column(children: [
          CustomFormField(
              label: 'Descrição',
              controller: _descriptionController,
              displayFloatingLabel: true,
              icon: Icons.edit_note),
          Container(
              margin: const EdgeInsets.only(left: 5),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Checkbox(
                  value: _isActive,
                  side: const BorderSide(color: Colors.black54, width: 2),
                  onChanged: widget.paymentType?.isActive != null
                      ? (bool? checked) {
                          setState(() => _isActive = checked ?? false);
                        }
                      : null,
                ),
                const Text('Ativo')
              ])),
          CustomButton(
              label: 'Salvar', onSubmit: () => save(context), height: 15),
        ]),
      ),
    );
  }

  save(BuildContext context) {
    var description = _descriptionController.value.text;

    if (description.isEmpty) {
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(description, _isActive);
  }
}
