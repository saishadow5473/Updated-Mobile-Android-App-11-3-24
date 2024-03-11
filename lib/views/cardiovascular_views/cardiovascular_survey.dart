import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/cardiovascular_views/cardio_age.dart';
import 'package:ihl/views/cardiovascular_views/cardio_cholestrol.dart';
import 'package:ihl/views/cardiovascular_views/cardio_cvd.dart';
import 'package:ihl/views/cardiovascular_views/cardio_diabetes.dart';
import 'package:ihl/views/cardiovascular_views/cardio_gender.dart';
import 'package:ihl/views/cardiovascular_views/cardio_hdl.dart';
import 'package:ihl/views/cardiovascular_views/cardio_ht.dart';
import 'package:ihl/views/cardiovascular_views/cardio_hypertension.dart';
import 'package:ihl/views/cardiovascular_views/cardio_isSmoker.dart';
import 'package:ihl/views/cardiovascular_views/cardio_wt.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/re_designed_home_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ihl/widgets/cardiovascular/cardiovascular_card_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardio_ldl.dart';

var currentIndexOfCardio = ValueNotifier<int>(0);

class CardiovascularSurvey extends StatefulWidget {
  const CardiovascularSurvey();

  @override
  State<CardiovascularSurvey> createState() => _CardiovascularSurveyState();
}

class _CardiovascularSurveyState extends State<CardiovascularSurvey> {
  // var currentIndexOfCardio = 0;
  // final dataKey =  GlobalKey();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();


  var __vitals;
  var __age;
  var __gender;
  var __height;
  var __weight;
  @override
  void initState() {
    getUserData();
    super.initState();
  }
  getUserData() async{
    ///get the user data and age,gender,height,weight,lastCheckin
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var res = jsonDecode(data);
     __vitals = res["LastCheckin"];
    if (__vitals != null) {
      __vitals.removeWhere((key, value) =>
      // key != "dateTimeFormatted" &&
      key != "dateTime" &&
          //pulsebpm
          key != "diastolic" &&
          key != "systolic" &&
          key != "pulseBpm" &&
          key != "bpClass" &&
          //BMC
          key != "fatRatio" &&
          key != "fatClass" &&
          key != "percent_body_fat" &&
          key != "percent_body_sdf_fat" &&

          //ECG
          key != "leadTwoStatus" &&
          key != "ecgBpm" &&
          //BMI
          key != "weightKG" &&
          key != "heightMeters" &&
          key != "bmi" &&
          key != "bmiClass" &&
          //spo2
          key != "spo2" &&
          key != "spo2Class" &&
          //temprature
          key != "temperature" &&
          key != "temperatureClass");
      __vitals.forEach((key, value) {
        if (key == "weightKG") {
          __vitals["weightKG"] = double.parse((value).toStringAsFixed(2));
        }
        if (key == "heightMeters") {
          __vitals["heightMeters"] = double.parse((value).toStringAsFixed(2));
        }
      });
      __vitals.removeWhere((key, value) => value == "");
    }

    print(__vitals);
    setState(() {
      __age = res['User']['dateOfBirth'];
    });
    __gender = res['User']['gender'];
    __height = res['User']['heightMeters'];
    try{
      __weight = res['User']['UserInputWeight']??res["User"]["userInputWeightInKG"];
    }
    catch(e){print(e.toString());}
if((__weight.toString()=="null"||__weight.toString()=="")&&__vitals.toString()!="null"&&__vitals.toString()!="[]"){
  try{
    __weight = __vitals['weightKG'];
  }
  catch(e){
    print(e.toString());
  }
}
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        allowFontScaling: true);
    return DietJournalUI(
      backgroundColor: FitnessAppTheme.nearlyWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () {
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => HomeScreen(
            //         introDone: true,
            //       ),
            //     ),
            //         (Route<dynamic> route) => false);
            Navigator.pop(context);
          }
        ),
        title: Text(
          "Cardio Health",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500,color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: FitnessAppTheme.nearlyWhite,
              height: 140,
              child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                scrollDirection: Axis.horizontal,
                itemCount: Questionss.length,
                itemBuilder: (context,index){
                  return ValueListenableBuilder(
                    valueListenable: currentIndexOfCardio,
                    builder: (context, value, widget){
                      if(value%2!=0&&value>1){
                        itemScrollController.scrollTo(
                            index: value,
                            duration: Duration(seconds: 2),
                            curve: Curves.easeInOutCubic);
                      }
                      return GestureDetector(
                        onTap: (){
                          ///for development person uncommented line  92 otherwise comment it
                          // currentIndexOfCardio.value = index;
                        },
                        child: Transform.scale(
                          scale: index==value?1.05:1.0,
                          child: Container(
                            // key: dataKey,
                            // height: 40,
                            margin: const EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 3,color: index==value?AppColors.primaryAccentColor:FitnessAppTheme.grey.withOpacity(0.1)),
                              // border: Border(
                              //   left: BorderSide(width: 3,color: AppColors.primaryAccentColor),
                              //   right: BorderSide(width: 3,color: AppColors.primaryAccentColor),
                              //   bottom: BorderSide(width: 3,color: AppColors.primaryAccentColor),
                              //   top: BorderSide(width: 3,color: AppColors.primaryAccentColor),
                              // ),
                              color: FitnessAppTheme.white,
                              // color: AppColors.primaryAccentColor,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                  child: Image.asset(Questionss[index]['img'],fit: BoxFit.cover),
                                  height: 60,
                                  width: 65,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      // color: AppColors.primaryAccentColor,
                                      color: index==value?AppColors.primaryAccentColor:FitnessAppTheme.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4)
                                  ),
                                  height: 20,
                                  width: 65,
                                  child: Text(Questionss[index]['name'],textAlign: TextAlign.center,
                                  style: TextStyle(color: index==value?Colors.white:FitnessAppTheme.grey.withOpacity(0.9),fontFamily: 'Poppins',),
                                  // maxFontSize: 14,
                                  //   minFontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Text(Questionss[currentIndexOfCardio]),
            // Questionss[currentIndexOfCardio],
            Visibility(
              visible: __age!=null,
              replacement: CircularProgressIndicator(),
              child: ValueListenableBuilder(valueListenable: currentIndexOfCardio,
                  builder:(context,value,widget) {
                return methh(value);
                  } ),
            ),


            // CardioAge(),
          ],
        ),
      ),
    );
  }
  // methh(value) {
  //   if(value==0){
  //     return CardioAge(dob: __age,);
  //   }
  //   else if(value==1){
  //     return CardioGen(gen: __gender,);
  //   }
  //   else if(value==2) {
  //     return CardioHt(height: __height.toString());
  //   }else if(value==3){
  //     return CardioWt(weight: __weight.toString(),);
  //   }else if(value==4){
  //     return CardioCholesterol();
  //   }else if(value==5){
  //     return CardioLdl();
  //   }else if(value==6){
  //     return CardioHdl();
  //   }else if(value==7){
  //     return CardioIsSmoker();
  //   }else if(value==8){
  //     return CardioFamilyDiabetes();
  //   }else if(value==9||value==10){
  //     return CardioFamilyHypertension();
  //   }
  //   // else if(value==10){
  //   //   return CardioFamilyCvd();
  //   // }
  // }

  methh(value) {
    if(value==0){
        return CardioGen(gen: __gender,);
    }
    else if(value==1) {

      return CardioCholesterol();
    }else if(value==2){

      return CardioIsSmoker();
    }else if(value==3){
      return CardioFamilyDiabetes();
    }else if(value==4||value==5){
      return CardioFamilyHypertension();
    }
    // else if(value==10){
    //   return CardioFamilyCvd();
    // }
  }
}


List Questionss = [
  //{'img':'assets/images/cardio/dob.png','name':'Age'},
  {'img':'assets/images/cardio/gen.png','name':'Gender'},
  //{'img':'assets/icons/h1.png','name':'Height'},
  //{'img':'assets/icons/weight.png','name':'Weight'},
  {'img':'assets/images/cardio/cholesterol (3).png','name':'Cholesterol'},
  //{'img':'assets/images/cardio/ldl.png','name':'L. D. L.'},
  //{'img':'assets/images/cardio/hdl2.png','name':'H. D. L.'},
  {'img':'assets/images/cardio/no_smokey.png','name':'Tobacco'},
  {'img':'assets/images/cardio/diabeties.png','name':'Diabetes'},
  {'img':'assets/images/cardio/hypertension.png','name':'B P'},//Hypertension
  // {'img':'assets/images/cardio/cvd.png','name':'Covid'},
];

class CardioQIconWidget extends StatefulWidget {
   CardioQIconWidget();


  @override
  _CardioQIconWidgetState createState() => _CardioQIconWidgetState();
}

class _CardioQIconWidgetState extends State<CardioQIconWidget> {
  @override
  Widget build(BuildContext context) {

    return Container(
      color: FitnessAppTheme.nearlyWhite,
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                // setState(() {
                  currentIndexOfCardio.value = index;
                // });
                // openTocDialog(context);
              },
              color: FitnessAppTheme.white,
              highlightColor: Color(0xFF89b9f0),
              textColor: Colors.white,
              child: Icon(
                FontAwesomeIcons.userMd,
                size: 35,
                color: AppColors.primaryAccentColor,
              ),
              padding: EdgeInsets.all(14),
              shape: CircleBorder(
                  side: BorderSide(
                    width: 2,
                    color: index==currentIndexOfCardio.value?Colors.green:FitnessAppTheme.grey.withOpacity(0.2),
                  )
              ),
              elevation: 0,
            ),
          );
        },
      ),
    );
  }
}
