import 'package:flutter/material.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// user review 🌟🌟🌟🌟🌟
class Reviews extends StatelessWidget {
  final List reviews;
  const Reviews({Key key, this.reviews}) : super(key: key);
  Widget createReview(Map map) {
    if (map == null || map.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            left: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: ScUtil().setWidth(145),
                child: Text('${map['user_name']} :' ?? "",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SmoothStarRating(
                    allowHalfRating: false,
                    onRated: (v) {},
                    starCount: 5,
                    rating:
                        double.tryParse(map['user_rating'].toString()) ?? 0.0,
                    size: 20.0,
                    isReadOnly: true,
                    color: Colors.orange,
                    borderColor: Colors.orange,
                    spacing: 0.0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        map['rating_text'] != ""
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: Text(
                  '${map['rating_text']}' ?? "",
                  textAlign: TextAlign.justify,
                ),
              ),
        Divider(
          thickness: 2,
        ),
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
