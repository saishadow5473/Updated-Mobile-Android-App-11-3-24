import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../clippath/badgeClipPath.dart';

// ignore: must_be_immutable
class AllChallengeTypeScreen extends StatelessWidget {
  AllChallengeTypeScreen({Key key}) : super(key: key);
  List checklist = [
    {"category": "Achived", "title": "walk now", "type": "group"},
    {"category": "Enrolled", "title": "start now", "type": "group"},
    {"category": "Achived", "title": "let's walk", "type": "individual"},
    {"category": "New", "title": "we can walk together", "type": "group"},
    {"category": "New", "title": "run now", "type": "individual"},
  ];
  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: AppBar(
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            )),
        title: Text(" Challenges", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
          children: checklist.map((e) {
        Color badgeColor = e["category"] == "Achived"
            ? Colors.green
            : e["category"] == "Enrolled"
                ? Colors.orange
                : AppColors.primaryColor;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              log(e.toString());
              // try {
              //   challengeDetail = await ChallengeApi().challengeDetail(challengeId: challangeID);
              //   Get.to(ChallengeDetailsScreen(
              //     fromNotification: false,
              //     challengeDetail: challengeDetail,
              //   ));
              // } catch (e) {
              //   Get.defaultDialog(title: 'Failed', middleText: "Something Went Wrong !");
              // }
            },
            child: Container(
              foregroundDecoration: BadgeDecoration(
                radius: 15,
                badgeColor: badgeColor,
                badgeSize: 50,
                textSpan: TextSpan(
                  text: e["category"],
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: "Poppins"),
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5), offset: Offset(1, 1), blurRadius: 5)
                  ],
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage("https://picsum.photos/id/237/200/300")),
                              color: Colors.blueAccent.shade200,
                              borderRadius: BorderRadius.circular(10)),
                          height: 55,
                          width: 55,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // width: Adaptive.w(60),
                            child: Text(
                              e["title"],
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            e["type"],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: MediaQuery.of(context).size.width * 0.03,
                            ),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList()),
    );
  }
}
