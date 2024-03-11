
class SendInviteUserForChallenge {
  SendInviteUserForChallenge({
    this.challangeId,
    this.referredbyemail,
    this.referredbyname,
    this.refferredtoemail,
  });

  String challangeId;
  String referredbyemail;
  String referredbyname, refferredtoemail;

  factory SendInviteUserForChallenge.fromJson(Map<String, dynamic> json) =>
      SendInviteUserForChallenge(
        challangeId: json["challengeid"],
        referredbyemail: json["referred_by_email"],
        referredbyname: json["referred_by_name"],
        refferredtoemail: json['referred_to_email'],
      );

  Map<String, dynamic> toJson() => {
    "challengeid": challangeId,
    "referred_by_email": referredbyemail,
    "referred_by_name": referredbyname,
    'referred_to_email': refferredtoemail,
  };
}
