import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget card(
    BuildContext context, var _title, var _icon, var _iconSize, var _bgColor, final Function onTap,
    {bool lessWidth}) {
  ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);

  // return Padding(
  //   padding: const EdgeInsets.all(2.5),
  //   child: Card(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     //   borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(15.0),
  //           bottomLeft: Radius.circular(15.0),
  //           bottomRight: Radius.circular(15.0),
  //           topRight: Radius.circular(15.0)),
  //     //       // topRight: Radius.circular(8.0)),
  //     ),
  //     elevation: 4,
  //     // color: AppColors.cardColor,
  //     color: FitnessAppTheme.white,
  return Container(
    margin: const EdgeInsets.only(
      left: 9.0,
      right: 9.0,
      top: 12.0,
    ),
    decoration: BoxDecoration(
      color: _title == 'Diabetics Health' ? Colors.grey.shade200 : FitnessAppTheme.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        bottomLeft: Radius.circular(15.0),
        bottomRight: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
        // topRight: Radius.circular(68.0)),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.2),
            offset: Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    ),

    child: InkWell(
      borderRadius: BorderRadius.circular(15.0),
      onTap: onTap,
      splashColor: _bgColor.withOpacity(0.5),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: ScUtil().setHeight(3.0),
        ),
        Center(
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(11.0),
                height: ScUtil().setHeight(60.0),
                width: ScUtil().setWidth(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _icon,
                  color: _bgColor,
                  size: _iconSize,
                ),
              ),
              SizedBox(
                width: ScUtil().setWidth(lessWidth.toString() == 'true' ? 10.0 : 30.0),
              ),
              Flexible(
                child: Text(
                  _title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    //fontWeight: FontWeight.w600,
                    fontSize: 18.px,
                    color: _title == 'Diabetics Health' ? Colors.grey : AppColors.primaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: ScUtil().setHeight(3.0),
        ),
      ]),
    ),
    // ),
  );
}

class Consultation {
  final String title;
  final String subtitle;
  final String price;
  final int index;
  Consultation({this.index, this.price, this.subtitle, this.title});
}

List<Consultation> consultationList = [
  Consultation(
    index: 1,
    title: "Cardio Issues?",
    price: "100",
    subtitle: "For cardio patient here can easily contact with doctor. Can book & live chat.",
  ),
  Consultation(
    index: 2,
    title: "Diet trouble?",
    price: "80",
    subtitle: "For Diet troubles, you can easily contact with Dietician. Can book & live chat.",
  ),
  Consultation(
    index: 3,
    title: "Fitness Issues?",
    price: "250",
    subtitle:
        "For Fitness & Yoga, you can easily connect with Trainer. Can subscribe & join classes.",
  ),
  Consultation(
    index: 4,
    title: "General Issues?",
    price: "500",
    subtitle: "For General issues, you can easily contact with doctor. Can book & live chat.",
  ),
  Consultation(
    index: 5,
    title: "Therapist?",
    price: "50",
    subtitle: "For therapist patients, you can easily contact with doctor. Can book & live chat.",
  ),
];

class ConsultationCard extends StatefulWidget {
  final Consultation consultation;
  final int index;
  ConsultationCard({this.consultation, this.index});

  @override
  _ConsultationCardState createState() => _ConsultationCardState();
}

class _ConsultationCardState extends State<ConsultationCard> {
  List consultationType = [];
  List list = [];

  Future getData(BuildContext context, var x) async {
    list.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    consultationType = teleConsulResponse['consult_type'];
    consultationType.map((e) => list.add(e['specality'])).toList();
    switch (x) {
      case 0:
        {
          Navigator.of(context).pushNamed(
            Routes.SelectConsultant,
            arguments: list[0][0],
          );
        }
        break;
      case 1:
        {
          Navigator.of(context).pushNamed(Routes.SelectConsultant, arguments: list[3][0]);
        }
        break;
      case 2:
        {
          Navigator.of(context).pushNamed(Routes.SelectClass, arguments: list[1][0]);
        }
        break;
      case 3:
        {
          Navigator.of(context).pushNamed(Routes.SelectConsultant, arguments: list[0][1]);
        }
        break;
      case 4:
        {
          Navigator.of(context).pushNamed(Routes.SelectClass, arguments: list[3][4]);
        }
        break;
      default:
        {
          Navigator.of(context).pushNamed(Routes.ConsultationType);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 18.0, bottom: 5.0),
      elevation: 6.0,
      color: CardColors.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: () async {
            var x = widget.index;
            await getData(context, x);
          },
          splashColor: AppColors.myApp.withOpacity(0.5),
          child: Container(
            width: ScUtil().setWidth(250.0),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Container(
                    width: ScUtil().setWidth(70.0),
                    height: ScUtil().setHeight(30.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFF19a9e5),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      "\₹${widget.consultation.price}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 30.0,
                  left: 15.0,
                  right: 18.0,
                  bottom: 15.0,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.consultation.title),
                        SizedBox(
                          height: ScUtil().setHeight(15.0),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: ScUtil().setWidth(2.0),
                                color: Color(0xFF19a9e5),
                              ),
                              SizedBox(
                                width: ScUtil().setWidth(12.0),
                              ),
                              Expanded(
                                child: Text(
                                  widget.consultation.subtitle,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
