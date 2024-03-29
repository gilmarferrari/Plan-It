import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/transaction.dart';

class CustomTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final double elevation;

  const CustomTransactionCard(
      {super.key, required this.transaction, this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Card(
        elevation: elevation,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 15, 20, 15),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  getIcon(),
                  Container(
                    child: transaction.isFinished
                        ? Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 12,
                              ),
                            ))
                        : null,
                  )
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: size.width - 130,
                child: Text(
                  transaction.description,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: size.width - 130,
                child: Text(
                  NumberFormat.simpleCurrency(locale: 'pt')
                      .format(transaction.amount),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
          ]),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
              child: Text(
                DateFormat('dd')
                    .format((transaction.paymentDate ?? transaction.entryDate)),
                style: const TextStyle(fontSize: 12),
              ))
        ]));
  }

  Widget getIcon() {
    switch (transaction.type) {
      case TransactionType.Expense:
        return Container(
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
        );
      case TransactionType.Incoming:
        return Container(
            decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 155, 114, 1),
                borderRadius: BorderRadius.circular(50)),
            child:
                const Icon(Icons.arrow_drop_up_rounded, color: Colors.white));
      default:
        return const Icon(Icons.attach_money);
    }
  }
}
