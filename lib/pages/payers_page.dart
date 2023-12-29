import 'package:flutter/material.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/edit_payer_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/payer.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';
import '../view_models/payer_type.dart';

class PayersPage extends StatefulWidget {
  const PayersPage({super.key});

  @override
  State<PayersPage> createState() => _PayersPageState();
}

class _PayersPageState extends State<PayersPage> {
  late Future<List<Payer>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  final List<PayerType> _types = PayerType.getTypes();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _future = getPayers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<Payer> payers = snapshot.data ?? [].cast<Payer>();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'FONTES PAGADORAS',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: AppConstants.primaryColor,
                  onPressed: () => addPayer(context),
                  child: const Icon(Icons.add)),
              body: ListView.builder(
                  key: PageStorageKey(widget.key),
                  itemCount: payers.length,
                  itemBuilder: (ctx, index) {
                    var payer = payers[index];
                    var payerType = _types.any((t) => t.value == payer.type)
                        ? _types
                            .firstWhere((t) => t.value == payer.type)
                            .description
                        : '(${payer.type})';

                    return CustomCard(
                      label: payer.description,
                      description:
                          '${payer.registrationNumber ?? 'Sem Registro'} / $payerType',
                      icon: Icons.apartment,
                      options: [
                        BottomSheetAction(
                            label: 'Editar',
                            icon: Icons.edit,
                            onPressed: () => editPayer(context, payer)),
                        BottomSheetAction(
                            label: 'Excluir',
                            icon: Icons.delete,
                            onPressed: () => deletePayer(context, payer)),
                      ],
                    );
                  }),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Payer>> getPayers() async {
    return await _localDatabase.getPayers();
  }

  addPayer(BuildContext context) {
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
          return EditPayerBottomSheet(onConfirm: (String description,
              String? registrationNumber, String? type, bool isActive) async {
            setState(() => _isLoading = true);

            await _localDatabase.createPayer(
                description: description,
                registrationNumber: registrationNumber,
                type: type);

            _future = getPayers();

            setState(() => _isLoading = false);
          });
        });
  }

  editPayer(BuildContext context, Payer payer) {
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
          return EditPayerBottomSheet(
              payer: payer,
              onConfirm: (String description, String? registrationNumber,
                  String? type, bool isActive) async {
                setState(() => _isLoading = true);

                await _localDatabase.updatePayer(
                    id: payer.id,
                    description: description,
                    registrationNumber: registrationNumber,
                    type: type,
                    isActive: isActive);

                _future = getPayers();

                setState(() => _isLoading = false);
              });
        });
  }

  deletePayer(BuildContext context, Payer payer) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente excluir a fonte pagadora "${payer.description}"?',
              description:
                  'Esta exclusão somente será realizada caso não haja nenhum registro ligado a este.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                await _localDatabase.deletePayer(id: payer.id);

                _future = getPayers();

                setState(() => _isLoading = false);
              });
        });
  }
}
