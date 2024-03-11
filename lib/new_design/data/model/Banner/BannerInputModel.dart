import 'package:flutter/material.dart';

class BannerInputModel {
  String userId, userEmail;
  List affiliation;
  int pageStart, pageEnd;
  BannerInputModel({
    @required this.userId,
    @required this.userEmail,
    @required this.affiliation,
    @required this.pageStart,
    @required this.pageEnd,
  });
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_email': userEmail,
        'affiliations': affiliation,
        'pagination_start': pageStart,
        'pagination_end': pageEnd
      };
}
