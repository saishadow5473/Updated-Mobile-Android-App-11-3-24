class PrescriptionModel {
  String drugName;
  String quantity;
  String medNote;
  String days;
  String directionOfUse;
  String sig;

  PrescriptionModel({
    this.drugName,
    this.quantity,
    this.medNote,
    this.days,
    this.directionOfUse,
    this.sig,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      drugName: json['drug_name'] ?? "",
      quantity: json['quantity'] ?? "",
      medNote: json['med_note'] ?? "",
      days: json['days'] ?? "",
      directionOfUse: json['direction_of_use'] ?? "",
      sig: json['SIG'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug_name': drugName,
      'quantity': quantity,
      'med_note': medNote,
      'days': days,
      'direction_of_use': directionOfUse,
      'SIG': sig,
    };
  }
}
