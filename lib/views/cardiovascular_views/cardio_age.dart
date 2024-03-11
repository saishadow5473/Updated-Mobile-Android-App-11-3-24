import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CardioAge extends StatefulWidget {
  CardioAge({this.dob});
  final dob;
  @override
  _CardioAgeState createState() => _CardioAgeState();
}

class _CardioAgeState extends State<CardioAge> {
  String _date = "Not set";//"01/02/1999";//""Not set";
  bool notValidUser = false;
  bool _dateNotset = false;
  var newFormat = DateFormat("MM/dd/yyyy");
  void _initAsync() async {
    await SpUtil.getInstance();
    try{
      var cardio_age = SpUtil.getString('cardio_age');
      if(cardio_age.toString()!='null'){
        setState(() {
          _date = cardio_age;
        });
      }
    }
    catch(e){
      print(e.toString());
    }

    if(_date==''||_date =="Not set"){
      ///put the value from userDretail here
      if(widget.dob.toString()!='null'&& widget.dob!=''){
        setState(() {
          _date = widget.dob;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            if (_date != "Not set") {
              if (isAdult(_date) == true) {
                if (this.mounted) {
                  setState(() {
                    notValidUser = false;
                  });
                }
                SpUtil.putString('cardio_age', _date);
                // Navigator.of(context).pushNamed(Routes.Cgender);
                ///navigate to nxt page
                // setState(() {
                  currentIndexOfCardio.value=1;
                // });
              } else {
                if (this.mounted) {
                  setState(() {
                    notValidUser = true;
                    _dateNotset = false;
                  });
                }
              }
            } else {
              if (this.mounted) {
                setState(() {
                  _dateNotset = true;
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    AppTexts.continuee,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(16),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 4 * SizeConfig.heightMultiplier,
          ),
          Text(
            AppTexts.dob,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromRGBO(109, 110, 113, 1),
                fontFamily: 'Poppins',
                fontSize: ScUtil().setSp(26),
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1.33),
          ), SizedBox(
            height: 3 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Text(
              AppTexts.sub4,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(15),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
          SizedBox(
            height: 5 * SizeConfig.heightMultiplier,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                elevation: 0.0,
              ),
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      itemStyle: TextStyle(
                        color: Colors.black,
                      ),
                      cancelStyle: TextStyle(),
                      doneStyle: TextStyle(),
                      containerHeight: 210,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(1900, 1, 1),
                    maxTime: DateTime.now(), onConfirm: (date) {
                      String updatedDt = newFormat.format(date);
                      _date = updatedDt; //"${date.toLocal()}".split(' ')[0];
                      if (this.mounted) {
                        setState(() {});
                      }
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 18.0,
                                color: Color(0xFF19a9e5),
                              ),
                              Text(
                                " $_date",
                                style: TextStyle(
                                    color:
                                    Color(0xFF19a9e5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScUtil().setSp(18)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Color(0xFF19a9e5),
                          fontWeight: FontWeight.bold,
                          fontSize: ScUtil().setSp(18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _dateNotset == true
              ? SizedBox(
            height: 3 * SizeConfig.heightMultiplier,
            child: Text(
              'Please enter your Date of Birth',
              style: TextStyle(color: Colors.red),
            ),
          )
              : notValidUser == true
              ? SizedBox(
            height: 3 * SizeConfig.heightMultiplier,
            child: Text(
              'Attention! You need to be 13 years or older to register with hCare.',
              style: TextStyle(color: Colors.red),
            ),
          )
              : SizedBox(
            height: 2 * SizeConfig.heightMultiplier,
          ),
          SizedBox(
            height: 4 * SizeConfig.heightMultiplier,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: Center(
              child: _customButton(),
            ),
          ),
        ],
      ),
    );
  }
}

bool isAdult(String birthDateString) {
  String datePattern = "MM/dd/yyyy";

  // Current time - at this moment
  DateTime today = DateTime.now();

  // Parsed date to check
  DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

  // Date to check but moved 13 years + 3 leap days ahead
  DateTime adultDate = DateTime(
    birthDate.year + 13,
    birthDate.month,
    birthDate.day + 3,
  );

  return adultDate.isBefore(today);
}
