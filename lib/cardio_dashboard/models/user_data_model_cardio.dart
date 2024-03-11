class UserDataModelCardio {
  UserDataModelCardio({
    this.user,
  });

  User user;

  factory UserDataModelCardio.fromJson(Map<String, dynamic> json) => UserDataModelCardio(
        user: User.fromJson(json["User"]),
      );

  Map<String, dynamic> toJson() => {
        "User": user.toJson(),
      };
}

class User {
  User({
    this.id,
    this.lastUpdated,
    this.userInputWeightInKg,
    this.personalEmail,
    this.hasPhoto,
    this.introDone,
    this.photo,
    this.photoTime,
    this.photofmt,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.trailStartDate,
    this.trailEndDate,
    this.status,
    this.affiliate,
    // this.userJobDetails,
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
    this.userScore,
    this.userAffiliate,
    this.lastCheckinServices,
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
  String personalEmail;
  bool hasPhoto;
  bool introDone;
  String photo;
  int photoTime;
  String photofmt;
  String firstName;
  String lastName;
  String dateOfBirth;
  DateTime trailStartDate;
  DateTime trailEndDate;
  String status;
  String affiliate;
  // UserJobDetails userJobDetails;
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
  Map<String, int> userScore;
  UserAffiliate userAffiliate;
  LastCheckinServices lastCheckinServices;
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
        personalEmail: json["personal_email"],
        hasPhoto: json["hasPhoto"],
        introDone: json["introDone"],
        photo: json["photo"],
        photoTime: json["photoTime"],
        photofmt: json["photofmt"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        dateOfBirth: json["dateOfBirth"],
        // trailStartDate:
        //     json["trail_start_date"] != null ? DateTime.parse(json["trail_start_date"]) : null,
        // trailEndDate:
        //     json["trail_end_date"] != null ? DateTime.parse(json["trail_end_date"]) : null,
        status: json["status"],
        affiliate: json["affiliate"],
        // userJobDetails: UserJobDetails.fromJson(json["user_job_details"]) == null
        //     ? null
        //     : UserJobDetails.fromJson(json["user_job_details"]),
        email: json["email"],
        gender: json["gender"],
        heightMeters: json["heightMeters"].toDouble(),
        fingerPrint: json["fingerPrint"],
        aadhaarNumber: json["aadhaarNumber"],
        mobileNumber: json["mobileNumber"],
        higiScore: json["higiScore"],
        state: json["state"],
        city: json["city"],
        area: json["area"],
        address: json["address"],
        pincode: json["pincode"],
        userScore: json["user_score"] != null
            ? Map.from(json["user_score"]).map((k, v) => MapEntry<String, int>(k, v))
            : {},
        // userAffiliate: UserAffiliate.fromJson(json["user_affiliate"]),
        // lastCheckinServices: LastCheckinServices.fromJson(json["last_checkin_services"]),
        // teleconsultLastCheckinService:
        //     TeleconsultLastCheckinService.fromJson(json["teleconsult_last_checkin_service"]),
        accountCreated: json["accountCreated"],
        // termsHistory: List<Terms>.from(json["termsHistory"].map((x) => Terms.fromJson(x))),
        // terms: Terms.fromJson(json["terms"]),
        // privacyAgreed: PrivacyAgreed.fromJson(json["privacyAgreed"]),
        // privacyAgreedHistory: List<PrivacyAgreed>.from(
        //     json["privacyAgreedHistory"].map((x) => PrivacyAgreed.fromJson(x))),
        notifications: Notifications.fromJson(json["Notifications"]),
        currentHigiScore: json["currentHigiScore"],
        hasPassword: json["hasPassword"],
        // privacy: Privacy.fromJson(json["privacy"]),
        tags: Tags.fromJson(json["tags"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastUpdated": lastUpdated,
        "userInputWeightInKG": userInputWeightInKg,
        "personal_email": personalEmail,
        "hasPhoto": hasPhoto,
        "introDone": introDone,
        "photo": photo,
        "photoTime": photoTime,
        "photofmt": photofmt,
        "firstName": firstName,
        "lastName": lastName,
        "dateOfBirth": dateOfBirth,
        "trail_start_date": trailStartDate.toIso8601String(),
        "trail_end_date": trailEndDate.toIso8601String(),
        "status": status,
        "affiliate": affiliate,
        // "user_job_details": userJobDetails.toJson(),
        "email": email,
        "gender": gender,
        "heightMeters": heightMeters,
        "fingerPrint": fingerPrint,
        "aadhaarNumber": aadhaarNumber,
        "mobileNumber": mobileNumber,
        "higiScore": higiScore,
        "state": state,
        "city": city,
        "area": area,
        "address": address,
        "pincode": pincode,
        "user_score": Map.from(userScore).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "user_affiliate": userAffiliate.toJson(),
        "last_checkin_services": lastCheckinServices.toJson(),
        "teleconsult_last_checkin_service": teleconsultLastCheckinService.toJson(),
        "accountCreated": accountCreated,
        "termsHistory": List<dynamic>.from(termsHistory.map((x) => x.toJson())),
        "terms": terms.toJson(),
        "privacyAgreed": privacyAgreed.toJson(),
        "privacyAgreedHistory": List<dynamic>.from(privacyAgreedHistory.map((x) => x.toJson())),
        "Notifications": notifications.toJson(),
        "currentHigiScore": currentHigiScore,
        "hasPassword": hasPassword,
        "privacy": privacy.toJson(),
        "tags": tags.toJson(),
      };
}

class LastCheckinServices {
  LastCheckinServices({
    this.weight,
    this.bp,
    this.bmc,
    this.bmcFull,
    this.ecg,
    this.spo2,
    this.temperature,
    this.serviceProvided,
    this.invoiceId,
  });

  bool weight;
  bool bp;
  bool bmc;
  bool bmcFull;
  bool ecg;
  bool spo2;
  bool temperature;
  bool serviceProvided;
  String invoiceId;

  factory LastCheckinServices.fromJson(Map<String, dynamic> json) => LastCheckinServices(
        weight: json["weight"],
        bp: json["bp"],
        bmc: json["bmc"],
        bmcFull: json["bmc_full"],
        ecg: json["ecg"],
        spo2: json["spo2"],
        temperature: json["temperature"],
        serviceProvided: json["service_provided"],
        invoiceId: json["invoice_id"],
      );

  Map<String, dynamic> toJson() => {
        "weight": weight,
        "bp": bp,
        "bmc": bmc,
        "bmc_full": bmcFull,
        "ecg": ecg,
        "spo2": spo2,
        "temperature": temperature,
        "service_provided": serviceProvided,
        "invoice_id": invoiceId,
      };
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

  Map<String, dynamic> toJson() => {
        "EmailCheckins": emailCheckins,
        "EmailMonthlyRecap": emailMonthlyRecap,
        "EmailHigisphereNotifications": emailHigisphereNotifications,
        "EmailHigiNews": emailHigiNews,
        "EmailMonthlyDigest": emailMonthlyDigest,
      };
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

  Map<String, dynamic> toJson() => {
        "leaderBoard": leaderBoard.toJson(),
        "thirdPartySharing": thirdPartySharing.toJson(),
      };
}

class LeaderBoard {
  LeaderBoard({
    this.enabled,
  });

  bool enabled;

  factory LeaderBoard.fromJson(Map<String, dynamic> json) => LeaderBoard(
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
      };
}

class ThirdPartySharing {
  ThirdPartySharing({
    this.nonIdentifiableSharing,
  });

  bool nonIdentifiableSharing;

  factory ThirdPartySharing.fromJson(Map<String, dynamic> json) => ThirdPartySharing(
        nonIdentifiableSharing: json["nonIdentifiableSharing"],
      );

  Map<String, dynamic> toJson() => {
        "nonIdentifiableSharing": nonIdentifiableSharing,
      };
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

  Map<String, dynamic> toJson() => {
        "privacyAgreedDate": privacyAgreedDate,
        "privacyFileName": privacyFileName,
      };
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

  Map<String, dynamic> toJson() => {
        "isEarndItUser": isEarndItUser,
        "testTag1": testTag1,
      };
}

class TeleconsultLastCheckinService {
  TeleconsultLastCheckinService({
    this.serviceProvided,
    this.vendorName,
    this.invoiceId,
  });

  bool serviceProvided;
  String vendorName;
  String invoiceId;

  factory TeleconsultLastCheckinService.fromJson(Map<String, dynamic> json) =>
      TeleconsultLastCheckinService(
        serviceProvided: json["service_provided"],
        vendorName: json["vendor_name"],
        invoiceId: json["invoice_id"],
      );

  Map<String, dynamic> toJson() => {
        "service_provided": serviceProvided,
        "vendor_name": vendorName,
        "invoice_id": invoiceId,
      };
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

  Map<String, dynamic> toJson() => {
        "termsAgreedDate": termsAgreedDate,
        "termsFileName": termsFileName,
      };
}

class UserAffiliate {
  UserAffiliate({
    this.afNo1,
  });

  AfNo1 afNo1;

  factory UserAffiliate.fromJson(Map<String, dynamic> json) => UserAffiliate(
        afNo1: AfNo1.fromJson(json["af_no1"]),
      );

  Map<String, dynamic> toJson() => {
        "af_no1": afNo1.toJson(),
      };
}

class AfNo1 {
  AfNo1({
    this.affilateUniqueName,
    this.affilateName,
    this.affilateEmail,
    this.affilateMobile,
    this.affliateIdentifierId,
    this.isSso,
  });

  String affilateUniqueName;
  String affilateName;
  String affilateEmail;
  String affilateMobile;
  String affliateIdentifierId;
  bool isSso;

  factory AfNo1.fromJson(Map<String, dynamic> json) => AfNo1(
        affilateUniqueName: json["affilate_unique_name"],
        affilateName: json["affilate_name"],
        affilateEmail: json["affilate_email"],
        affilateMobile: json["affilate_mobile"],
        affliateIdentifierId: json["affliate_identifier_id"],
        isSso: json["is_sso"],
      );

  Map<String, dynamic> toJson() => {
        "affilate_unique_name": affilateUniqueName,
        "affilate_name": affilateName,
        "affilate_email": affilateEmail,
        "affilate_mobile": affilateMobile,
        "affliate_identifier_id": affliateIdentifierId,
        "is_sso": isSso,
      };
}

// class UserJobDetails {
//   UserJobDetails({
//     this.employeeId,
//     this.department,
//     this.jobTitle,
//     this.officeLocation,
//     this.postalCode,
//     this.streetAddress,
//     this.state,
//     this.city,
//   });

//   String employeeId;
//   String department;
//   String jobTitle;
//   String officeLocation;
//   String postalCode;
//   String streetAddress;
//   String state;
//   String city;

//   factory UserJobDetails.fromJson(Map<String, dynamic> json) => UserJobDetails(
//         employeeId: json["employeeId"] ?? "",
//         department: json["department"] ?? "",
//         jobTitle: json["jobTitle"] ?? "",
//         officeLocation: json["officeLocation"] ?? "",
//         postalCode: json["postalCode"] ?? "",
//         streetAddress: json["streetAddress"] ?? "",
//         state: json["state"] ?? "",
//         city: json["city"] ?? "",
//       );

//   Map<String, dynamic> toJson() => {
//         "employeeId": employeeId,
//         "department": department,
//         "jobTitle": jobTitle,
//         "officeLocation": officeLocation,
//         "postalCode": postalCode,
//         "streetAddress": streetAddress,
//         "state": state,
//         "city": city,
//       };
// }
