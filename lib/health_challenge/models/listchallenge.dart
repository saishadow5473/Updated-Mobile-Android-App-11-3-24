import 'enrolled_challenge.dart';
import 'challenge_detail.dart';

class ListChallenge {
  final String challenge_mode, email;
  final int pagination_start, pagination_end;
  final List affiliation_list;

  ListChallenge(
      {this.challenge_mode,
      this.email,
      this.pagination_start,
      this.pagination_end,
      this.affiliation_list});
  Map<String, dynamic> toJson() => {
        "challenge_mode": "",
        "affiliation_list": affiliation_list,
        "user_email": email,
        "pagination_start": pagination_start,
        "pagination_end": pagination_end
      };
}
class ListBadges {
  final String user_id, email;
  final int pagination_start, pagination_end;
  final List affiliation_list;


  ListBadges(
      {this.affiliation_list,
        this.user_id,
        this.email,
        this.pagination_start,
        this.pagination_end});
  Map<String, dynamic> toJson() => {
    "affiliation_list": affiliation_list,
    "user_id": user_id,
    "user_email": email,
    "pagination_start": pagination_start,
    "pagination_end": pagination_end
  };
}

class Badge {
  String challengeId;
  String enrollementStatus;
  String challengeBadgeImgUrl;
  String challengeName;
  ChallengeDetail challengeDetail;
  EnrolledChallenge enrolledChallenge;

  Badge({
    this.challengeId,
    this.enrollementStatus,
    this.challengeBadgeImgUrl,
    this.challengeName,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    challengeId: json["challenge_id"],
    enrollementStatus: json["enrollement_status"],
    challengeBadgeImgUrl: json["challenge_badge_img_url"],
    challengeName: json["challenge_name"],
  );

  Map<String, dynamic> toJson() => {
    "challenge_id": challengeId,
    "enrollement_status": enrollementStatus,
    "challenge_badge_img_url": challengeBadgeImgUrl,
    "challenge_name": challengeName,
  };
}