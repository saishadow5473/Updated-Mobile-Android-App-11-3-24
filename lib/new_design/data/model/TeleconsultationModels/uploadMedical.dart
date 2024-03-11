// To parse this JSON data, do
//
//     final uploadMedical = uploadMedicalFromJson(jsonString);

import 'dart:convert';

UploadMedical uploadMedicalFromJson(String str) => UploadMedical.fromJson(json.decode(str));

String uploadMedicalToJson(UploadMedical data) => json.encode(data.toJson());

class UploadMedical {
  String status;
  String documentId;

  UploadMedical({
    this.status,
    this.documentId,
  });

  factory UploadMedical.fromJson(Map<String, dynamic> json) => UploadMedical(
        status: json["status"],
        documentId: json["document_id"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "document_id": documentId,
      };
}
