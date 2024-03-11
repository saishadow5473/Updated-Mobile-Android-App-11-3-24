import 'package:intl/intl.dart' as intl;
import 'package:meta/meta.dart';

class HealthJournalGraphToJson {
  String userId;
  List<String> mealType;
  int startEpochDate, endEpochDate;
  HealthJournalGraphToJson({
    @required this.userId,
    @required this.mealType,
    @required this.startEpochDate,
    @required this.endEpochDate,
  });
  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "meal_type": List<dynamic>.from(mealType.map((x) => x)),
        "start_epoch_date": startEpochDate,
        "end_epoch_date": endEpochDate,
      };
}

class HealthJournalGraphModel {
  String timestamp, userIhlId, food, foodTimeCategory, totalCaloriesGained, day, month;
  DateTime foodLogTime;
  int epochLogTime;
  HealthJournalGraphModel(
      {@required this.timestamp,
      @required this.userIhlId,
      @required this.food,
      @required this.foodLogTime,
      @required this.epochLogTime,
      @required this.foodTimeCategory,
      @required this.totalCaloriesGained,
      this.day,
      this.month});
  factory HealthJournalGraphModel.fromJson(Map<String, dynamic> json) => HealthJournalGraphModel(
        timestamp: json["Timestamp"],
        userIhlId: json["user_ihl_id"],
        food: json["food"],
        foodLogTime: DateTime.parse(json["food_log_time"]),
        epochLogTime: json["epoch_log_time"],
        foodTimeCategory: json["food_time_category"],
        totalCaloriesGained: json["total_calories_gained"],
        month: intl.DateFormat('MMMM').format(DateTime.parse(json["food_log_time"])),
        day: intl.DateFormat('EEEE').format(DateTime.parse(json["food_log_time"])),
      );

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "user_ihl_id": userIhlId,
        "food": food,
        "food_log-time": foodLogTime,
        "epoch_log_time": epochLogTime,
        "food_time_category": foodTimeCategory,
        "total_calories_gained": totalCaloriesGained
      };
}

class DayModel {
  String day;
  List data = [];
  int fullValue;
  String name = "";

  DayModel({@required this.day, this.data, this.fullValue, this.name});

  factory DayModel.fromJson(Map<String, dynamic> json) => DayModel(
      day: json["Affiliation name"], data: json["data"] == null ? [] : json["data"], fullValue: 0);
}
