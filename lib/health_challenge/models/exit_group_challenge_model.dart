class ExitGroupChallenge {
  ExitGroupChallenge({
    this.userId,
    this.groupId,
    this.challengeId,
  });

  String userId;
  String groupId;
  String challengeId;

  factory ExitGroupChallenge.fromJson(Map<String, dynamic> json) => ExitGroupChallenge(
        userId: json["user_id"],
        groupId: json["group_id"],
        challengeId: json["challenge_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "group_id": groupId,
        "challenge_id": challengeId,
      };
}
