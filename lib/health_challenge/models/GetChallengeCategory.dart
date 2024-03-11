// To parse this JSON data, do
//
//     final getChallengeCategory = getChallengeCategoryFromJson(jsonString);

import 'dart:convert';

GetChallengeCategory getChallengeCategoryFromJson(String str) => GetChallengeCategory.fromJson(json.decode(str));

String getChallengeCategoryToJson(GetChallengeCategory data) => json.encode(data.toJson());

class GetChallengeCategory {
  List<String> status;

  GetChallengeCategory({
     this.status,
  });

  factory GetChallengeCategory.fromJson(Map<String, dynamic> json) => GetChallengeCategory(
    status: List<String>.from(json["status"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "status": List<dynamic>.from(status.map((x) => x)),
  };
}
