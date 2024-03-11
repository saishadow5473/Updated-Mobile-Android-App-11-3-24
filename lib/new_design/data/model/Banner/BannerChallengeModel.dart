// To parse this JSON data, do
//
//     final bannerChallenge = bannerChallengeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

BannerChallenge bannerChallengeFromJson(String str) => BannerChallenge.fromJson(json.decode(str));

String bannerChallengeToJson(BannerChallenge data) => json.encode(data.toJson());

class BannerChallenge {
  int totalcount;
  List<Datum> data;

  BannerChallenge({
    @required this.totalcount,
    @required this.data,
  });

  factory BannerChallenge.fromJson(Map<String, dynamic> json) => BannerChallenge(
        totalcount: json["totalcount"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalcount": totalcount,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String affiliations, bannerImgUrl, assosideId, challengeId, challengeName;
  bool isVarient;
  bool bannerVisibleInMainDashboard;
  bool bannerVisibleInSocialDashboard;

  Datum({
    @required this.affiliations,
    @required this.bannerImgUrl,
    @required this.isVarient,
    @required this.assosideId,
    @required this.challengeId,
    @required this.challengeName,
    @required this.bannerVisibleInMainDashboard,
    @required this.bannerVisibleInSocialDashboard,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        affiliations: json["affiliations"],
        bannerImgUrl: json["banner_img_url"],
        isVarient: json["is_varient"],
        assosideId: json["assoside_id"],
        challengeId: json["challenge_id"],
        challengeName: json["challenge_name"],
        bannerVisibleInMainDashboard: json["banner_visible_in_main_dashboard"],
        bannerVisibleInSocialDashboard: json["banner_visible_in_social_dashboard"],
      );

  Map<String, dynamic> toJson() => {
        "affiliations": affiliations,
        "banner_img_url": bannerImgUrl,
        "is_varient": isVarient,
        "assoside_id": assosideId,
        "challenge_id": challengeId,
        "challenge_name": challengeName,
        "banner_visible_in_main_dashboard": bannerVisibleInMainDashboard,
        "banner_visible_in_social_dashboard": bannerVisibleInSocialDashboard,
      };
}
