class SQLTable {
  String name;
  late String description;
  bool isSelected = true;
  List<Map<String, dynamic>>? data;

  SQLTable({required this.name, this.data}) {
    description = getDescription();
  }

  getDescription() {
    switch (name) {
      case 'BudgetCategories':
        return 'Categorias de Orçamento';
      case 'IncomingCategories':
        return 'Categorias de Rendimento';
      case 'Payers':
        return 'Fontes Pagadoras';
      case 'PaymentTypes':
        return 'Tipos de Pagamento';
      case 'BudgetEntries':
        return 'Orçamentos';
      case 'Expenses':
        return 'Despesas';
      case 'Incomings':
        return 'Rendimentos';
      default:
        return name;
    }
  }

  @override
  String toString() {
    return name;
  }
}
