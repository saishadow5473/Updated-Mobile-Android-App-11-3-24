// To parse this JSON data, do
//
//     final invoice = invoiceFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Invoice invoiceFromJson(String str) => Invoice.fromJson(json.decode(str));

String invoiceToJson(Invoice data) => json.encode(data.toJson());

class Invoice {
  Invoice({
    @required this.ihlId,
    @required this.transactionId,
    @required this.ihlInvoiceNumbers,
    @required this.mobileNumber,
    @required this.ihlAppointmentId,
    @required this.discount,
    @required this.discountType,
    @required this.usageType,
  });

  String ihlId,
      transactionId,
      ihlInvoiceNumbers,
      mobileNumber,
      ihlAppointmentId,
      discount,
      discountType,
      usageType;

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        ihlId: json["ihl_id"],
        transactionId: json["transaction_id"],
        ihlInvoiceNumbers: json["ihl_invoice_numbers"],
        mobileNumber: json["mobile_number"],
        ihlAppointmentId: json["ihl_appointment_id"],
        discount: json["discount"] == "" || json["discount"] == null
            ? ""
            : twoDecimalValues(json["discount"]),
        discountType: json["DiscountType"],
        usageType: json["UsageType"],
      );

  Map<String, dynamic> toJson() => {
        "ihl_id": ihlId,
        "transaction_id": transactionId,
        "ihl_invoice_numbers": ihlInvoiceNumbers,
        "mobile_number": mobileNumber,
        "ihl_appointment_id": ihlAppointmentId,
        "discount": discount,
        "DiscountType": discountType,
        "UsageType": usageType,
      };
}

twoDecimalValues(String value) {
  if (value.toLowerCase() != "free") {
    return double.parse(value.toString()).toStringAsFixed(2);
  } else {
    return value;
  }
}
