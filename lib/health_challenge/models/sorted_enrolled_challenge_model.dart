class SortedEnrolledChallenge {
  SortedEnrolledChallenge({
    this.userStatus,
    this.name,
    this.city,
    this.department,
    this.designation,
    this.gender,
    this.enrollmentId,
    this.userBibNo,
    this.challengeId,
    this.challengeName,
    this.imgUrl,
    this.thumbnailUrl,
    this.bannerImg,
    this.challengeMode,
    this.challengeType,
    this.target,
    this.challengeUnit,
    this.challengeRunType,
    this.selectedFitnessApp,
  });

  String userStatus;
  String name;
  String city;
  String department;
  String designation;
  String gender;
  String enrollmentId;
  String userBibNo;
  String challengeId;
  String challengeName;
  String imgUrl;
  String thumbnailUrl;
  String bannerImg;
  String challengeMode;
  String challengeType;
  String target;
  String challengeUnit;
  String challengeRunType;
  String selectedFitnessApp;

  factory SortedEnrolledChallenge.fromJson(Map<String, dynamic> json) => SortedEnrolledChallenge(
        userStatus: json["user_status"],
        name: json["name"],
        city: json["city"],
        department: json["department"],
        designation: json["designation"],
        gender: json["gender"],
        enrollmentId: json["enrollment_id"],
        userBibNo: json["user_bib_no"],
        challengeId: json["challenge_id"],
        challengeName: json["challenge_name"],
        imgUrl: json["img_url"],
        thumbnailUrl: json["thumbnail_url"],
        bannerImg: json["banner_img"],
        challengeMode: json["challenge_mode"],
        challengeType: json["challenge_type"],
        target: json["target"],
        challengeUnit: json["challenge_unit"],
        challengeRunType: json["challenge_run_type"],
        selectedFitnessApp: json["selected_fitness_app"],
      );

  Map<String, dynamic> toJson() => {
        "user_status": userStatus,
        "name": name,
        "city": city,
        "department": department,
        "designation": designation,
        "gender": gender,
        "enrollment_id": enrollmentId,
        "user_bib_no": userBibNo,
        "challenge_id": challengeId,
        "challenge_name": challengeName,
        "img_url": imgUrl,
        "thumbnail_url": thumbnailUrl,
        "banner_img": bannerImg,
        "challenge_mode": challengeMode,
        "challenge_type": challengeType,
        "target": target,
        "challenge_unit": challengeUnit,
        "challenge_run_type": challengeRunType,
        "selected_fitness_app": selectedFitnessApp,
      };
}

class SortedErChallenge {
  SortedErChallenge({
    this.notStarted,
    this.started,
    this.completed,
  });

  List<SortedEnrolledChallenge> notStarted;
  List<SortedEnrolledChallenge> started;
  List<SortedEnrolledChallenge> completed;

  factory SortedErChallenge.fromJson(Map<String, dynamic> json) => SortedErChallenge(
        notStarted: List<SortedEnrolledChallenge>.from(
            json["not_started"].map((x) => SortedEnrolledChallenge.fromJson(x))).toList(),
        started: List<SortedEnrolledChallenge>.from(
            json["started"].map((x) => SortedEnrolledChallenge.fromJson(x))).toList(),
        completed: List<SortedEnrolledChallenge>.from(
            json["completed"].map((x) => SortedEnrolledChallenge.fromJson(x))).toList(),
      );

  Map<String, dynamic> toJson() => {
        "not_started": List<dynamic>.from(notStarted.map((x) => x)),
        "started": List<dynamic>.from(started.map((x) => x)),
        "completed": List<dynamic>.from(completed.map((x) => x)),
      };
}
