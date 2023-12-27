import 'package:flutter/material.dart';
import '../models/payer.dart';
import '../view_models/payer_type.dart';
import 'custom_button.dart';
import 'custom_dropdown.dart';
import 'custom_form_field.dart';

class EditPayerBottomSheet extends StatefulWidget {
  final Payer? payer;
  final void Function(String, String?, String?, bool) onConfirm;

  const EditPayerBottomSheet({super.key, required this.onConfirm, this.payer});

  @override
  State<EditPayerBottomSheet> createState() => _EditPayerBottomSheetState();
}

class _EditPayerBottomSheetState extends State<EditPayerBottomSheet> {
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.payer?.description);
  late final TextEditingController _registrationNumberController =
      TextEditingController(text: widget.payer?.registrationNumber);
  final List<PayerType> _types = PayerType.getTypes();
  late PayerType? _type = _types.any((t) => t.value == widget.payer?.type)
      ? _types.firstWhere((t) => t.value == widget.payer?.type)
      : null;
  late bool _isActive = widget.payer?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 340,
        child: Column(children: [
          CustomFormField(
              label: 'Descrição',
              controller: _descriptionController,
              displayFloatingLabel: true,
              icon: Icons.edit_note),
          CustomDropdown(
            icon: Icons.apartment,
            iconColor: Colors.black54,
            title: 'Categoria',
            value: _types.any((t) => t.value == _type?.value)
                ? _types.firstWhere((t) => t.value == _type?.value)
                : null,
            options: _types,
            onChanged: (dynamic type) {
              setState(() {
                _type = type;
              });
            },
          ),
          CustomFormField(
              label: 'CPF ou CPNJ',
              controller: _registrationNumberController,
              displayFloatingLabel: true,
              icon: Icons.badge),
          Container(
              margin: const EdgeInsets.only(left: 5),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Checkbox(
                  value: _isActive,
                  side: const BorderSide(color: Colors.black54, width: 2),
                  onChanged: widget.payer != null
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
    var registrationNumber = _registrationNumberController.value.text;

    if (description.isEmpty) {
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(description, registrationNumber, _type?.value, _isActive);
  }
}
