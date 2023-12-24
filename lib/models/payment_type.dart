class PaymentType {
  late int id;
  late String description;
  late bool isActive;

  static PaymentType fromJson(Map<String, dynamic> json) {
    var paymentType = PaymentType();

    paymentType.id = json['id'];
    paymentType.description = json['description'];
    paymentType.isActive = json['isActive'];

    return paymentType;
  }

  static Map<String, dynamic> toJson(PaymentType paymentType) {
    return {
      'id': paymentType.id,
      'description': paymentType.description,
      'isActive': paymentType.isActive
    };
  }

  @override
  String toString() {
    return description;
  }
}
