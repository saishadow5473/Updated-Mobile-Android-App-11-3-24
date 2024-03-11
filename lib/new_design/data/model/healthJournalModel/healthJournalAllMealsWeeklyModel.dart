import 'healthJournalgraph.dart';

class WeeklyModel {
  String xValue;
  int fullValue;
  List<CategoryWiseDatum> categoryWiseData;
  String name = "";

  WeeklyModel({this.xValue, this.fullValue, this.categoryWiseData, this.name});

  factory WeeklyModel.fromJson(Map<String, dynamic> json) => WeeklyModel(
      xValue: json["xValue"],
      fullValue: json["fullValue"],
      categoryWiseData: List<CategoryWiseDatum>.from(
          json["categoryWiseData"].map((x) => CategoryWiseDatum.fromJson(x))),
      name: "");

  Map<String, dynamic> toJson() => {
        "xValue": xValue,
        "fullValue": fullValue,
        "categoryWiseData": List<dynamic>.from(categoryWiseData.map((x) => x.toJson())),
      };
}

class CategoryWiseDatum {
  String categoryName;
  List<HealthJournalGraphModel> data;
  int catFullValue = 0;

  CategoryWiseDatum({
    this.categoryName,
    this.data,
    this.catFullValue,
  });

  factory CategoryWiseDatum.fromJson(Map<String, dynamic> json) => CategoryWiseDatum(
      categoryName: json["categoryName"],
      data: List<HealthJournalGraphModel>.from(
          json["data"].map((x) => HealthJournalGraphModel.fromJson(x))),
      catFullValue: 0);

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "data": List<HealthJournalGraphModel>.from(data.map((x) => x.toJson())),
        "catFullValue": catFullValue,
      };
}
