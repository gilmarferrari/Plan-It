import 'budget_category.dart';

class ExpenseCategoryAmountDTO {
  BudgetCategory budgetCategory;
  double amount;

  ExpenseCategoryAmountDTO(
      {required this.budgetCategory, required this.amount});

  @override
  String toString() {
    return budgetCategory.description;
  }
}
