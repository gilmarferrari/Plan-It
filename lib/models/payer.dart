class Payer {
  late int id;
  late String description;
  late String? registrationNumber;
  late String? type;
  late bool isActive;

  static Payer fromJson(Map<String, dynamic> json) {
    var payer = Payer();

    payer.id = json['id'];
    payer.description = json['description'];
    payer.registrationNumber = json['registrationNumber'];
    payer.type = json['type'];
    payer.isActive = json['isActive'];

    return payer;
  }

  static Map<String, dynamic> toJson(Payer payer) {
    return {
      'id': payer.id,
      'description': payer.description,
      'registrationNumber': payer.registrationNumber,
      'type': payer.type,
      'isActive': payer.isActive
    };
  }

  static Payer empty({String description = 'Nenhuma'}) {
    var payer = Payer();

    payer.id = 0;
    payer.description = description;
    payer.registrationNumber = null;
    payer.type = null;
    payer.isActive = true;

    return payer;
  }

  @override
  String toString() {
    return description;
  }
}
