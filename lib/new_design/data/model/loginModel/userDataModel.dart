import '../affiliation_details_model.dart';

class UserData {
  UserData({
    this.token,
    this.user,
    this.lastCheckin,
  });

  String token;
  User user;
  LastCheckin lastCheckin;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        token: json["Token"],
        user: User.fromJson(json["User"]),
        lastCheckin: LastCheckin.fromJson(json["LastCheckin"] ?? {}),
      );
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
    this.cholesterol,
    this.medicalhistorydataIsSmoker,
    this.foodPreference,
    this.medicalhistorydataLdl,
    this.medicalhistorydataHdl,
    this.medicalhistorydataOnStatin,
    this.medicalhistorydataOnAspirinTheraphy,
    this.medicalhistorydataHasFamilyHistoryDiabetes,
    this.medicalhistorydataHasHypertensionTreatment,
    this.medicalhistorydataScore,
    this.ihlUserIdentificationId,
    this.ihlMachineId,
    this.ihlId,
    this.organization,
    this.orgMacName,
    this.orgAddress,
    this.ihlMachineLocation,
    this.score,
    this.dateOfBirth,
    this.gender,
    this.bmi,
    // this.dateTimeFormatted,
    this.bmiClass,
  });

  String id;
  String dateTime;
  double weightKg;
  double heightMeters;
  String ecgData;
  String ecgData2;
  String ecgData3;
  double cholesterol;
  String medicalhistorydataIsSmoker;
  String foodPreference;
  String medicalhistorydataLdl;
  String medicalhistorydataHdl;
  String medicalhistorydataOnStatin;
  String medicalhistorydataOnAspirinTheraphy;
  String medicalhistorydataHasFamilyHistoryDiabetes;
  String medicalhistorydataHasHypertensionTreatment;
  String medicalhistorydataScore;
  String ihlUserIdentificationId;
  String ihlMachineId;
  String ihlId;
  String organization;
  String orgMacName;
  String orgAddress;
  String ihlMachineLocation;
  double score;
  String dateOfBirth;
  String gender;
  double bmi;
  // DateTime dateTimeFormatted;
  String bmiClass;

  factory LastCheckin.fromJson(Map<String, dynamic> json) => LastCheckin(
        id: json["id"],
        dateTime: json["dateTime"],
        weightKg: json.containsKey('weightKG') ? json["weightKG"] : 0.0,
        heightMeters: json["heightMeters"]?.toDouble(),
        ecgData: json["ECGData"],
        ecgData2: json["ECGData2"],
        ecgData3: json["ECGData3"],
        cholesterol: json["Cholesterol"],
        medicalhistorydataIsSmoker: json["medicalhistorydata_is_smoker"],
        foodPreference: json["food_preference"],
        medicalhistorydataLdl: json["medicalhistorydata_ldl"],
        medicalhistorydataHdl: json["medicalhistorydata_hdl"],
        medicalhistorydataOnStatin: json["medicalhistorydata_on_statin"],
        medicalhistorydataOnAspirinTheraphy: json["medicalhistorydata_on_aspirin_theraphy"],
        medicalhistorydataHasFamilyHistoryDiabetes:
            json["medicalhistorydata_has_family_history_diabetes"],
        medicalhistorydataHasHypertensionTreatment:
            json["medicalhistorydata_has_hypertension_treatment"],
        medicalhistorydataScore: json["medicalhistorydata_score"],
        ihlUserIdentificationId: json["ihl_user_identification_id"],
        ihlMachineId: json["IHLMachineId"],
        ihlId: json["IHL_ID"],
        organization: json["organization"],
        orgMacName: json["orgMacName"],
        orgAddress: json["orgAddress"],
        ihlMachineLocation: json["IHLMachineLocation"],
        score: json["score"],
        dateOfBirth: json["dateOfBirth"],
        gender: json["gender"],
        bmi: json.containsKey('bmi') ? json["bmi"]?.toDouble() : 0.0,
        // dateTimeFormatted: json["dateTimeFormatted"],
        bmiClass: json["bmiClass"],
      );
}

class User {
  User({
    this.id,
    this.lastUpdated,
    this.userInputWeightInKg,
    this.hasPhoto,
    this.introDone,
    this.photo,
    this.photoTime,
    this.photofmt,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    // this.trailStartDate,
    // this.trailEndDate,
    this.status,
    this.affiliate,
    this.email,
    this.gender,
    this.heightMeters,
    this.fingerPrint,
    this.aadhaarNumber,
    this.mobileNumber,
    this.higiScore,
    this.state,
    this.city,
    this.area,
    this.address,
    this.pincode,
    this.userAffiliate,
    this.teleconsultLastCheckinService,
    this.accountCreated,
    this.termsHistory,
    this.terms,
    this.privacyAgreed,
    this.privacyAgreedHistory,
    this.notifications,
    this.currentHigiScore,
    this.hasPassword,
    this.privacy,
    this.tags,
  });

  String id;
  int lastUpdated;
  String userInputWeightInKg;
  bool hasPhoto;
  bool introDone;
  String photo;
  int photoTime;
  String photofmt;
  String firstName;
  String lastName;
  String dateOfBirth;
  // DateTime trailStartDate;
  // DateTime trailEndDate;
  String status;
  String affiliate;
  String email;
  String gender;
  double heightMeters;
  String fingerPrint;
  String aadhaarNumber;
  String mobileNumber;
  double higiScore;
  String state;
  String city;
  String area;
  String address;
  String pincode;
  UserAffiliate userAffiliate;
  TeleconsultLastCheckinService teleconsultLastCheckinService;
  String accountCreated;
  List<Terms> termsHistory;
  Terms terms;
  PrivacyAgreed privacyAgreed;
  List<PrivacyAgreed> privacyAgreedHistory;
  Notifications notifications;
  double currentHigiScore;
  bool hasPassword;
  Privacy privacy;
  Tags tags;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        lastUpdated: json["lastUpdated"],
        userInputWeightInKg: json["userInputWeightInKG"],
        hasPhoto: json["hasPhoto"],
        introDone: json["introDone"],
        photo: json["photo"],
        photoTime: json["photoTime"],
        photofmt: json["photofmt"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        dateOfBirth: json["dateOfBirth"],
        // trailStartDate: json["trail_start_date"] == null
        //     ? DateTime.parse(json["trail_start_date"])
        //     : DateTime.now(),
        // trailEndDate: json["trail_end_date"] == null
        //     ? DateTime.parse(json["trail_end_date"])
        //     : DateTime.now(),
        status: json["status"],
        affiliate: json["affiliate"],
        email: json["email"],
        gender: json["gender"],
        heightMeters: json["heightMeters"]?.toDouble(),
        fingerPrint: json["fingerPrint"],
        aadhaarNumber: json["aadhaarNumber"],
        mobileNumber: json["mobileNumber"],
        higiScore: json["higiScore"],
        state: json["state"],
        city: json["city"],
        area: json["area"],
        address: json["address"],
        pincode: json["pincode"],
        userAffiliate: UserAffiliate.fromJson(json["user_affiliate"] ?? {}),
        // userAffiliate: json["user_affiliate"],
        // teleconsultLastCheckinService:
        //     TeleconsultLastCheckinService.fromJson(json["teleconsult_last_checkin_service"]),
        accountCreated: json["accountCreated"],
        //termsHistory: List<Terms>.from(json["termsHistory"].map((x) => Terms.fromJson(x))),
        terms: Terms.fromJson(json["terms"]),
        privacyAgreed: PrivacyAgreed.fromJson(json["privacyAgreed"]),
        // privacyAgreedHistory: List<PrivacyAgreed>.from(
        //     json["privacyAgreedHistory"].map((x) => PrivacyAgreed.fromJson(x))),
        notifications: Notifications.fromJson(json["Notifications"]),
        currentHigiScore: json["currentHigiScore"],
        hasPassword: json["hasPassword"],
        privacy: Privacy.fromJson(json["privacy"]),
        tags: Tags.fromJson(json["tags"]),
      );
}

class Notifications {
  Notifications({
    this.emailCheckins,
    this.emailMonthlyRecap,
    this.emailHigisphereNotifications,
    this.emailHigiNews,
    this.emailMonthlyDigest,
  });

  String emailCheckins;
  String emailMonthlyRecap;
  String emailHigisphereNotifications;
  String emailHigiNews;
  String emailMonthlyDigest;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        emailCheckins: json["EmailCheckins"],
        emailMonthlyRecap: json["EmailMonthlyRecap"],
        emailHigisphereNotifications: json["EmailHigisphereNotifications"],
        emailHigiNews: json["EmailHigiNews"],
        emailMonthlyDigest: json["EmailMonthlyDigest"],
      );
}

class Privacy {
  Privacy({
    this.leaderBoard,
    this.thirdPartySharing,
  });

  LeaderBoard leaderBoard;
  ThirdPartySharing thirdPartySharing;

  factory Privacy.fromJson(Map<String, dynamic> json) => Privacy(
        leaderBoard: LeaderBoard.fromJson(json["leaderBoard"]),
        thirdPartySharing: ThirdPartySharing.fromJson(json["thirdPartySharing"]),
      );
}

class LeaderBoard {
  LeaderBoard({
    this.enabled,
  });

  bool enabled;

  factory LeaderBoard.fromJson(Map<String, dynamic> json) => LeaderBoard(
        enabled: json["enabled"],
      );
}

class ThirdPartySharing {
  ThirdPartySharing({
    this.nonIdentifiableSharing,
  });

  bool nonIdentifiableSharing;

  factory ThirdPartySharing.fromJson(Map<String, dynamic> json) => ThirdPartySharing(
        nonIdentifiableSharing: json["nonIdentifiableSharing"],
      );
}

class PrivacyAgreed {
  PrivacyAgreed({
    this.privacyAgreedDate,
    this.privacyFileName,
  });

  String privacyAgreedDate;
  String privacyFileName;

  factory PrivacyAgreed.fromJson(Map<String, dynamic> json) => PrivacyAgreed(
        privacyAgreedDate: json["privacyAgreedDate"],
        privacyFileName: json["privacyFileName"],
      );
}

class Tags {
  Tags({
    this.isEarndItUser,
    this.testTag1,
  });

  bool isEarndItUser;
  int testTag1;

  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        isEarndItUser: json["isEarndItUser"],
        testTag1: json["testTag1"],
      );
}

class TeleconsultLastCheckinService {
  TeleconsultLastCheckinService({
    this.serviceProvided,
    this.vendorName,
    this.invoiceId,
    this.invoiceNumber,
  });

  bool serviceProvided;
  String vendorName;
  String invoiceId;
  String invoiceNumber;

  factory TeleconsultLastCheckinService.fromJson(Map<String, dynamic> json) =>
      TeleconsultLastCheckinService(
        serviceProvided: json["service_provided"] ?? "",
        vendorName: json["vendor_name"] ?? "",
        invoiceId: json["invoice_id"] ?? "",
        invoiceNumber: json["invoice_number"] ?? "",
      );
}

class Terms {
  Terms({
    this.termsAgreedDate,
    this.termsFileName,
  });

  String termsAgreedDate;
  String termsFileName;

  factory Terms.fromJson(Map<String, dynamic> json) => Terms(
        termsAgreedDate: json["termsAgreedDate"],
        termsFileName: json["termsFileName"],
      );
}

class UserAffiliate {
  UserAffiliate({
    this.afNo1,
    this.afNo2,
    this.afNo3,
    this.afNo4,
    this.afNo5,
    this.afNo6,
    this.afNo7,
    this.afNo8,
    this.afNo9,
  });

  AfNo afNo1;
  AfNo afNo2;
  AfNo afNo3;
  AfNo afNo4;
  AfNo afNo5;
  AfNo afNo6;
  AfNo afNo7;
  AfNo afNo8;
  AfNo afNo9;

  factory UserAffiliate.fromJson(Map<String, dynamic> json) => UserAffiliate(
      afNo1: AfNo.fromJson(json["af_no1"] ?? {}),
      afNo2: AfNo.fromJson(json["af_no2"] ?? {}),
      afNo3: AfNo.fromJson(json["af_no3"] ?? {}),
      afNo4: AfNo.fromJson(json["af_no4"] ?? {}),
      afNo5: AfNo.fromJson(json["af_no5"] ?? {}),
      afNo6: AfNo.fromJson(json["af_no6"] ?? {}),
      afNo7: AfNo.fromJson(json["af_no7"] ?? {}),
      afNo8: AfNo.fromJson(json["af_no8"] ?? {}),
      afNo9: AfNo.fromJson(json["af_no9"] ?? {}));

  Map<String, dynamic> toJson() => {
        "af_no1": afNo1?.toJson(),
        "af_no2": afNo2?.toJson(),
        "af_no3": afNo3?.toJson(),
        "af_no4": afNo4?.toJson(),
        "af_no5": afNo5?.toJson(),
        "af_no6": afNo6?.toJson(),
        "af_no7": afNo7?.toJson(),
        "af_no8": afNo8?.toJson(),
        "af_no9": afNo9?.toJson(),
      };
}

class AfNo {
  AfNo(
      {this.affilateUniqueName,
      this.affilateName,
      this.affilateEmail,
      this.affilateMobile,
      this.affliateIdentifierId,
      this.isSso,
      this.imgUrl,
      this.affiliate_theme_color,
      this.featureSettings,
      this.affiliate_pillar_list});

  String affilateUniqueName;
  String affilateName;
  String affilateEmail;
  String affilateMobile;
  String affliateIdentifierId;
  String imgUrl;
  bool isSso;
  String affiliate_theme_color;
  List affiliate_pillar_list;
  FeatureSettings featureSettings;

  factory AfNo.fromJson(Map<String, dynamic> json) {
    return AfNo(
      affilateUniqueName: json["affilate_unique_name"],
      affilateName: json["affilate_name"],
      affilateEmail: json["affilate_email"],
      affilateMobile: json["affilate_mobile"],
      affliateIdentifierId: json["affliate_identifier_id"],
      isSso: json["is_sso"],
      affiliate_pillar_list: json["affiliate_pillar_list"] ?? [],
      affiliate_theme_color: json["affiliate_theme_color"] ?? "19A9E5",
      imgUrl: "",
    );
  }

  Map<String, dynamic> toJson() => {
        "affilate_unique_name": affilateUniqueName,
        "affilate_name": affilateName,
        "affilate_email": affilateEmail,
        "affilate_mobile": affilateMobile,
        "affliate_identifier_id": affliateIdentifierId,
        "is_sso": isSso,
        "affiliate_pillar_list": affiliate_pillar_list.toList(),
        "affiliate_theme_color": affiliate_theme_color
      };
}
