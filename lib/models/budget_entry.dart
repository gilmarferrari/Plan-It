import 'budget_category.dart';

class BudgetEntry {
  late int id;
  late double amount;
  late DateTime entryDate;
  late BudgetCategory budgetCategory;

  static BudgetEntry fromJson(Map<String, dynamic> json) {
    var budgetEntry = BudgetEntry();

    budgetEntry.id = json['id'];
    budgetEntry.amount = json['amount'];
    budgetEntry.entryDate = DateTime.parse(json['entryDate']);
    budgetEntry.budgetCategory =
        BudgetCategory.fromJson(json['budgetCategory']);

    return budgetEntry;
  }
}
