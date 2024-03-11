class LastCheckinModel {
  LastCheckinModel({
    this.lastCheckin,
  });

  LastCheckin lastCheckin;

  factory LastCheckinModel.fromJson(Map<String, dynamic> json) =>
      LastCheckinModel(
        lastCheckin: LastCheckin.fromJson(json["LastCheckin"]),
      );

  Map<String, dynamic> toJson() => {
        "LastCheckin": lastCheckin.toJson(),
      };
}

class LastCheckin {
  LastCheckin({
    this.id,
    this.dateTime,
    this.weightKg,
    this.heightMeters,
    this.ecgData,
    this.ecgData2,
    this.ecgData3,
    this.ihlMachineId,
    this.ihlId,
    this.ihlMachineName,
    this.ihlMachineLocation,
    this.firstName,
    this.systolic,
    this.diastolic,
    this.pulseBpm,
    this.sourceVendorId,
    this.sourceType,
    this.sourceId,
    this.score,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.bmi,
    this.dateTimeFormatted,
    this.bmiClass,
    this.bpClass,
    this.map,
    this.pulseClass,
  });

  String id;
  String dateTime;
  double weightKg;
  double heightMeters;
  String ecgData;
  String ecgData2;
  String ecgData3;
  String ihlMachineId;
  String ihlId;
  String ihlMachineName;
  String ihlMachineLocation;
  String firstName;
  double systolic;
  double diastolic;
  double pulseBpm;
  String sourceVendorId;
  String sourceType;
  String sourceId;
  double score;
  String dateOfBirth;
  String age;
  String gender;
  double bmi;
  DateTime dateTimeFormatted;
  String bmiClass;
  String bpClass;
  double map;
  String pulseClass;

  factory LastCheckin.fromJson(Map<String, dynamic> json) => LastCheckin(
        id: json["id"],
        dateTime: json["dateTime"],
        weightKg: json["weightKG"].toDouble(),
        heightMeters: json["heightMeters"].toDouble(),
        ecgData: json["ECGData"],
        ecgData2: json["ECGData2"],
        ecgData3: json["ECGData3"],
        ihlMachineId: json["IHLMachineId"],
        ihlId: json["IHL_ID"],
        ihlMachineName: json["IHLMachineName"],
        ihlMachineLocation: json["IHLMachineLocation"],
        firstName: json["firstName"],
        systolic: json["systolic"],
        diastolic: json["diastolic"],
        pulseBpm: json["pulseBpm"],
        sourceVendorId: json["sourceVendorID"],
        sourceType: json["sourceType"],
        sourceId: json["sourceId"],
        score: json["score"],
        dateOfBirth: json["dateOfBirth"],
        age: json["Age"],
        gender: json["gender"],
        bmi: json["bmi"].toDouble(),
        dateTimeFormatted: DateTime.parse(json["dateTimeFormatted"]),
        bmiClass: json["bmiClass"],
        bpClass: json["bpClass"],
        map: json["map"].toDouble(),
        pulseClass: json["pulseClass"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dateTime": dateTime,
        "weightKG": weightKg,
        "heightMeters": heightMeters,
        "ECGData": ecgData,
        "ECGData2": ecgData2,
        "ECGData3": ecgData3,
        "IHLMachineId": ihlMachineId,
        "IHL_ID": ihlId,
        "IHLMachineName": ihlMachineName,
        "IHLMachineLocation": ihlMachineLocation,
        "firstName": firstName,
        "systolic": systolic,
        "diastolic": diastolic,
        "pulseBpm": pulseBpm,
        "sourceVendorID": sourceVendorId,
        "sourceType": sourceType,
        "sourceId": sourceId,
        "score": score,
        "dateOfBirth": dateOfBirth,
        "Age": age,
        "gender": gender,
        "bmi": bmi,
        "dateTimeFormatted": dateTimeFormatted.toIso8601String(),
        "bmiClass": bmiClass,
        "bpClass": bpClass,
        "map": map,
        "pulseClass": pulseClass,
      };
}
