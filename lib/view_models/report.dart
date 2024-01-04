// ignore_for_file: constant_identifier_names

class Report {
  String category;
  String? description;
  DateTime entryDate;
  double amount;
  BreakType breakType;

  Report({
    required this.category,
    required this.entryDate,
    required this.amount,
    required this.breakType,
    this.description,
  });
}

enum ReportType {
  Incomings,
  Expenses,
  PendingExpenses,
  ScheduledExpenses,
  Budgets,
}

enum BreakType {
  Category,
  Month,
}
