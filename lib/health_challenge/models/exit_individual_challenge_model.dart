class ExitIndividualChallenge {
  ExitIndividualChallenge({
    this.challengeId,
    this.enrollmentId,
    this.userId,
  });

  String challengeId;
  String enrollmentId;
  String userId;

  factory ExitIndividualChallenge.fromJson(Map<String, dynamic> json) => ExitIndividualChallenge(
        challengeId: json["challenge_id"],
        enrollmentId: json["enrollment_id"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "challenge_id": challengeId,
        "enrollment_id": enrollmentId,
        "user_id": userId,
      };
}
