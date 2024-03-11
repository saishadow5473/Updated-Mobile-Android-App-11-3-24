class DoctorModel {
  //lib\new_design\data\model\TeleconsultationModels\TeleconulstationDashboardModels.dart
  AffilationExcusiveData affilationExcusiveData;
  bool exclusiveOnly;
  String rmpId;
  String vendorId;
  String ihlConsultantId;
  String vendorConsultantId;
  String name;
  String email;
  String contactNumber;
  int age;
  List<String> languagesSpoken;
  List<String> consultantSpeciality;
  String description;
  String gender;
  String suffix;
  String qualification;
  String experience;
  String ratings;
  String consultationFees;
  bool liveCallAllowed;
  String currentLiveStatus;
  List<dynamic> textReviewsData;
  String accountId;
  String accountName;
  String accountStatus;
  String consultantAddress;
  String userName;
  String docImage = "";
  bool livecall;

  DoctorModel(
      {this.affilationExcusiveData,
      this.exclusiveOnly,
      this.rmpId,
      this.vendorId,
      this.ihlConsultantId,
      this.vendorConsultantId,
      this.name,
      this.email,
      this.contactNumber,
      this.age,
      this.languagesSpoken,
      this.consultantSpeciality,
      this.description,
      this.gender,
      this.suffix,
      this.qualification,
      this.experience,
      this.ratings,
      this.consultationFees,
      this.liveCallAllowed,
      this.currentLiveStatus,
      this.textReviewsData,
      this.accountId,
      this.accountName,
      this.accountStatus,
      this.consultantAddress,
      this.userName,
      this.docImage,
      this.livecall});

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String name = json["user_name"] ?? json["consultant_name"];
    String holdername = json["name"] ?? json["consultant_name"];
    if (json == null) {
      return DoctorModel();
    }
    return DoctorModel(
      affilationExcusiveData: json["affilation_excusive_data"] == null
          ? AffilationExcusiveData.fromJson(json["AffilationExclusive"])
          : AffilationExcusiveData.fromJson(json["affilation_excusive_data"]),
      exclusiveOnly: json["exclusive_only"],
      rmpId: json["RMP_ID"],
      vendorId: json["vendor_id"],
      ihlConsultantId: json["ihl_consultant_id"],
      vendorConsultantId: json["vendor_consultant_id"],
      name: holdername,
      email: json["email"],
      contactNumber: json["contact_number"],
      age: json["age"],
      languagesSpoken: json["languages_Spoken"] != null
          ? List<String>.from(json["languages_Spoken"].map((x) => x))
          : [],
      consultantSpeciality: json["consultant_speciality"] != null
          ? List<String>.from(json["consultant_speciality"].map((x) => x))
          : List<String>.from(json["speciality_list"].map((x) => x)),
      description: json["description"]
          .toString()
          .replaceAll('&#39;', "'")
          .replaceAll('&amp;', '')
          .replaceAll('nbsp;', ''),
      gender: json["gender"],
      suffix: json["suffix"],
      qualification: json["qualification"],
      experience: json["experience"],
      ratings: json["ratings"],
      consultationFees: json["consultation_fees"] == "" ? "0" : json["consultation_fees"],
      liveCallAllowed: json["live_call_allowed"].toString().toBoolean(),
      currentLiveStatus: json["current_live_status"] ?? "false",
      textReviewsData: json["text_reviews_data"] != null
          ? List<dynamic>.from(json["text_reviews_data"].map((x) => x))
          : [],
      accountId: json["account_id"],
      accountName: json["account_name"],
      accountStatus: json["account_status"],
      consultantAddress: json["consultant_address"],
      userName: name,
    );
  }

  Map<String, dynamic> toJson() => {
        "affilation_excusive_data":
            affilationExcusiveData != null ? affilationExcusiveData.toJson() : null,
        "exclusive_only": exclusiveOnly,
        "RMP_ID": rmpId,
        "vendor_id": vendorId,
        "ihl_consultant_id": ihlConsultantId,
        "vendor_consultant_id": vendorConsultantId,
        "name": name,
        "email": email,
        "contact_number": contactNumber,
        "age": age,
        "languages_Spoken": List<dynamic>.from(languagesSpoken.map((x) => x)),
        "consultant_speciality": List<dynamic>.from(consultantSpeciality.map((x) => x)),
        "description": description,
        "gender": gender,
        "suffix": suffix,
        "qualification": qualification,
        "experience": experience,
        "ratings": ratings,
        "consultation_fees": consultationFees,
        "live_call_allowed": liveCallAllowed,
        "current_live_status": currentLiveStatus,
        "text_reviews_data": List<dynamic>.from(textReviewsData.map((x) => x)),
        "account_id": accountId,
        "account_name": accountName,
        "account_status": accountStatus,
        "consultant_address": consultantAddress,
        "user_name": userName,
      };
}

class AffilationExcusiveData {
  List<AffilationArray> affilationArray;

  AffilationExcusiveData({
    this.affilationArray,
  });

  factory AffilationExcusiveData.fromJson(dynamic json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    if (json.isNotEmpty && json.runtimeType.toString() == "List<dynamic>") {
      return AffilationExcusiveData(
        affilationArray: List<AffilationArray>.from(json.map((x) => AffilationArray.fromJson(x))),
      );
    }
    return AffilationExcusiveData(
      affilationArray: List<AffilationArray>.from(
          json["affilation_array"].map((x) => AffilationArray.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "affilation_array": List<dynamic>.from(affilationArray.map((x) => x.toJson())),
      };
}

class AffilationArray {
  String affilationUniqueName;
  String affilationName;
  String affilationMrp;
  String affilationPrice;

  AffilationArray({
    this.affilationUniqueName,
    this.affilationName,
    this.affilationMrp,
    this.affilationPrice,
  });

  factory AffilationArray.fromJson(Map<String, dynamic> json) => AffilationArray(
        affilationUniqueName: json["affilation_unique_name"],
        affilationName: json["affilation_name"],
        affilationMrp: json["affilation_mrp"],
        affilationPrice: json["affilation_price"],
      );

  Map<String, dynamic> toJson() => {
        "affilation_unique_name": affilationUniqueName,
        "affilation_name": affilationName,
        "affilation_mrp": affilationMrp,
        "affilation_price": affilationPrice,
      };
}

extension on String {
  bool toBoolean() {
    return (toLowerCase() == "true" || toLowerCase() == "1")
        ? true
        : (toLowerCase() == "false" || toLowerCase() == "0" ? false : false);
  }
}
