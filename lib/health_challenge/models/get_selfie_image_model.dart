import 'dart:convert';

SelifeImageData selifeImageDataFromJson(String str) => SelifeImageData.fromJson(json.decode(str));

String selifeImageDataToJson(SelifeImageData data) => json.encode(data.toJson());

class SelifeImageData {
  SelifeImageData({
    this.enrollId,
    this.userid,
    this.challengeid,
    this.userUploadedImageUrl,
    this.userUploadedImageUrlThumbnail,
    this.filename,
  });

  String enrollId;
  String userid;
  String challengeid;
  String userUploadedImageUrl;
  String userUploadedImageUrlThumbnail;
  String filename;

  factory SelifeImageData.fromJson(Map<String, dynamic> json) => SelifeImageData(
        enrollId: json["enroll_id"],
        userid: json["userid"],
        challengeid: json["challengeid"],
        userUploadedImageUrl: json["user_uploaded_image_url"],
        userUploadedImageUrlThumbnail: json["user_uploaded_image_url_thumbnail"],
        filename: json["filename"],
      );

  Map<String, dynamic> toJson() => {
        "enroll_id": enrollId,
        "userid": userid,
        "challengeid": challengeid,
        "user_uploaded_image_url": userUploadedImageUrl,
        "user_uploaded_image_url_thumbnail": userUploadedImageUrlThumbnail,
        "filename": filename,
      };
}
