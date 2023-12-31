// ignore_for_file: constant_identifier_names

class Transaction {
  DateTime entryDate;
  DateTime? paymentDate;
  double amount;
  TransactionType type;
  String description;
  late bool isFinished;

  Transaction({
    required this.entryDate,
    required this.amount,
    required this.type,
    required this.description,
    this.paymentDate,
  }) {
    isFinished = entryDate.isBefore(DateTime.now()) &&
        (type == TransactionType.Expense
            ? (paymentDate != null && paymentDate!.isBefore(DateTime.now()))
            : true);
  }

  String getTransactionType() {
    switch (type) {
      case TransactionType.Expense:
        return 'Débito';
      case TransactionType.Incoming:
        return 'Crédito';
      default:
        return '';
    }
  }
}

enum TransactionType {
  Expense,
  Incoming,
}
