import 'package:flutter/material.dart';
import 'package:ihl/models/surveyQuestion.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class FollowUpDialog extends StatefulWidget {
  FollowUpDialog({Key key, this.surveyQuestion});
  SurveyQuestion surveyQuestion;

  @override
  _FollowUpDialogState createState() => _FollowUpDialogState();
}

class _FollowUpDialogState extends State<FollowUpDialog> {
  SurveyQuestion _surveyQuestion;
  @override
  void initState() {
    super.initState();
    _surveyQuestion = widget.surveyQuestion;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SimpleDialog(
        title: Text(_surveyQuestion.question,style: TextStyle(
          fontSize: 17.5.sp,
        )),
        children: [
          Center(
            child: _surveyQuestion.qid == 'D3Yes'
                ? CheckboxWidget()
                : DropdownButton<SurveyOption>(
                    hint: Text(_surveyQuestion.answer != null
                        ? _surveyQuestion.answer.mainAnswer.status
                        : 'Choose your Status',
                        style: TextStyle(
                          fontSize: 15.5.sp,
                        )),
                    items: _surveyQuestion.options
                        .map((e) => DropdownMenuItem(
                              child: Row(
                                children: [
                                  Text(e.mainAnswer.status,style: TextStyle(
                                    fontSize: 15.5.sp,
                                  )),
                                  e.mainAnswer.range == null
                                      ? null
                                      : Text(' ' + e.mainAnswer.range,
                                          style: TextStyle(fontSize: 3.sp))
                                ],
                              ),
                              value: e,
                            ))
                        .toList(),
                    onChanged: (e) {
                      _surveyQuestion.answer = e;
                      if (this.mounted) {
                        setState(() {
                          _surveyQuestion.answer = e;
                        });
                      }
                    }),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 40.sp),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _surveyQuestion.qid == 'D3Yes'
                    ? Navigator.of(context).pop(_surveyQuestion)
                    : Navigator.of(context).pop(_surveyQuestion);
              },
            ),
          )
        ],
      ),
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  @override
  CheckboxWidgetState createState() => new CheckboxWidgetState();
}

class CheckboxWidgetState extends State {
  List<String> tmpArray = List<String>();
  Map<String, bool> values = {
    'Diabeties': false,
    'Thyroid': false,
    'Heart Problems': false,
    'High Cholestrol': false,
    'High Blood Pressure': false,
    'Other': false,
  };

  getCheckboxItems() {
    values.forEach((key, value) {
      if (value == true) {
        if (key == 'Diabeties') {
          tmpArray.add('diabeties');
        } else if (key == 'Thyroid') {
          tmpArray.add('thyroid');
        } else if (key == 'Heart Problems') {
          tmpArray.add('heart_problems');
        } else if (key == 'High Cholestrol') {
          tmpArray.add('high_cholesterol_level');
        } else if (key == 'High Blood Pressure') {
          tmpArray.add('high_blood_pressure_level');
        } else if (key == 'Other') {
          tmpArray.add('other');
        }
      }
    });
    tmpArray.clear();
    return tmpArray;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 300,
        width: double.maxFinite,
        child: Column(children: <Widget>[
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: values.keys.map((String key) {
                return new CheckboxListTile(
                  title: new Text(key),
                  value: values[key],
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  onChanged: (bool value) {
                    if (this.mounted) {
                      setState(() {
                        values[key] = value;
                        getCheckboxItems();
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
