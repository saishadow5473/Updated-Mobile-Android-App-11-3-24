class ChallengeVideoGenModel {
  String img1;
  String img2;
  String img3;
  String img4;
  String img5;
  String img6;
  String img7;
  String img8;
  String img9;
  String img10;
  String img11;
  String firstName;
  String lastName;
  String runName;
  String bib;
  String enrollmentId;
  String speed;
  String distance;
  String duration;
  String submit;
  String challenge_name;
  String template_affiliation;

  ChallengeVideoGenModel(
      {this.img1,
      this.img2,
      this.img3,
      this.img4,
      this.img5,
      this.img6,
      this.img7,
      this.img8,
      this.img9,
      this.img10,
      this.img11,
      this.firstName,
      this.lastName,
      this.runName,
      this.bib,
      this.enrollmentId,
      this.speed,
      this.distance,
      this.duration,
      this.submit,
      this.challenge_name,
      this.template_affiliation});

  ChallengeVideoGenModel.fromJson(Map<String, dynamic> json) {
    img1 = json['img1'];
    img2 = json['img2'];
    img3 = json['img3'];
    img4 = json['img4'];
    img5 = json['img5'];
    img6 = json['img6'];
    img7 = json['img7'];
    img8 = json['img8'];
    img9 = json['img9'];
    img10 = json['img10'];
    img11 = json['img11'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    runName = json['run_name'];
    bib = json['bib'];
    enrollmentId = json['enrollment_id'];
    speed = json['speed'];
    distance = json['distance'];
    duration = json['duration'];
    submit = json['submit'];
    challenge_name:json['challenge_name'];
    template_affiliation=json['template_affiliation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['img1'] = this.img1;
    data['img2'] = this.img2;
    data['img3'] = this.img3;
    data['img4'] = this.img4;
    data['img5'] = this.img5;
    data['img6'] = this.img6;
    data['img7'] = this.img7;
    data['img8'] = this.img8;
    data['img9'] = this.img9;
    data['img10'] = this.img10;
    data['img11'] = this.img11;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['run_name'] = this.runName;
    data['bib'] = this.bib;
    data['enrollment_id'] = this.enrollmentId;
    data['speed'] = this.speed;
    data['distance'] = this.distance;
    data['duration'] = this.duration;
    data['submit'] = this.submit;
    return data;
  }
}
