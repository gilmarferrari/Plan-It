class BudgetCategory {
  late int id;
  late String description;
  late bool isActive;

  static BudgetCategory fromJson(Map<String, dynamic> json) {
    var budgetCategory = BudgetCategory();

    budgetCategory.id = json['id'];
    budgetCategory.description = json['description'];
    budgetCategory.isActive = json['isActive'];

    return budgetCategory;
  }

  static Map<String, dynamic> toJson(BudgetCategory budgetCategory) {
    return {
      'id': budgetCategory.id,
      'description': budgetCategory.description,
      'isActive': budgetCategory.isActive
    };
  }

  @override
  String toString() {
    return description;
  }
}
