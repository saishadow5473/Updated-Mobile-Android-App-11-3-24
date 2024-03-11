import 'dart:io';

class PersistentUploadScreenShot {
  PersistentUploadScreenShot({
    this.enrollId,
    this.userId,
    this.challengeid,
    this.testimg,
  });

  String enrollId;
  String userId;
  String challengeid;
  File testimg;

  // factory PersistentUploadScreenShot.fromJson(Map<String, dynamic> json) =>
  //     PersistentUploadScreenShot(
  //       enrollId: json["enroll_id"],
  //       userId: json["user_id"],
  //       challengeid: json["challengeid"],
  //       testimg: json["testimg"],
  //     );

  Map<String, dynamic> toJson() => {
        "enroll_id": enrollId,
        "user_id": userId,
        "challengeid": challengeid,
        "testimg": testimg,
      };
}
