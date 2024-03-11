class StoreMedicalData {
  StoreMedicalData({
    this.storeLogTime,
    this.ihlUserId,
    this.systolicBloodPressure,
    this.diastolicBloodPressure,
    this.weight,
    this.cholesterol,
    this.ldl,
    this.hdl,
    this.isSmoker,
    this.hasFamilyHistoryDiabetes,
    this.hasHypertensionTreatment,
    this.onStatin,
    this.onAspirinTheraphy,
    this.region,
    this.foodPreference,
    this.gender,
  });

  String storeLogTime;
  String ihlUserId;
  double systolicBloodPressure;
  double diastolicBloodPressure;
  double weight;
  double cholesterol;
  double ldl;
  double hdl;
  String isSmoker;
  String hasFamilyHistoryDiabetes;
  String hasHypertensionTreatment;
  String onStatin;
  String onAspirinTheraphy;
  String region;
  String foodPreference;
  String gender;

  factory StoreMedicalData.fromJson(Map<String, dynamic> json) => StoreMedicalData(
        storeLogTime: json["store_log_time"],
        ihlUserId: json["ihl_user_id"],
        systolicBloodPressure: json["systolic_blood_pressure"],
        diastolicBloodPressure: json["diastolic_blood_pressure"],
        weight: json["weight"],
        cholesterol: json["Cholesterol"],
        ldl: json["ldl"],
        hdl: json["hdl"],
        isSmoker: json["is_smoker"],
        hasFamilyHistoryDiabetes: json["has_family_history_diabetes"],
        hasHypertensionTreatment: json["has_hypertension_treatment"],
        onStatin: json["on_statin"],
        onAspirinTheraphy: json["on_aspirin_theraphy"],
        region: json["region"],
        foodPreference: json["food_preference"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "store_log_time": storeLogTime,
        "ihl_user_id": ihlUserId,
        "systolic_blood_pressure": systolicBloodPressure.toString(),
        "diastolic_blood_pressure": diastolicBloodPressure.toString(),
        "weight": weight.toString(),
        "Cholesterol": cholesterol.toString(),
        "ldl": ldl.toString(),
        "hdl": hdl.toString(),
        "is_smoker": isSmoker,
        "has_family_history_diabetes": hasFamilyHistoryDiabetes,
        "has_hypertension_treatment": hasHypertensionTreatment,
        "on_statin": onStatin,
        "on_aspirin_theraphy": onAspirinTheraphy,
        "region": region,
        "food_preference": foodPreference,
        "gender": gender,
      };
}
