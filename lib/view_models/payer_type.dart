class PayerType {
  String description;
  String value;

  PayerType({required this.description, required this.value});

  static getTypes() {
    return [
      PayerType(description: 'Pessoa Física', value: 'PF'),
      PayerType(description: 'Pessoa Jurídica', value: 'PJ')
    ];
  }

  @override
  String toString() {
    return description;
  }
}
