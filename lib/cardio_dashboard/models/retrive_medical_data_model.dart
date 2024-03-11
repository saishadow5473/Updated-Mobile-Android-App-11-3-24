class RetriveMedicalData {
  RetriveMedicalData({
    this.ihlUserId,
    this.createdDate,
    this.cholesterol,
    this.ldl,
    this.hdl,
    this.systolicBloodPressure,
    this.diastolicBloodPressure,
    this.gender,
    this.isSmoker,
    this.hasFamilyHistoryDiabetes,
    this.hasFamilyHistoryHypertension,
    this.score,
    this.foodPreference,
    this.region,
    this.onStatin,
    this.onAspirinTheraphy,
    this.weight,
    this.height,
  });

  String ihlUserId;
  DateTime createdDate;
  double cholesterol;
  double ldl;
  double hdl;
  double systolicBloodPressure;
  double diastolicBloodPressure;
  String gender;
  String isSmoker;
  String hasFamilyHistoryDiabetes;
  String hasFamilyHistoryHypertension;
  double score;
  String foodPreference;
  String region;
  String onStatin;
  String onAspirinTheraphy;
  double weight;
  double height;

  factory RetriveMedicalData.fromJson(Map<String, dynamic> json) => RetriveMedicalData(
        ihlUserId: json["ihl_user_id"],
        createdDate: DateTime.parse(json["created_date"]),
        cholesterol: json["Cholesterol"],
        ldl: json["ldl"],
        hdl: json["hdl"],
        systolicBloodPressure: json["systolic_blood_pressure"],
        diastolicBloodPressure: json["diastolic_blood_pressure"],
        gender: json["gender"],
        isSmoker: json["is_smoker"],
        hasFamilyHistoryDiabetes: json["has_family_history_diabetes"],
        hasFamilyHistoryHypertension: json["has_family_history_hypertension"],
        score: json["score"],
        foodPreference: json["food_preference"],
        region: json["region"],
        onStatin: json["on_statin"],
        onAspirinTheraphy: json["on_aspirin_theraphy"],
        weight: json["weight"],
        height: json["height"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "ihl_user_id": ihlUserId,
        "created_date": createdDate.toIso8601String(),
        "Cholesterol": cholesterol,
        "ldl": ldl,
        "hdl": hdl,
        "systolic_blood_pressure": systolicBloodPressure,
        "diastolic_blood_pressure": diastolicBloodPressure,
        "gender": gender,
        "is_smoker": isSmoker,
        "has_family_history_diabetes": hasFamilyHistoryDiabetes,
        "has_family_history_hypertension": hasFamilyHistoryHypertension,
        "score": score,
        "food_preference": foodPreference,
        "region": region,
        "on_statin": onStatin,
        "on_aspirin_theraphy": onAspirinTheraphy,
        "weight": weight,
        "height": height,
      };
}
