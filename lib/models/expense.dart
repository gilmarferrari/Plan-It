import 'budget_category.dart';
import 'payment_type.dart';

class Expense {
  late int id;
  late DateTime entryDate;
  late DateTime? paymentDate;
  late String? description;
  late double amount;
  late BudgetCategory budgetCategory;
  late PaymentType paymentType;

  static Expense fromJson(Map<String, dynamic> json) {
    var expense = Expense();

    expense.id = json['id'];
    expense.entryDate = DateTime.parse(json['entryDate']);
    expense.paymentDate = json['paymentDate'] != null
        ? DateTime.parse(json['paymentDate'])
        : null;
    expense.description = json['description'];
    expense.amount = json['amount'];
    expense.budgetCategory = BudgetCategory.fromJson(json['budgetCategory']);
    expense.paymentType = PaymentType.fromJson(json['paymentType']);

    return expense;
  }
}
