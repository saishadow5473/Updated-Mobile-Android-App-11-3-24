// To parse this JSON data, do
//
//     final allMedicalFiles = allMedicalFilesFromJson(jsonString);

import 'dart:convert';

List<AllMedicalFiles> allMedicalFilesFromJson(String str) =>
    List<AllMedicalFiles>.from(json.decode(str).map((x) => AllMedicalFiles.fromJson(x)));

String allMedicalFilesToJson(List<AllMedicalFiles> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllMedicalFiles {
  String documentId;
  String documentName;
  String documentType;
  DocumentFormat documentFormat;
  String documentLink;

  AllMedicalFiles({
    this.documentId,
    this.documentName,
    this.documentType,
    this.documentFormat,
    this.documentLink,
  });

  factory AllMedicalFiles.fromJson(Map<String, dynamic> json) => AllMedicalFiles(
        documentId: json["document_id"],
        documentName: json["document_name"],
        documentType: json["document_type"],
        documentFormat: documentFormatValues.map[json["document_format"]],
        documentLink: json["document_link"],
      );

  Map<String, dynamic> toJson() => {
        "document_id": documentId,
        "document_name": documentName,
        "document_type": documentType,
        "document_format": documentFormatValues.reverse[documentFormat],
        "document_link": documentLink,
      };
}

enum DocumentFormat { IMAGE }

final documentFormatValues = EnumValues({"image": DocumentFormat.IMAGE});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
