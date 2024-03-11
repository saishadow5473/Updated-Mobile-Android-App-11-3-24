import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../utils/app_colors.dart';
import '../models/challenge_detail.dart';

class CustomStartChallengeTile extends StatelessWidget {
  CustomStartChallengeTile({Key key, @required this.challengeDetail}) : super(key: key);
  ChallengeDetail challengeDetail;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 45,
              width: 55,
              child: CircleAvatar(
                backgroundImage: NetworkImage(challengeDetail.challengeImgUrlThumbnail),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                        fontSize: Device.height < 600 ? 15 : 16,
                        color: Colors.grey,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w600),
                    text: challengeDetail.challengeName),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 4, 15),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                "Challenge will start on ",
                style: TextStyle(
                  fontSize: Device.height < 600 ? 12 : 12,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                DateFormat('MM-dd-yyyy').format(challengeDetail.challengeStartTime),
                style: TextStyle(
                    fontSize: Device.height < 600 ? 12 : 12,
                    color: Colors.lightBlue,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                " at ",
                style: TextStyle(
                  fontSize: Device.height < 600 ? 12 : 12,
                  color: Colors.black,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                DateFormat('HH:mm aa').format(challengeDetail.challengeStartTime),
                style: TextStyle(
                    fontSize: Device.height < 600 ? 12 : 12,
                    color: Colors.lightBlue,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              primary:
                  DateFormat('MM-dd-yyyy').format(challengeDetail.challengeStartTime).toString() !=
                              "01-01-2000" &&
                          DateTime.now().isAfter(challengeDetail.challengeStartTime)
                      ? AppColors.primaryAccentColor
                      : Colors.grey,
            ),
            onPressed: () {},
            child: Text('Start',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Popins',
                    color: Colors.white)),
          ),
        )
      ],
    );
  }
}
