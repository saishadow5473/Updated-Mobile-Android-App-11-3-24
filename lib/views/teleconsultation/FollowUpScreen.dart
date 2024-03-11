import 'package:ihl/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:ihl/widgets/BasicPageUI.dart';

/// Follow up screen 👀👀
class FollowUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
              ),
              Text(
                AppTexts.followupTitle,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
          SizedBox(
            height: 40,
          )
        ],
      ),
      body: FollowupList(),
    );
  }
}
