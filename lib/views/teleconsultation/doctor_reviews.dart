import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// user review 🌟🌟🌟🌟🌟
class ConsultantReviews extends StatelessWidget {
  final String userRatingText;
  final int userRating;
  final List reviews;
  const ConsultantReviews({Key key, this.userRatingText,this.userRating, this.reviews}) : super(key: key);

  Widget createReview(Map map) {
    if (map == null || map.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            children: [
              SmoothStarRating(
                  allowHalfRating: false,
                  onRated: (v) {},
                  starCount: 5,
                  rating: double.tryParse(map['user_rating'].toString()) ?? 0.0,
                  size: 20.0,
                  isReadOnly: true,
                  color: Colors.orange,
                  borderColor: Colors.orange,
                  spacing: 0.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '${map['user_name']}' ?? "",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '${map['rating_text']}' ?? "",
            textAlign: TextAlign.justify,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          reviews.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No reviews yet '),
          )
              : Column(
            children: reviews.map((e) => createReview(e)).toList(),
          ),
        ],
      ),
    );
  }
}
