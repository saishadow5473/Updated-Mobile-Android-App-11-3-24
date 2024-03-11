import 'dart:io';

class SelfieImgUpload {
  SelfieImgUpload({
    this.enrollId,
    this.userid,
    this.challengeid,
    this.selfieImage,
  });

  String enrollId;
  String userid;
  String challengeid;
  File selfieImage;

  factory SelfieImgUpload.fromJson(Map<String, dynamic> json) => SelfieImgUpload(
        enrollId: json["enroll_id"],
        userid: json["userid"],
        challengeid: json["challengeid"],
        selfieImage: json["selfie_image"],
      );

  Map<String, dynamic> toJson() => {
        "enroll_id": enrollId,
        "userid": userid,
        "challengeid": challengeid,
        "selfie_image": selfieImage,
      };
}
