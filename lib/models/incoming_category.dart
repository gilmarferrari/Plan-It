class IncomingCategory {
  late int id;
  late String description;
  late bool isActive;

  static IncomingCategory fromJson(Map<String, dynamic> json) {
    var incomingCategory = IncomingCategory();

    incomingCategory.id = json['id'];
    incomingCategory.description = json['description'];
    incomingCategory.isActive = json['isActive'];

    return incomingCategory;
  }

  static Map<String, dynamic> toJson(IncomingCategory incomingCategory) {
    return {
      'id': incomingCategory.id,
      'description': incomingCategory.description,
      'isActive': incomingCategory.isActive
    };
  }

  @override
  String toString() {
    return description;
  }
}
