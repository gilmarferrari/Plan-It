import 'package:flutter/material.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/edit_payment_type_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/payment_type.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';

class PaymentTypesPage extends StatefulWidget {
  const PaymentTypesPage({super.key});

  @override
  State<PaymentTypesPage> createState() => _PaymentTypesPageState();
}

class _PaymentTypesPageState extends State<PaymentTypesPage> {
  late Future<List<PaymentType>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _future = getPaymentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<PaymentType> paymentTypes =
                snapshot.data ?? [].cast<PaymentType>();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'TIPOS DE PAGAMENTO',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: AppConstants.primaryColor,
                  onPressed: () => addPaymentType(context),
                  child: const Icon(Icons.add)),
              body: ListView.builder(
                  key: PageStorageKey(widget.key),
                  itemCount: paymentTypes.length,
                  itemBuilder: (ctx, index) {
                    var paymentType = paymentTypes[index];

                    return CustomCard(
                      label: paymentType.description,
                      description: 'Tipo de Pagamento',
                      icon: Icons.credit_card,
                      options: [
                        BottomSheetAction(
                            label: 'Editar',
                            icon: Icons.edit,
                            onPressed: () =>
                                editPaymentType(context, paymentType)),
                        BottomSheetAction(
                            label: 'Excluir',
                            icon: Icons.delete,
                            onPressed: () =>
                                deletePaymentType(context, paymentType)),
                      ],
                    );
                  }),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<PaymentType>> getPaymentTypes() async {
    return await _localDatabase.getPaymentTypes();
  }

  addPaymentType(BuildContext context) {
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
          return EditPaymentTypeBottomSheet(
              onConfirm: (String description, bool isActive) async {
            setState(() => _isLoading = true);

            await _localDatabase.createPaymentType(description: description);

            _future = getPaymentTypes();

            setState(() => _isLoading = false);
          });
        });
  }

  editPaymentType(BuildContext context, PaymentType paymentType) {
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
          return EditPaymentTypeBottomSheet(
              paymentType: paymentType,
              onConfirm: (String description, bool isActive) async {
                setState(() => _isLoading = true);

                await _localDatabase.updatePaymentType(
                    id: paymentType.id,
                    description: description,
                    isActive: isActive);

                _future = getPaymentTypes();

                setState(() => _isLoading = false);
              });
        });
  }

  deletePaymentType(BuildContext context, PaymentType paymentType) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente excluir o tipo de pagamento "${paymentType.description}"?',
              description:
                  'Esta exclusão somente será realizada caso não haja nenhum registro ligado a este.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                await _localDatabase.deletePaymentType(id: paymentType.id);

                _future = getPaymentTypes();

                setState(() => _isLoading = false);
              });
        });
  }
}
