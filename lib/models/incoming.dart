import 'incoming_category.dart';
import 'payer.dart';

class Incoming {
  late int id;
  late DateTime entryDate;
  late double grossAmount;
  late double discounts;
  late IncomingCategory incomingCategory;
  late Payer? payer;

  static Incoming fromJson(Map<String, dynamic> json) {
    var incoming = Incoming();

    incoming.id = json['id'];
    incoming.entryDate = DateTime.parse(json['entryDate']);
    incoming.grossAmount = json['grossAmount'];
    incoming.discounts = json['discounts'];
    incoming.incomingCategory =
        IncomingCategory.fromJson(json['incomingCategory']);
    incoming.payer =
        json['payer'] != null ? Payer.fromJson(json['payer']) : null;

    return incoming;
  }
}
