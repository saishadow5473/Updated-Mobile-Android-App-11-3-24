import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';

class ReviewsAndRatings extends StatelessWidget {
  String ratings;
  List ratingsList;
  ReviewsAndRatings({Key key, this.ratings, this.ratingsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List ratingsL = [
    //   {
    //     "rating_text": " ",
    //     "user_rating": 5,
    //     "user_name": "Janhavi Nagarajan",
    //     "time_stamp": "/Date(1657971731542)/"
    //   }
    // ];
    // ratingsList = ratingsL;
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Reviews and Ratings", style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ratingsList.isEmpty
            ? const Center(
                child: Text("No Ratings Yet"),
              )
            : Column(
                children: ratingsList.map((e) {
                  return ratingsCard(e['user_name'], e['rating_text'], "", e['time_stamp'],
                      e['user_rating'].toString());
                }).toList(),
                // children: [
                //   ratingsCard('Adam Henry', 'So far So Good', ''),
                //   ratingsCard('Adam Henry', 'Eyes opening session', '')
                // ],
              ),
      ),
    );
  }

  Card ratingsCard(String name, String review, String photo, String time, String rat) {
    return Card(
      elevation: 0.5,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                'https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-Vector-PNG-Pic.png',
                              ),
                              fit: BoxFit.cover)),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name),
                        Text(
                          getPastString(time),
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(review)
              ],
            ),
            Container(
              width: 16.w,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 142, 201, 250),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  Text(rat.toString())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  DateTime parseTimestamp(String timestamp) {
    // Extract milliseconds from the timestamp string
    int milliseconds = int.parse(timestamp.substring(6, timestamp.length - 2));

    // Create a DateTime object from milliseconds
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String getPastString(timestampString) {
    // String timestampString = "/Date(1657971731542)/";
    DateTime dateTime = parseTimestamp(timestampString);

    // Calculate the difference between the current date and the converted date
    Duration difference = DateTime.now().difference(dateTime);

    // Convert the duration to a human-readable string
    String result = formatDuration(difference);
    print(result);
    // Output: "X days ago"
    return result;
  }
}
