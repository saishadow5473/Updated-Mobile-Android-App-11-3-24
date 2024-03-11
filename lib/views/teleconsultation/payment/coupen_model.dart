// To parse this JSON data, do
//
//     final coupenModel = coupenModelFromJson(jsonString);

import 'dart:convert';

CoupenModel coupenModelFromJson(String str) => CoupenModel.fromJson(json.decode(str));

String coupenModelToJson(CoupenModel data) => json.encode(data.toJson());

class CoupenModel {
  CoupenModel({
    this.status,
    this.amount,
    this.couponType,
    this.isNotBillableToIhl,
    this.discountPercentage,
  });

  String status;
  int amount;
  String couponType;
  bool isNotBillableToIhl;
  double discountPercentage;

  factory CoupenModel.fromJson(Map<String, dynamic> json) => CoupenModel(
        status: json["status"],
        amount: json["amount"] ?? 0,
        couponType: json["coupon_type"],
        isNotBillableToIhl: json["isNotBillableToIhl"],
        discountPercentage: double.parse(json["discount_percentage"] ?? "0"),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "amount": amount,
        "coupon_type": couponType,
        "isNotBillableToIhl": isNotBillableToIhl,
        "discount_percentage": discountPercentage,
      };
}
