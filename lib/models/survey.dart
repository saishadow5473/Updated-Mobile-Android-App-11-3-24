import 'dart:convert';

List<Survey> surveyFromJson(String str) =>
    List<Survey>.from(json.decode(str).map((x) => Survey.fromJson(x)));
String surveyToJson(List<Survey> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Survey {
  // ignore: unused_element
  Survey._();

  Survey({
    this.qId,
    this.showStatus,
    this.name,
    this.type,
    this.multiQuestions,
    this.icon,
    this.option,
    this.yes,
    this.answer,
  });

  String qId;

  bool showStatus;
  String name;
  Type type;
  List<dynamic> multiQuestions;
  String icon;
  List<dynamic> option;
  Yes yes;
  String answer;

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
        qId: json["q_id"],
        showStatus: json["showStatus"],
        name: json["name"],
        type: typeValues.map[json["type"]],
        multiQuestions: json["multi_questions"] == null
            ? null
            : List<dynamic>.from(json["multi_questions"].map((x) => x)),
        icon: json["icon"],
        option: List<dynamic>.from(json["option"].map((x) => x)),
        yes: Yes.fromJson(json["yes"]),
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "q_id": qId,
        "showStatus": showStatus,
        "name": name,
        "type": typeValues.reverse[type],
        "multi_questions": multiQuestions == null
            ? null
            : List<dynamic>.from(multiQuestions.map((x) => x)),
        "icon": icon,
        "option": List<dynamic>.from(option.map((x) => x)),
        "yes": yes.toJson(),
        "answer": answer,
      };
}

class OptionClass {
  OptionClass({
    this.status,
    this.range,
    this.value,
    this.check,
  });

  String status;
  String range;
  String value;
  bool check;

  factory OptionClass.fromJson(Map<String, dynamic> json) => OptionClass(
        status: json["status"],
        range: json["range"],
        value: json["value"],
        check: json["check"] == null ? null : json["check"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "range": range,
        "value": value,
        "check": check == null ? null : check,
      };
}

enum Type { RADIO }

final typeValues = EnumValues({"radio": Type.RADIO});

class Yes {
  Yes({
    this.showStatus,
    this.option,
    this.qId,
    this.name,
    this.type,
    this.answer,
  });

  bool showStatus;
  List<OptionClass> option;
  String qId;
  String name;
  String type;
  String answer;

  factory Yes.fromJson(Map<String, dynamic> json) => Yes(
        showStatus: json["showStatus"],
        option: List<OptionClass>.from(
            json["option"].map((x) => OptionClass.fromJson(x))),
        qId: json["q_id"] == null ? null : json["q_id"],
        name: json["name"] == null ? null : json["name"],
        type: json["type"] == null ? null : json["type"],
        answer: json["answer"] == null ? null : json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "showStatus": showStatus,
        "option": List<dynamic>.from(option.map((x) => x.toJson())),
        "q_id": qId == null ? null : qId,
        "name": name == null ? null : name,
        "type": type == null ? null : type,
        "answer": answer == null ? null : answer,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
