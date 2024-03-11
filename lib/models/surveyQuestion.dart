import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ihl/views/survey/dialog.dart';

class SurveyQuestion {
  String question;
  Image icon;
  String qid;
  List<SurveyOption> options = [];
  bool showStatus;
  SurveyOption answer;
  Map completeMap;
  int value;
  SurveyQuestion(Map q, {preset}) {
    qid = q['q_id'];
    showStatus = q['showStatus'];
    question = q['name'].toString();
    completeMap = q;
    if (preset[qid] is String) {
      value = int.tryParse(preset[qid]);
    }
    if (preset[qid] is double) {
      value = preset[qid].toInt();
    }
    if (preset[qid] is int) {
      value = preset[qid];
    }

    if (value == null) {
      value = 0;
    }
    List op = q['option'];
    op.forEach((element) {
      options.add(SurveyOption(
          complete: completeMap, current: element, presets: preset));
    });
    answer = options[value];
  }
  // ignore: missing_return
  Future<SurveyQuestion> selectFromIndex(int i, BuildContext context) async {
    answer = options[i];
    value = i;
    if (answer.hasExtra) {
      return await answer.selectDialog(context: context);
    }
  }
}

class SurveyOption {
  Option mainAnswer;
  bool hasExtra = false;
  SurveyQuestion extra;
  SurveyOption({Map complete, current, presets}) {
    mainAnswer = Option(current);
    if (complete[mainAnswer.value] != null &&
        complete[mainAnswer.value]['option'] != [] &&
        complete[mainAnswer.value]['option'] is List &&
        !complete[mainAnswer.value]['option'].isEmpty) {
      extra = SurveyQuestion(complete[mainAnswer.value], preset: presets);
      hasExtra = true;
    }
  }

  Future<SurveyQuestion> selectDialog({BuildContext context}) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
        return Container(
            child: FollowUpDialog(
          surveyQuestion: extra,
        ));}
        );

  }
}

class Option {
  String value;
  String status;
  String range;
  Option(m) {
    if (m is String) {
      range = m;
      value = m;
      status = m;
    }
    if (m is Map) {
      value = m['value'].toString();
      range = m['range'].toString();
      status = m['status'].toString();
    }
  }
  String getJson() {
    return jsonEncode(createMap());
  }

  Map createMap() {
    return {"status": status, "range": range, "value": value};
  }
}
