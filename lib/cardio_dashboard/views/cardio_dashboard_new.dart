import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../new_design/data/model/healthTipModel/healthTipModel.dart';
import '../../new_design/data/providers/network/apis/healthTipsApi/healthTipsData.dart';
import '../../new_design/presentation/Widgets/appBar.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../new_design/presentation/pages/manageHealthscreens/myVitalsScreens/myVitalsGraphScreen.dart';
import '../../new_design/presentation/pages/onlineServices/SearchByDocAndList.dart';
import '../controllers/getx_controller_cardio.dart';
import '../widgets/custom_diet_card_cardio.dart';
import '../widgets/custom_vital_card_cardio.dart';
import '../../constants/api.dart';
import '../../constants/spKeys.dart';
import '../../models/DailyTipsDataModel.dart';
import '../../new_design/app/utils/appText.dart';
import '../../new_design/app/utils/imageAssets.dart';
import '../../repositories/new_dashboard_navigation.dart';
import '../../views/gamification/dateutils.dart';
import '../../views/newScreens/dashboard_navigation.dart';
import '../../views/screens.dart';
import '../../views/tips/tips_screen.dart';
import '../../widgets/BasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/recommended_food._model.dart';
import '../../utils/app_colors.dart';
import '../../views/cardiovascular_views/InfoScreen.dart';
import '../../views/cardiovascular_views/cardio_dashboard.dart';
import '../../views/dietJournal/MealTypeScreen.dart';
import '../../views/dietJournal/apis/list_apis.dart';
import '../widgets/custom_activity_tile_cardio.dart';
import '../widgets/custom_article_tile_cardio.dart.dart';
import '../widgets/custom_expertconsultant_tile_cardio.dart';
import '../widgets/score_meter_cardio.dart';

class CardioDashboardNew extends StatefulWidget {
  CardioDashboardNew({Key key, this.cond, this.tabView}) : super(key: key);
  bool cond;
  bool tabView = false;

  @override
  State<CardioDashboardNew> createState() => _CardioDashboardNewState();
}

class _CardioDashboardNewState extends State<CardioDashboardNew> {
  // bool load = true;
  @override
  void initState() {
    super.initState();
    getData();
    getTipsData();
    retrieveMedicalData();
    getRecommendedActivity();
  }

  @override
  void dispose() {
    super.dispose();
    _cardioController.updatebp = false;
  }

  // void loadData() async {
  //   setState(() {
  //     load = false; // tells to show our loaded data.
  //   });
  // }
  final TabBarController _tabController = Get.find() ?? Get.put(TabBarController());
  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.lightBlueAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32.0),
    ),
  );

  _showDialog({Widget content}) async {
    await showDialog<String>(
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recommended Diet',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            content,
          ],
        ),
      ),
      context: context,
    );
  }

  final CardioGetXController _cardioController = Get.put(CardioGetXController());
  List<TipsModel> tipsList = [];
  final http.Client _client = http.Client(); //3gb
  bool loading = true;

  getTipsData() async {
    String affi = UpdatingColorsBasedOnAffiliations.ssoAffiliation == null
        ? "global_services"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    List<HealthTipsModel> resultTips = await HealthTipsData().healthTipsData(affiUnqiueName: affi);
    // final http.Response
    //  resultTips = await _client.get(
    //   Uri.parse("${API.iHLUrl}/pushnotification/retrieve_healthtip_data"),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'ApiToken': '${API.headerr['ApiToken']}',
    //     'Token': '${API.headerr['Token']}',
    //   },
    // );
    List<TipsModel> result = <TipsModel>[];
    try {
      resultTips
          .map((HealthTipsModel e) => result.add(TipsModel(
              health_tip_blob_url: e.healthTipBlobUrl,
              health_tip_blog_thum_url: e.healthTipBlobThumbNailUrl,
              health_tip_id: e.healthTipId,
              health_tip_log: e.healthTipLog,
              health_tip_title: e.healthTipTitle,
              message: e.message)))
          .toList();
      // if (resultTips.statusCode == 200) {
      //   if (resultTips.body != "" && resultTips.body != null) {
      //     var decValue = json.decode(resultTips.body);
      //     for (Map i in decValue) {
      //       String message = i["message"];
      //       message = message.replaceAll('&amp;', '&');
      //       message = message.replaceAll('&quot;', '"');
      //       message = message.replaceAll("\\r\\n", '');

      //       TipsModel value = TipsModel(
      //           health_tip_id: i["health_tip_id"],
      //           health_tip_title: i["health_tip_title"],
      //           message: message,
      //           health_tip_log: i["health_tip_log"],
      //           health_tip_blob_url: i["health_tip_blob_url"],
      //           health_tip_blog_thum_url: i['health_tip_blob_thumb_nail_url']);
      //       result.add(value);
      //     }
      //     setState(() {
      //       tipsList = result;
      //       loading = false;
      //     });
      //   }
      // }
      if (mounted) {
        setState(() {
          tipsList = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tipsList = result;
          loading = false;
        });
      }
    }
  }

  final List _answers = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ];
  List _recommendedDietMenuList = [];
  bool _foodandactivityLoaded = true;
  final List<String> _foodMealType = [
    'Log Food',
    'Log Food',
    'Log Food',
    'Log Food',
  ];
  List<MealsListData> mealsListData = [];
  final List<String> _lastRetrieveKeys = [
    'systolic_blood_pressure',
    'diastolic_blood_pressure',
    'weight',
    'Cholesterol',
    'ldl',
    'hdl',
    'is_smoker',
    'has_family_history_diabetes',
    'has_family_history_hypertension',
    'on_statin',
    'on_aspirin_theraphy',
    'region',
    'food_preference'
  ];
  String _smokerType = 'N/A', _token = '';
  Map _lastRetriveData;
  Map vitals;
  String temp_score = '';
  String txt = 'Intermediate';
  dynamic clr = Colors.yellow;
  double score = 0.0;
  bool getScoreComplete = false, _haveScore = false, hasBp = false, bPStatus = false;
  final TextEditingController _textController = TextEditingController();
  var cholesterol;

  List<TextInputFormatter> numberOnly = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    FilteringTextInputFormatter.digitsOnly,
  ];

  Map<String, dynamic> _recommendedActivityList;

  List<dynamic> _walking = [];
  List<dynamic> _sports = [];
  List<dynamic> _yoga = [];
  List<dynamic> _activities = [];

  calculatestatus(score) async {
    txt = score >= 20
        ? 'High'
        : score < 20 && score >= 7.5
            ? 'Intermediate'
            : score < 7.5 && score >= 5
                ? 'Borderline'
                : 'Low';
    if (clr == Colors.yellow) {
      clr = await colorForStatus(txt);
    }
    return txt;
  }

  colorForStatus(status) {
    if (status == 'Low') {
      // return Colors.lightGreenAccent.shade400;
      return Colors.lightGreenAccent.shade700.withOpacity(1.0);
    } else if (status == 'Borderline') {
      return const Color(0xffff9800);
    } else if (status == 'Intermediate') {
      return Colors.orange.shade200;
    } else if (status == 'High') {
      return Colors.redAccent.shade400;
    }
  }

  Future retrieveMedicalData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
    final http.Response response = await http.post(
      Uri.parse('${API.iHLUrl}/empcardiohealth/retrieve_medical_data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"ihl_user_id": iHLUserId}),
    );

    if (response.statusCode == 200) {
      List resList = json.decode(response.body);
      if (resList.isNotEmpty) {
        _lastRetriveData = resList[0];
        temp_score = _lastRetriveData['score'].toString();
        score = double.parse(temp_score);
        calculatestatus(score);
        for (int i = 0; i <= _lastRetrieveKeys.length - 1; i++) {
          if (i < 6) {
            _answers[i] = _lastRetriveData[_lastRetrieveKeys[i]].toInt().toString();
          } else {
            _answers[i] = _lastRetriveData[_lastRetrieveKeys[i]].toString().contains('true')
                ? 'yes'
                : _lastRetriveData[_lastRetrieveKeys[i]].toString().contains('false')
                    ? 'no'
                    : _lastRetriveData[_lastRetrieveKeys[i]].toString();
          }
          if (i == 6) {
            if (_lastRetriveData['is_smoker'] == true ||
                _lastRetriveData['is_smoker'] == 'notGiven') {
              _smokerType = _lastRetriveData['smoker_type'] ?? 'N/A';
            }
          } else if (i == 0) {
            _textController.text = _answers[0];
          }
        }
        _haveScore = true;
        if (mounted) {
          setState(() {
            // oldUi = false;
            // _vitalLoaded = false;
          });
        }
      } else {
        for (int i = 0; i <= 3; i++) {
          switch (i) {
            case 0:
              if (vitals == null) {
                String systolicG = '';
                _answers[0] = systolicG;
                _textController.text = _answers[0];
              } else {
                String systolicG = vitals["systolic"].toString() ?? '';
                _answers[0] = systolicG;
                _textController.text = _answers[0];
              }
              break;
            case 1:
              if (vitals == null) {
                String diastolicG = '';
                _answers[1] = diastolicG;
              } else {
                String diastolicG = vitals["diastolic"].toString() ?? '';
                _answers[1] = diastolicG;
              }
              break;
            case 2:
              // double weight = double.parse(_weight.toString());
              //  _answers[2] = weight.toStringAsFixed(2).toString() ?? "";
              break;
          }
        }
        // if (mounted) setState(() => oldUi = true);
      }
    }
    getRecommendedFood();
  }

  Future getRecommendedFood() async {
    http.Response res = await http.post(Uri.parse('${API.iHLUrl}/empcardiohealth/recommended_food'),
        body: json.encode({
          //"meal_type": "mid_meal", //early_morning breakfast mid_meal
          "cholesterol": "yes",
          "hypertension": "yes",
          "visceral_fats": "yes",
          "dish_type": _answers[12] == "notGiven"
              ? "all"
              : _answers[12].toString() == "veg"
                  ? 'all'
                  : _answers[12], // _answers[11], //eggetarianAndNonveg,nonVeg,all
          // "region": _answers[11] == "notGiven" ? [""] : [_answers[11].substring(0, 1)]
          "region": ["n", "s"]
        }));
    if (res.statusCode == 200) {
      _recommendedDietMenuList = json.decode(res.body);

      sortingMeal();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _foodandactivityLoaded = false;
      if (mounted) setState(() {});
    }
  }

  sortingMeal() {
    List foodList = _recommendedDietMenuList;
    List breakFast = [], lunch = [], dinner = [], snacks = [];
    if (foodList.isNotEmpty) {
      for (var element in foodList) {
        RecommendedFood foodValue = RecommendedFood.fromJson(element);
        if (foodValue.mealType == "breakfast" || foodValue.mealType == 'early _morning') {
          breakFast.add(foodValue.dishName);
        } else if (foodValue.mealType == "lunch") {
          lunch.add(foodValue.dishName);
        } else if (foodValue.mealType == "dinner") {
          dinner.add(foodValue.dishName);
        } else {
          snacks.add(foodValue.dishName);
        }
      }
      DateTime d = DateTime.now();
      Map<String, dynamic> currentDayValue = {
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'currentIndex': 0
      };
      if (gs.read(GSKeys.currentDayValue) != null) {
        currentDayValue = gs.read(GSKeys.currentDayValue);
        if (!d.isSameDate(DateFormat('yyyy-MM-dd').parse(currentDayValue['date']))) {
          if (currentDayValue['currentIndex'] > foodList.length) {
            gs.write(GSKeys.currentDayValue,
                {'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'currentIndex': 0});
            currentDayValue = {
              'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
              'currentIndex': 0
            };
          } else {
            gs.write(GSKeys.currentDayValue, {
              'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
              'currentIndex': currentDayValue['currentIndex'] + 1
            });
          }
        }
      } else {
        gs.write(GSKeys.currentDayValue,
            {'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'currentIndex': 0});
      }

      // var foodEntryList = listEntities.entries.toList();
      _foodMealType[0] = currentDayValue['currentIndex'] > breakFast.length
          ? breakFast[0]
          : breakFast[currentDayValue['currentIndex']];
      _foodMealType[1] = currentDayValue['currentIndex'] > lunch.length
          ? lunch[0]
          : lunch[currentDayValue['currentIndex']];
      _foodMealType[3] = currentDayValue['currentIndex'] > dinner.length
          ? dinner[0]
          : dinner[currentDayValue['currentIndex']];
      _foodMealType[2] = currentDayValue['currentIndex'] > snacks.length
          ? snacks[0]
          : snacks[currentDayValue['currentIndex']];
    } else {
      _foodMealType[0] = 'Log Food';
      _foodMealType[1] = 'Log Food';
      _foodMealType[2] = 'Log Food';
      _foodMealType[3] = 'Log Food';
    }
  }

  getData() async {
    ListApis listApis = ListApis();
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (mounted) {
        setState(() {
          mealsListData = value['food'];
          //loaded = true;
        });
      }
    });

    // _cardioController.datumCollect();
  }

  bool activityLoaded = false;

  Future getRecommendedActivity() async {
    http.Response res =
        await http.post(Uri.parse('${API.iHLUrl}/empcardiohealth/recommended_activity'),
            body: json.encode({
              "age": "all", //not for above 55 , all
              "cholesterol": "yes",
              "hypertension": "yes",
              "time_of_the_day": "morning or evening" //morning , morning or evening
            }));
    if (res.statusCode == 200) {
      _recommendedActivityList = json.decode(res.body);
      _walking = _recommendedActivityList["walking"];
      _sports = _recommendedActivityList["sports"];
      _activities = _recommendedActivityList["activite"];
      _yoga = _recommendedActivityList["yoga"];
      setState(() {
        activityLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool enabled = true;
    //     .retrivedMedicalData.diastolicBloodPressure.toString()}');
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    List foodTileDetails = [
      {
        "name": "Breakfast",
        "imagePath": "assets/icons/O____-removebg-preview.png",
        "color": [const Color(0xffda9080), const Color(0xffc5300f)],
        "onTap": () async {
          if (_answers[12] == "") {
            getDialog('To see your recommended food answer the simple questionnaire!!!');
          } else {
            _showDialog(
                content: Column(
              children: [
                CustomDietCard(
                  name: "Breakfast",
                  imgPath: "assets/icons/O____-removebg-preview.png",
                  colors: const [Color(0xffda9080), Color(0xffc5300f)],
                ),
                listOfFood(0),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: buttonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          Text(
                            'Log Food',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("naviFromCardio", true);
                        print(prefs.getBool("naviFromCardio").toString());
                        Get.back();
                        Get.to(MealTypeScreen(mealsListData: mealsListData[0], Screen: "cardio"));
                      }),
                ),
              ],
            ));
          }
        }
      },
      {
        "name": "Lunch",
        "imagePath": "assets/icons/O___-removebg-preview.png",
        "color": [Colors.lightBlueAccent.shade100, Colors.lightBlueAccent],
        "onTap": () {
          if (_answers[12] == "") {
            getDialog('To see your recommended food answer the simple questionnaire!!!');
          } else {
            _showDialog(
                content: Column(
              children: [
                CustomDietCard(
                  name: "Lunch",
                  imgPath: "assets/icons/O___-removebg-preview.png",
                  colors: [Colors.lightBlueAccent.shade100, Colors.lightBlueAccent],
                ),
                listOfFood(1),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: buttonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          Text(
                            'Log Food',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("naviFromCardio", true);
                        print(prefs.getBool("naviFromCardio").toString());
                        Get.back();
                        Get.to(MealTypeScreen(mealsListData: mealsListData[1], Screen: "cardio"));
                      }),
                ),
              ],
            ));
          }
        }
      },
      {
        "name": "Snacks",
        "imagePath": "assets/icons/O_-removebg-preview.png",
        "color": [Colors.pinkAccent.shade100, Colors.pinkAccent],
        "onTap": () {
          if (_answers[12] == "") {
            getDialog('To see your recommended food answer the simple questionnaire!!!');
          } else {
            _showDialog(
                content: Column(
              children: [
                CustomDietCard(
                  name: "Snacks",
                  imgPath: "assets/icons/O_-removebg-preview.png",
                  colors: [Colors.pinkAccent.shade100, Colors.pinkAccent],
                ),
                listOfFood(2),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: buttonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          Text(
                            'Log Food',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("naviFromCardio", true);
                        print(prefs.getBool("naviFromCardio").toString());
                        Get.back();
                        Get.to(MealTypeScreen(mealsListData: mealsListData[2], Screen: "cardio"));
                      }),
                ),
              ],
            ));
          }
        }
      },
      {
        "name": "Dinner",
        "imagePath": "assets/icons/O111-removebg-preview.png",
        "color": [Colors.purpleAccent.shade100, Colors.purpleAccent],
        "onTap": () {
          if (_answers[12] == "") {
            getDialog('To see your recommended food answer the simple questionnaire!!!');
          } else {
            _showDialog(
                content: Column(
              children: [
                CustomDietCard(
                  name: "Dinner",
                  imgPath: "assets/icons/O111-removebg-preview.png",
                  colors: [Colors.purpleAccent.shade100, Colors.purpleAccent],
                ),
                listOfFood(3),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: buttonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          Text(
                            'Log Food',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("naviFromCardio", true);
                        print(prefs.getBool("naviFromCardio").toString());
                        Get.back();
                        Get.to(MealTypeScreen(mealsListData: mealsListData[3], Screen: "cardio"));
                      }),
                ),
              ],
            ));
          }
        }
      }
    ];
    if (!Tabss.featureSettings.heartHealth) {
      if (widget.tabView ?? false) {
        return const Center(child: Text("No Heart Health Available"));
      }
      return BasicPageUI(
          appBar: AppBar(
            title: Text("Heart Health",
                style: TextStyle(
                  fontSize: 20.0.sp,
                )),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: InkWell(
              onTap: () {
                if (widget.cond == true) {
                  Get.to(() => DashBoardNavigation(
                      title: 'Health Programs',
                      backNav: true,
                      navigationList: NewDashBoardNavigation.healthProgram));
                } else {
                  Get.off(LandingPage());
                  // Get.back();
                }
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
              height: 80.h,
              alignment: Alignment.center,
              child: const Text("No Heart Health Available")));
    } else {
      return widget.tabView ?? false
          ? _tabView(
              height: height,
              width: width,
              foodTileDetails: foodTileDetails,
              cardioController: _cardioController)
          : _withoutTabView(height: height, width: width, foodTileDetails: foodTileDetails);
    }
  }

  Widget _withoutTabView({var width, height, List foodTileDetails}) {
    return WillPopScope(
        onWillPop: () async {
          if (widget.cond == true) {
            Get.to(() => DashBoardNavigation(
                title: 'Health Programs',
                backNav: true,
                navigationList: NewDashBoardNavigation.healthProgram));
          } else {
            Get.off(LandingPage());
            // Get.back();
          }
          return true;
        },
        child: CommonScreenForNavigation(
          content: BasicPageUI(
            appBar: AppBar(
              title: Text("Heart Health",
                  style: TextStyle(
                    fontSize: 20.0.sp,
                  )),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: InkWell(
                onTap: () {
                  if (widget.cond == true) {
                    Get.to(() => DashBoardNavigation(
                        title: 'Health Programs',
                        backNav: true,
                        navigationList: NewDashBoardNavigation.healthProgram));
                  } else {
                    Get.off(LandingPage());
                    // Get.back();
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
                child: GetBuilder<CardioGetXController>(
                    id: "score",
                    builder: (_) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                width: width,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          offset: const Offset(1, 1),
                                          color: Colors.grey.shade400,
                                          blurRadius: 15)
                                    ],
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    )),
                                child: _.score == 0.0
                                    ? GestureDetector(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(AppTexts.improveHeartHealth,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily: 'Poppins',
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 17.sp,
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 1,
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: Text(AppTexts.deservesHeartHealth,
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 12,
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(15.0),
                                              child:
                                                  Image(width: 40, image: ImageAssets.Questionmark),
                                            )
                                          ],
                                        ),
                                        onTap: () {
                                          Get.to(const CardioDashboard());
                                        },
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            GetBuilder<CardioGetXController>(
                                                id: "score",
                                                builder: (CardioGetXController context) {
                                                  return ScoreMeterCardio(
                                                      value: _cardioController.score);
                                                }),
                                            SizedBox(
                                              height: height / 6,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  colorStatus("Low", Colors.yellow),
                                                  colorStatus("Healthy", Colors.green),
                                                  colorStatus("Intermediate", Colors.orangeAccent),
                                                  colorStatus("Danger", Colors.red),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: width / 8,
                                              child: const VerticalDivider(
                                                color: Colors.blue,
                                                thickness: 2,
                                                width: 2,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    FittedBox(
                                                      child: Text(
                                                        "Risk Status",
                                                        style: TextStyle(
                                                            color: Colors.grey, fontSize: 16.2.sp),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      color: Colors.blue,
                                                      onPressed: () {
                                                        Get.to(InfoScreen(
                                                          score: _cardioController.score.toInt(),
                                                        ));
                                                      },
                                                      icon: const Icon(
                                                        Icons.info,
                                                        size: 22,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // SizedBox(height: 2),
                                                FittedBox(
                                                  child: Text(
                                                    score >= 20
                                                        ? 'High'
                                                        : score < 20 && score >= 7.5
                                                            ? 'Intermediate'
                                                            : score < 7.5 && score >= 5
                                                                ? 'Healthy'
                                                                : 'Low',
                                                    style: TextStyle(
                                                        fontSize: size.width > 340 ? 16 : 11),
                                                  ),
                                                )
                                              ],
                                            )
                                          ])),
                          ),
                          GetBuilder<CardioGetXController>(
                              id: "vitalscard",
                              builder: (CardioGetXController context) {
                                return Wrap(
                                  runSpacing: 3.0,
                                  children: [
                                    CustomVitalCard(
                                      name: "Blood Pressure",
                                      value: _lastRetriveData == null ||
                                              _answers == null ||
                                              _cardioController.retrivedMedicalData == null
                                          ? '0.0'
                                          : _cardioController.updatebp
                                              ? "${_cardioController.retrivedMedicalData.systolicBloodPressure.toStringAsFixed(0)}/${_cardioController.retrivedMedicalData.diastolicBloodPressure.toStringAsFixed(0)}"
                                              : '${_answers[0]}/${_answers[1]}',
                                      // value: ( _cardioController
                                      //     .retrivedMedicalData.diastolicBloodPressure==null?0.0:_cardioController
                                      //     .retrivedMedicalData.diastolicBloodPressure)
                                      //     .toStringAsFixed(0)
                                      //     .toString()+"/"+(_cardioController
                                      //     .retrivedMedicalData.systolicBloodPressure??0.0)
                                      //     .toStringAsFixed(0)
                                      //     .toString()??'0.0',
                                      imagePath: "assets/icons/blood-pressure-removebg-preview.png",
                                      onTileTap: () {
                                        TextEditingController systolic = TextEditingController();
                                        TextEditingController diastolic = TextEditingController();
                                        systolic.text = _cardioController
                                                    .retrivedMedicalData.systolicBloodPressure ==
                                                null
                                            ? ''
                                            : _cardioController
                                                .retrivedMedicalData.systolicBloodPressure
                                                .toStringAsFixed(0)
                                                .toString();
                                        diastolic.text = _cardioController
                                                    .retrivedMedicalData.diastolicBloodPressure ==
                                                null
                                            ? ''
                                            : _cardioController
                                                .retrivedMedicalData.diastolicBloodPressure
                                                .toStringAsFixed(0)
                                                .toString();
                                        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                        const TextStyle titleTextStyle =
                                            TextStyle(color: AppColors.appItemTitleTextColor);
                                        final InputDecoration textInputDecoration = InputDecoration(
                                            errorMaxLines: 2,
                                            errorStyle: TextStyle(height: 0.9, fontSize: 15.sp),
                                            suffixIcon: Icon(
                                              Icons.edit,
                                              size: 20.sp,
                                            ),
                                            isDense: true,
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                )));
                                        _answers[0] == ' ' ||
                                                _cardioController.retrivedMedicalData
                                                        .diastolicBloodPressure ==
                                                    null
                                            ? getDialog(
                                                'To add your vital answer the simple questionnaire!!!')
                                            : Get.defaultDialog(
                                                barrierDismissible: false,
                                                contentPadding: const EdgeInsets.all(20),
                                                titlePadding: const EdgeInsets.only(top: 20),
                                                title: 'Blood pressure',
                                                radius: 4.0,
                                                titleStyle: const TextStyle(
                                                    color: AppColors.primaryColor,
                                                    fontWeight: FontWeight.bold),
                                                content: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Enter your systolic',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin: EdgeInsets.symmetric(
                                                            vertical: 1.5.h,
                                                          ),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 90) {
                                                                  return "Value between 90 -  200";
                                                                } else if (s > 200) {
                                                                  return "Value between 90 -  200";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 90 -  200";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: systolic,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'Enter your diostolic',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin:
                                                              EdgeInsets.symmetric(vertical: 1.5.h),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 10) {
                                                                  return "Value between 10 -  150";
                                                                } else if (s > 150) {
                                                                  return "Value between 10 -  150";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 10 -  150";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: diastolic,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15),
                                                        GetBuilder<CardioGetXController>(
                                                            id: "status",
                                                            builder:
                                                                (CardioGetXController context) {
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: _cardioController
                                                                            .updatingVitalValue
                                                                        ? () {}
                                                                        : () {
                                                                            Get.back();
                                                                          },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 3.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          border: Border.all(
                                                                              color: AppColors
                                                                                  .primaryColor,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            color: AppColors
                                                                                .primaryColor,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 6.w),
                                                                  InkWell(
                                                                    onTap:
                                                                        _cardioController
                                                                                .updatingVitalValue
                                                                            ? () {}
                                                                            : () {
                                                                                if (formKey
                                                                                    .currentState
                                                                                    .validate()) {
                                                                                  unfocusKeyboard();
                                                                                  _cardioController
                                                                                      .storeMEdicalData(
                                                                                          datatoChange: {
                                                                                        "dataName":
                                                                                            "BP",
                                                                                        "systolic":
                                                                                            double.parse(
                                                                                                systolic.text),
                                                                                        "diastolic":
                                                                                            double.parse(
                                                                                                diastolic.text),
                                                                                      });
                                                                                }
                                                                              },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 3.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: AppColors
                                                                              .primaryColor,
                                                                          border: Border.all(
                                                                              color: Colors.blue),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: _cardioController
                                                                              .updatingVitalValue
                                                                          ? const SizedBox(
                                                                              height: 33,
                                                                              width: 33,
                                                                              child:
                                                                                  CircularProgressIndicator(
                                                                                color: Colors.white,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              "Update",
                                                                              style: TextStyle(
                                                                                  color:
                                                                                      Colors.white,
                                                                                  fontSize:
                                                                                      size.width >
                                                                                              340
                                                                                          ? 16
                                                                                          : 11),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            })
                                                      ],
                                                    )));
                                      },
                                      onGraphTap: () {
                                        List tempList = [];
                                        List optimizedVitalData = [];
                                        var date;
                                        for (int i = 0; i < _cardioController.bp.length; i++) {
                                          date = (_cardioController.bp[i]['date']);
                                          final DateFormat formatter =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          final String formatted = formatter.format(date);
                                          tempList.add(formatted);
                                          if (tempList.length > 1) {
                                            if (tempList[i - 1] == tempList[i]) {
                                              i = i++;
                                            } else {
                                              optimizedVitalData.add(_cardioController.bp[i]);
                                            }
                                          } else {
                                            optimizedVitalData.add(_cardioController.bp[i]);
                                          }
                                        }
                                        Map arg = {
                                          'vitalType': "bp",
                                          'status': optimizedVitalData.last['status'],
                                          'value': optimizedVitalData.last['value'].toString(),
                                          'data': optimizedVitalData
                                        };
                                        // var xyzabc = arg;
                                        // print(xyzabc);
                                        // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                        _tabController.updateSelectedIconValue(
                                            value: AppTexts.healthProgramms);
                                        Get.to(MyVitalGraphScreen(
                                          data: arg,
                                          navPath: "",
                                        ));
                                      },
                                      color: Colors.green,
                                    ),
                                    CustomVitalCard(
                                      name: "Cholesterol",
                                      value: _cardioController.lastUpdatedMedicaldata.cholesterol ==
                                              null
                                          ? "0.0"
                                          : _cardioController.lastUpdatedMedicaldata.cholesterol
                                              .toString(),
                                      imagePath: "assets/icons/cholesterol-removebg-preview.png",
                                      onTileTap: () {
                                        print("Cholesterol tapped");
                                        TextEditingController ldl = TextEditingController();
                                        TextEditingController hdl = TextEditingController();
                                        TextEditingController cholesterol = TextEditingController();
                                        ldl.text = _cardioController.retrivedMedicalData.ldl == null
                                            ? ''
                                            : _cardioController.retrivedMedicalData.ldl
                                                .toStringAsFixed(0)
                                                .toString();
                                        hdl.text = _cardioController.retrivedMedicalData.hdl == null
                                            ? ''
                                            : _cardioController.retrivedMedicalData.hdl
                                                .toStringAsFixed(0)
                                                .toString();
                                        cholesterol.text =
                                            _cardioController.retrivedMedicalData.cholesterol ==
                                                    null
                                                ? ''
                                                : _cardioController.retrivedMedicalData.cholesterol
                                                    .toStringAsFixed(0)
                                                    .toString();
                                        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                        const TextStyle titleTextStyle =
                                            TextStyle(color: AppColors.appItemTitleTextColor);
                                        final InputDecoration textInputDecoration = InputDecoration(
                                            errorMaxLines: 2,
                                            suffixIcon: const Icon(Icons.edit),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                )));
                                        _cardioController.retrivedMedicalData.cholesterol == null
                                            ? getDialog(
                                                'To add your vital answer the simple questionnaire!!!')
                                            : Get.defaultDialog(
                                                barrierDismissible: false,
                                                contentPadding: const EdgeInsets.all(20),
                                                titlePadding: const EdgeInsets.only(top: 20),
                                                title: 'Cholesterol',
                                                radius: 4.0,
                                                // titleStyle: TextStyle(
                                                //     color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                                                // onConfirm: () {
                                                //   if (_formKey.currentState.validate()) {
                                                //     _cardioController.storeMEdicalData(datatoChange: {
                                                //       "dataName": "Cholesterol",
                                                //       "ldl": double.parse(ldl.text),
                                                //       "hdl": double.parse(hdl.text),
                                                //       "cholesterol": double.parse(cholesterol.text)
                                                //     });
                                                //     Get.back();
                                                //   }
                                                // },
                                                // textConfirm: 'Update',
                                                // confirmTextColor: Colors.white,
                                                // textCancel: 'Cancel',
                                                // onCancel: () {},
                                                content: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Enter your LDL',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin:
                                                              EdgeInsets.symmetric(vertical: 1.5.h),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 60) {
                                                                  return "Value between 60 -  200";
                                                                } else if (s > 200) {
                                                                  return "Value between 60 -  200";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 60 -  200";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: ldl,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'Enter your HDL',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin:
                                                              EdgeInsets.symmetric(vertical: 1.5.h),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 20) {
                                                                  return "Value between 20 -  100";
                                                                } else if (s > 100) {
                                                                  return "Value between 20 -  100";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 20 -  100";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: hdl,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'Enter your Cholesterol',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin:
                                                              EdgeInsets.symmetric(vertical: 1.5.h),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 130) {
                                                                  return "Value between 130 -  320";
                                                                } else if (s > 320) {
                                                                  return "Value between 130 -  320";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 130 -  320";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: cholesterol,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        GetBuilder<CardioGetXController>(
                                                            id: "status",
                                                            builder:
                                                                (CardioGetXController context) {
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: _cardioController
                                                                            .updatingVitalValue
                                                                        ? () {}
                                                                        : () {
                                                                            Get.back();
                                                                          },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 4.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          border: Border.all(
                                                                              color: AppColors
                                                                                  .primaryColor,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            color: AppColors
                                                                                .primaryColor,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        _cardioController
                                                                                .updatingVitalValue
                                                                            ? () {}
                                                                            : () {
                                                                                if (formKey
                                                                                    .currentState
                                                                                    .validate()) {
                                                                                  unfocusKeyboard();
                                                                                  _cardioController
                                                                                      .storeMEdicalData(
                                                                                          datatoChange: {
                                                                                        "dataName":
                                                                                            "Cholesterol",
                                                                                        "ldl": double
                                                                                            .parse(ldl
                                                                                                .text),
                                                                                        "hdl": double
                                                                                            .parse(hdl
                                                                                                .text),
                                                                                        "cholesterol":
                                                                                            double.parse(
                                                                                                cholesterol.text)
                                                                                      });
                                                                                }
                                                                              },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 4.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: AppColors
                                                                              .primaryColor,
                                                                          border: Border.all(
                                                                              color: Colors.blue),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: _cardioController
                                                                              .updatingVitalValue
                                                                          ? const SizedBox(
                                                                              height: 33,
                                                                              width: 33,
                                                                              child:
                                                                                  CircularProgressIndicator(
                                                                                color: Colors.white,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              "Update",
                                                                              style: TextStyle(
                                                                                  color:
                                                                                      Colors.white,
                                                                                  fontSize:
                                                                                      size.width >
                                                                                              340
                                                                                          ? 16
                                                                                          : 11),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            })
                                                      ],
                                                    )));
                                      },
                                      onGraphTap: () {
                                        List tempList = [];
                                        List optimizedVitalData = [];
                                        var date;
                                        for (int i = 0;
                                            i < _cardioController.CholestrolUpdated.length;
                                            i++) {
                                          date = (_cardioController.CholestrolUpdated[i]['date']);
                                          final DateFormat formatter =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          final String formatted = formatter.format(date);
                                          tempList.add(formatted);
                                          if (tempList.length > 1) {
                                            if (tempList[i - 1] == tempList[i]) {
                                              i = i++;
                                            } else {
                                              optimizedVitalData
                                                  .add(_cardioController.CholestrolUpdated[i]);
                                            }
                                          } else {
                                            optimizedVitalData
                                                .add(_cardioController.CholestrolUpdated[i]);
                                          }
                                        }
                                        Map arg = {
                                          'vitalType': "Cholesterol",
                                          'status': optimizedVitalData.last['status'],
                                          'value': optimizedVitalData.last['value'].toString(),
                                          'data': optimizedVitalData
                                        };

                                        // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                        //Navigator.pushNamed(Get.context, 'cholestrol_screen', arguments: arg);
                                        _tabController.updateSelectedIconValue(
                                            value: AppTexts.healthProgramms);
                                        Get.to(MyVitalGraphScreen(
                                          data: arg,
                                          navPath: "",
                                        ));
                                      },
                                      color: Colors.red,
                                    ),
                                    CustomVitalCard(
                                      name: "Visceral Fat",
                                      // value: _cardioController
                                      //             .lastUpdatedMedicaldata.cholesterol ==
                                      //         null
                                      //     ? "0.0"
                                      //     : _cardioController
                                      //         .lastUpdatedMedicaldata.cholesterol
                                      //         .toString(),
                                      value: _cardioController.viseralFFat.toString() == "0" ||
                                              _cardioController.viseralFFat == null ||
                                              _cardioController.viseralFFat.toString() == "null"
                                          ? "N/A"
                                          : _cardioController.viseralFFat.toString(),
                                      imagePath: "assets/icons/fat-removebg-preview.png",
                                      onTileTap: () {
                                        print("Visceral Fat tapped");
                                      },
                                      onGraphTap: () {
                                        List tempList = [];
                                        List optimizedVitalData = [];
                                        var date;
                                        print(_cardioController.vsFat);
                                        for (int i = 0; i < _cardioController.vsFat.length; i++) {
                                          date = (_cardioController.vsFat[i]['date']);
                                          final DateFormat formatter =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          final String formatted = formatter.format(date);
                                          tempList.add(formatted);
                                          if (tempList.length > 1) {
                                            if (tempList[i - 1] == tempList[i]) {
                                              i = i++;
                                            } else {
                                              optimizedVitalData.add(_cardioController.vsFat[i]);
                                            }
                                          } else {
                                            optimizedVitalData.add(_cardioController.vsFat[i]);
                                          }
                                        }
                                        Map arg = {
                                          'vitalType': "visceral_fat",
                                          'status': optimizedVitalData.last['status'],
                                          'value': optimizedVitalData.last['value'].toString(),
                                          'data': optimizedVitalData
                                        };
                                        // var xyzabc = arg;
                                        // print(xyzabc);
                                        optimizedVitalData.last['value'].toString() != "null" &&
                                                optimizedVitalData.last['value'].toString() !=
                                                    "0.0" &&
                                                optimizedVitalData.last['value'].toString() != "NaN"
                                            // ? Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg)
                                            ? {
                                                _tabController.updateSelectedIconValue(
                                                    value: AppTexts.healthProgramms),
                                                Get.to(MyVitalGraphScreen(
                                                  data: arg,
                                                  navPath: "",
                                                )),
                                              }
                                            : Get.snackbar('Visceral Fat Test Not Taken', ' ',
                                                icon: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child:
                                                        Icon(Icons.favorite, color: Colors.white)),
                                                margin:
                                                    const EdgeInsets.all(20).copyWith(bottom: 40),
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                snackPosition: SnackPosition.BOTTOM);
                                      },
                                      color: Colors.red,
                                    ),
                                    CustomVitalCard(
                                      name: "BMI",
                                      value: _cardioController.bmi.length == 0 ||
                                              _cardioController.bmi.length == null
                                          ? "0.0"
                                          : _cardioController.bmi.last['value'].toString(),
                                      imagePath: "assets/icons/bmi-removebg-preview.png",
                                      onTileTap: () {
                                        TextEditingController weight = TextEditingController();
                                        weight.text =
                                            _cardioController.retrivedMedicalData.weight == null
                                                ? ''
                                                : _cardioController.retrivedMedicalData.weight
                                                    .toStringAsFixed(0)
                                                    .toString();
                                        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                        const TextStyle titleTextStyle =
                                            TextStyle(color: AppColors.appItemTitleTextColor);
                                        final InputDecoration textInputDecoration = InputDecoration(
                                            errorMaxLines: 2,
                                            suffixIcon: const Icon(Icons.edit),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primaryColor,
                                                )));
                                        _cardioController.retrivedMedicalData.weight == null
                                            ? getDialog(
                                                'To add your vital answer the simple questionnaire!!!')
                                            : Get.defaultDialog(
                                                barrierDismissible: false,
                                                contentPadding: const EdgeInsets.all(15),
                                                titlePadding: const EdgeInsets.only(top: 20),
                                                title: 'BMI',
                                                radius: 4.0,
                                                titleStyle: const TextStyle(
                                                    color: AppColors.primaryColor,
                                                    fontWeight: FontWeight.bold),
                                                // onConfirm: () {
                                                //   if (_formKey.currentState.validate()) {
                                                //     _cardioController.storeMEdicalData(datatoChange: {
                                                //       "dataName": "BMI",
                                                //       "weight": double.parse(weight.text)
                                                //     });
                                                //     Get.back();
                                                //   }
                                                // },
                                                // textConfirm: 'Update',
                                                // confirmTextColor: Colors.white,
                                                // textCancel: 'Cancel',
                                                // onCancel: () {},
                                                content: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Enter Your Weight',
                                                          style: titleTextStyle,
                                                        ),
                                                        Container(
                                                          height: 6.5.h,
                                                          margin:
                                                              EdgeInsets.symmetric(vertical: 1.5.h),
                                                          child: TextFormField(
                                                            enabled: !_cardioController
                                                                .updatingVitalValue,
                                                            validator: ((String value) {
                                                              if (value.isNotEmpty) {
                                                                double s = double.parse(value);
                                                                if (s < 40) {
                                                                  return "Value between 40 -  180";
                                                                } else if (s > 180) {
                                                                  return "Value between 40 -  180";
                                                                } else {
                                                                  return null;
                                                                }
                                                              } else if (value.isEmpty) {
                                                                return "Value between 40 -  180";
                                                              }
                                                              return null;
                                                            }),
                                                            keyboardType: TextInputType.number,
                                                            inputFormatters: numberOnly,
                                                            controller: weight,
                                                            autovalidateMode:
                                                                AutovalidateMode.always,
                                                            decoration: textInputDecoration,
                                                          ),
                                                        ),
                                                        GetBuilder<CardioGetXController>(
                                                            id: "status",
                                                            builder:
                                                                (CardioGetXController context) {
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: _cardioController
                                                                            .updatingVitalValue
                                                                        ? () {}
                                                                        : () {
                                                                            Get.back();
                                                                          },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 4.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          border: Border.all(
                                                                              color: AppColors
                                                                                  .primaryColor,
                                                                              width: 2),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            color: AppColors
                                                                                .primaryColor,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: _cardioController
                                                                            .updatingVitalValue
                                                                        ? () {}
                                                                        : () {
                                                                            if (formKey.currentState
                                                                                .validate()) {
                                                                              unfocusKeyboard();
                                                                              _cardioController
                                                                                  .storeMEdicalData(
                                                                                      datatoChange: {
                                                                                    "dataName":
                                                                                        "BMI",
                                                                                    "weight": double
                                                                                        .parse(weight
                                                                                            .text)
                                                                                  });
                                                                            }
                                                                          },
                                                                    child: Container(
                                                                      height: 35,
                                                                      width: width / 4.5,
                                                                      alignment: Alignment.center,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              8, 5, 8, 5),
                                                                      decoration: BoxDecoration(
                                                                          color: AppColors
                                                                              .primaryColor,
                                                                          border: Border.all(
                                                                              color: Colors.blue),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20)),
                                                                      child: _cardioController
                                                                              .updatingVitalValue
                                                                          ? const SizedBox(
                                                                              height: 33,
                                                                              width: 33,
                                                                              child:
                                                                                  CircularProgressIndicator(
                                                                                color: Colors.white,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              "Update",
                                                                              style: TextStyle(
                                                                                  color:
                                                                                      Colors.white,
                                                                                  fontSize:
                                                                                      size.width >
                                                                                              340
                                                                                          ? 16
                                                                                          : 11),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            })
                                                      ],
                                                    )));
                                      },
                                      onGraphTap: () {
                                        List tempList = [];
                                        List optimizedVitalData = [];
                                        var date;
                                        for (int i = 0; i < _cardioController.bmi.length; i++) {
                                          date = (_cardioController.bmi[i]['date']);
                                          final DateFormat formatter =
                                              DateFormat("yyyy-MM-dd HH:mm:ss");
                                          final String formatted = formatter.format(date);
                                          tempList.add(formatted);
                                          if (tempList.length > 1) {
                                            if (tempList[i - 1] == tempList[i]) {
                                              i = i++;
                                            } else {
                                              optimizedVitalData.add(_cardioController.bmi[i]);
                                            }
                                          } else {
                                            optimizedVitalData.add(_cardioController.bmi[i]);
                                          }
                                        }
                                        Map arg = {
                                          'vitalType': "bmi",
                                          'status': optimizedVitalData.last['status'],
                                          'value': optimizedVitalData.last['value'].toString(),
                                          'data': optimizedVitalData
                                        };
                                        // var xyzabc = arg;
                                        // print(xyzabc);
                                        // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                        _tabController.updateSelectedIconValue(
                                            value: AppTexts.healthProgramms);
                                        Get.to(MyVitalGraphScreen(
                                          data: arg,
                                          navPath: "",
                                        ));
                                        print("Blood Pressure tapped");
                                      },
                                      color: Colors.yellow,
                                    ),
                                  ],
                                );
                              }),
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                  child: Text(
                                    "Recommended Diet",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Get.to(CustomDietList(context));
                                  // (Route<dynamic> route) => false);
                                  print("View All selected");
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                      child: Text(
                                        "View All",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: width,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    offset: const Offset(1, 1),
                                    color: Colors.grey.shade400,
                                    blurRadius: 15)
                              ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: foodTileDetails
                                            .map((e) => CustomDietCard(
                                                  name: e["name"],
                                                  colors: e["color"],
                                                  imgPath: e["imagePath"],
                                                  onTap: e["onTap"],
                                                ))
                                            .toList()),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
                                      child: Text(
                                        "Click the above icons for your personalized diet recommendations",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 20, bottom: 20),
                              child: SizedBox(
                                width: 70.w,
                                child: Text(
                                  "Recommended Activities",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Wrap(
                            runSpacing: 3.0,
                            children: [
                              CustomActivityTile(
                                name: 'yoga',
                                imagePath: "assets/icons/Group 164.png",
                                durationType: "Min",
                                reminderText: "Set Reminder",
                                activityList: _yoga,
                                activityLoaded: activityLoaded,
                              ),
                              CustomActivityTile(
                                name: 'walking',
                                imagePath: "assets/icons/Group 168.png",
                                durationType: "Min",
                                reminderText: "Set Reminder",
                                activityList: _walking,
                                activityLoaded: activityLoaded,
                              ),
                              CustomActivityTile(
                                name: "sports",
                                imagePath: "assets/icons/Group 170.png",
                                durationType: "Min",
                                reminderText: "Set Reminder",
                                activityList: _sports,
                                activityLoaded: activityLoaded,
                              ),
                              CustomActivityTile(
                                name: "activites",
                                imagePath: "assets/icons/Group 171.png",
                                durationType: "Min",
                                reminderText: "Set Reminder",
                                activityList: _activities,
                                activityLoaded: activityLoaded,
                              ),
                            ],
                          ),
                          Visibility(
                            visible: tipsList.isNotEmpty,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 67.w,
                                      child: Text(
                                        "Exclusive Articles for you",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        var affi = UpdatingColorsBasedOnAffiliations
                                            .selectedAffiliation.value;
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) => TipsScreen(
                                                      affi: affi,
                                                      hmmNavigation: "true",
                                                    )),
                                            (Route<dynamic> route) => false);
                                        print("View All selected");
                                      },
                                      child: Row(
                                        children: const [
                                          Text(
                                            "View All ",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            size: 13,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: tipsList.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 52.h,
                                width: 100.w,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tipsList.length,
                                    itemBuilder: (BuildContext ctx, int i) {
                                      return CustomAtricleTile(
                                        title: tipsList[i].health_tip_title,
                                        text: tipsList[i].message,
                                        imageUrl: tipsList[i].health_tip_blob_url,
                                        date: tipsList[i].health_tip_log,
                                        thumbnailUrl: tipsList[i].health_tip_blog_thum_url,
                                      );
                                    }),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                              child: Text(
                                "Experts Consultation for you",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomExpertConsultant(
                                  contentText: "Cardiologist",
                                  imagePath: "assets/icons/consultant_cardio.jpg",
                                  onTap: () {
                                    //Old navigateion ⚪⚪
                                    // _cardioController.cardiolosit(
                                    //   consultType: "Doctor Consultation");

                                    // New Navigation⚪⚪
                                    Get.to(SearchByDocAndList(
                                      specName: "Cardiology",
                                    ));
                                  }),
                              CustomExpertConsultant(
                                  contentText: "Diet Consultation",
                                  imagePath: "assets/icons/healthyLifestyleCardio.jpg",
                                  onTap: () {
                                    //Old navigateion ⚪⚪
                                    // _cardioController.cardiolosit(
                                    //   consultType: "Health Consultation");

                                    // New Navigation⚪⚪
                                    Get.to(SearchByDocAndList(
                                      specName: "Diet Consultation",
                                    ));
                                  }),
                            ],
                          ),
                          SizedBox(
                            height: 9.h,
                          )
                        ],
                      );
                    })),
          ),
        ));
  }

  Widget _tabView(
      {var width, height, List foodTileDetails, CardioGetXController cardioController}) {
    return Material(
      child: SingleChildScrollView(
          child: GetBuilder<CardioGetXController>(
              id: "score",
              builder: (_) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: width,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(1, 1),
                                    color: Colors.grey.shade400,
                                    blurRadius: 15)
                              ],
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          child: _.score == 0.0
                              ? GestureDetector(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(AppTexts.improveHeartHealth,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                    )),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 1,
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(AppTexts.deservesHeartHealth,
                                                      maxLines: 3,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Image(width: 40, image: ImageAssets.Questionmark),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    Get.to(const CardioDashboard());
                                  },
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                      GetBuilder<CardioGetXController>(
                                          id: "score",
                                          builder: (CardioGetXController context) {
                                            return ScoreMeterCardio(value: _cardioController.score);
                                          }),
                                      SizedBox(
                                        height: height / 6,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            colorStatus("Low", Colors.yellow),
                                            colorStatus("Healthy", Colors.green),
                                            colorStatus("Intermediate", Colors.orangeAccent),
                                            colorStatus("Danger", Colors.red),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: width / 8,
                                        child: const VerticalDivider(
                                          color: Colors.blue,
                                          thickness: 2,
                                          width: 2,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              FittedBox(
                                                child: Text(
                                                  "Risk Status",
                                                  style: TextStyle(
                                                      color: Colors.grey, fontSize: 16.2.sp),
                                                ),
                                              ),
                                              IconButton(
                                                color: Colors.blue,
                                                onPressed: () {
                                                  Get.to(InfoScreen(
                                                    score: _cardioController.score.toInt(),
                                                  ));
                                                },
                                                icon: const Icon(
                                                  Icons.info,
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // SizedBox(height: 2),
                                          FittedBox(
                                            child: Text(
                                              score >= 20
                                                  ? 'High'
                                                  : score < 20 && score >= 7.5
                                                      ? 'Intermediate'
                                                      : score < 7.5 && score >= 5
                                                          ? 'Healthy'
                                                          : 'Low',
                                              style:
                                                  TextStyle(fontSize: size.width > 340 ? 16 : 11),
                                            ),
                                          )
                                        ],
                                      )
                                    ])),
                    ),
                    GetBuilder<CardioGetXController>(
                        id: "vitalscard",
                        builder: (CardioGetXController context) {
                          return Wrap(
                            runSpacing: 3.0,
                            children: [
                              CustomVitalCard(
                                name: "Blood Pressure",
                                value: _lastRetriveData == null ||
                                        _answers == null ||
                                        _cardioController.retrivedMedicalData == null
                                    ? '0.0'
                                    : _cardioController.updatebp
                                        ? "${_cardioController.retrivedMedicalData.systolicBloodPressure.toStringAsFixed(0)}/${_cardioController.retrivedMedicalData.diastolicBloodPressure.toStringAsFixed(0)}"
                                        : '${_answers[0]}/${_answers[1]}',
                                // value: ( _cardioController
                                //     .retrivedMedicalData.diastolicBloodPressure==null?0.0:_cardioController
                                //     .retrivedMedicalData.diastolicBloodPressure)
                                //     .toStringAsFixed(0)
                                //     .toString()+"/"+(_cardioController
                                //     .retrivedMedicalData.systolicBloodPressure??0.0)
                                //     .toStringAsFixed(0)
                                //     .toString()??'0.0',
                                imagePath: "assets/icons/blood-pressure-removebg-preview.png",
                                onTileTap: () {
                                  TextEditingController systolic = TextEditingController();
                                  TextEditingController diastolic = TextEditingController();
                                  systolic.text = _cardioController
                                              .retrivedMedicalData.systolicBloodPressure ==
                                          null
                                      ? ''
                                      : _cardioController.retrivedMedicalData.systolicBloodPressure
                                          .toStringAsFixed(0)
                                          .toString();
                                  diastolic.text = _cardioController
                                              .retrivedMedicalData.diastolicBloodPressure ==
                                          null
                                      ? ''
                                      : _cardioController.retrivedMedicalData.diastolicBloodPressure
                                          .toStringAsFixed(0)
                                          .toString();
                                  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                  const TextStyle titleTextStyle =
                                      TextStyle(color: AppColors.appItemTitleTextColor);
                                  final InputDecoration textInputDecoration = InputDecoration(
                                      errorMaxLines: 2,
                                      errorStyle: TextStyle(height: 0.9, fontSize: 15.sp),
                                      suffixIcon: Icon(
                                        Icons.edit,
                                        size: 20.sp,
                                      ),
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                          )));
                                  _answers[0] == ' ' ||
                                          _cardioController
                                                  .retrivedMedicalData.diastolicBloodPressure ==
                                              null
                                      ? getDialog(
                                          'To add your vital answer the simple questionnaire!!!')
                                      : Get.defaultDialog(
                                          barrierDismissible: false,
                                          contentPadding: const EdgeInsets.all(20),
                                          titlePadding: const EdgeInsets.only(top: 20),
                                          title: 'Blood pressure',
                                          radius: 4.0,
                                          titleStyle: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold),
                                          content: Form(
                                              key: formKey,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Enter your systolic',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(
                                                      vertical: 1.5.h,
                                                    ),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 90) {
                                                            return "Value between 90 -  200";
                                                          } else if (s > 200) {
                                                            return "Value between 90 -  200";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 90 -  200";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: systolic,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Enter your diostolic',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 60) {
                                                            return "Value between 60 -  150";
                                                          } else if (s > 150) {
                                                            return "Value between 60 -  150";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 60 -  150";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: diastolic,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  GetBuilder<CardioGetXController>(
                                                      id: "status",
                                                      builder: (CardioGetXController context) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      Get.back();
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 3.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    border: Border.all(
                                                                        color:
                                                                            AppColors.primaryColor,
                                                                        width: 2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: AppColors.primaryColor,
                                                                      fontSize: size.width > 340
                                                                          ? 16
                                                                          : 11),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 6.w),
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      if (formKey.currentState
                                                                          .validate()) {
                                                                        unfocusKeyboard();
                                                                        _cardioController
                                                                            .storeMEdicalData(
                                                                                datatoChange: {
                                                                              "dataName": "BP",
                                                                              "systolic":
                                                                                  double.parse(
                                                                                      systolic
                                                                                          .text),
                                                                              "diastolic":
                                                                                  double.parse(
                                                                                      diastolic
                                                                                          .text),
                                                                            });
                                                                      }
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 3.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.primaryColor,
                                                                    border: Border.all(
                                                                        color: Colors.blue),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: _cardioController
                                                                        .updatingVitalValue
                                                                    ? const SizedBox(
                                                                        height: 33,
                                                                        width: 33,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color: Colors.white,
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "Update",
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      })
                                                ],
                                              )));
                                },
                                onGraphTap: () {
                                  List tempList = [];
                                  List optimizedVitalData = [];
                                  var date;
                                  for (int i = 0; i < _cardioController.bp.length; i++) {
                                    date = (_cardioController.bp[i]['date']);
                                    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                                    final String formatted = formatter.format(date);
                                    tempList.add(formatted);
                                    if (tempList.length > 1) {
                                      if (tempList[i - 1] == tempList[i]) {
                                        i = i++;
                                      } else {
                                        optimizedVitalData.add(_cardioController.bp[i]);
                                      }
                                    } else {
                                      optimizedVitalData.add(_cardioController.bp[i]);
                                    }
                                  }
                                  Map arg = {
                                    'vitalType': "bp",
                                    'status': optimizedVitalData.last['status'],
                                    'value': optimizedVitalData.last['value'].toString(),
                                    'data': optimizedVitalData
                                  };
                                  // var xyzabc = arg;
                                  // print(xyzabc);
                                  // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                  _tabController.updateSelectedIconValue(
                                      value: AppTexts.healthProgramms);
                                  Get.to(MyVitalGraphScreen(
                                    data: arg,
                                    navPath: "",
                                  ));
                                },
                                color: Colors.green,
                              ),
                              CustomVitalCard(
                                name: "Cholesterol",
                                value: _cardioController.lastUpdatedMedicaldata.cholesterol == null
                                    ? "0.0"
                                    : _cardioController.lastUpdatedMedicaldata.cholesterol
                                        .toString(),
                                imagePath: "assets/icons/cholesterol-removebg-preview.png",
                                onTileTap: () {
                                  print("Cholesterol tapped");
                                  TextEditingController ldl = TextEditingController();
                                  TextEditingController hdl = TextEditingController();
                                  TextEditingController cholesterol = TextEditingController();
                                  ldl.text = _cardioController.retrivedMedicalData.ldl == null
                                      ? ''
                                      : _cardioController.retrivedMedicalData.ldl
                                          .toStringAsFixed(0)
                                          .toString();
                                  hdl.text = _cardioController.retrivedMedicalData.hdl == null
                                      ? ''
                                      : _cardioController.retrivedMedicalData.hdl
                                          .toStringAsFixed(0)
                                          .toString();
                                  cholesterol.text =
                                      _cardioController.retrivedMedicalData.cholesterol == null
                                          ? ''
                                          : _cardioController.retrivedMedicalData.cholesterol
                                              .toStringAsFixed(0)
                                              .toString();
                                  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                  const TextStyle titleTextStyle =
                                      TextStyle(color: AppColors.appItemTitleTextColor);
                                  final InputDecoration textInputDecoration = InputDecoration(
                                      errorMaxLines: 2,
                                      suffixIcon: const Icon(Icons.edit),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                          )));
                                  _cardioController.retrivedMedicalData.cholesterol == null
                                      ? getDialog(
                                          'To add your vital answer the simple questionnaire!!!')
                                      : Get.defaultDialog(
                                          barrierDismissible: false,
                                          contentPadding: const EdgeInsets.all(20),
                                          titlePadding: const EdgeInsets.only(top: 20),
                                          title: 'Cholesterol',
                                          radius: 4.0,
                                          // titleStyle: TextStyle(
                                          //     color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                                          // onConfirm: () {
                                          //   if (_formKey.currentState.validate()) {
                                          //     _cardioController.storeMEdicalData(datatoChange: {
                                          //       "dataName": "Cholesterol",
                                          //       "ldl": double.parse(ldl.text),
                                          //       "hdl": double.parse(hdl.text),
                                          //       "cholesterol": double.parse(cholesterol.text)
                                          //     });
                                          //     Get.back();
                                          //   }
                                          // },
                                          // textConfirm: 'Update',
                                          // confirmTextColor: Colors.white,
                                          // textCancel: 'Cancel',
                                          // onCancel: () {},
                                          content: Form(
                                              key: formKey,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Enter your LDL',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 60) {
                                                            return "Value between 60 -  200";
                                                          } else if (s > 200) {
                                                            return "Value between 60 -  200";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 60 -  200";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: ldl,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Enter your HDL',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 20) {
                                                            return "Value between 20 -  100";
                                                          } else if (s > 100) {
                                                            return "Value between 20 -  100";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 20 -  100";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: hdl,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Enter your Cholesterol',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 130) {
                                                            return "Value between 130 -  320";
                                                          } else if (s > 320) {
                                                            return "Value between 130 -  320";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 130 -  320";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: cholesterol,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  GetBuilder<CardioGetXController>(
                                                      id: "status",
                                                      builder: (CardioGetXController context) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      Get.back();
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 4.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    border: Border.all(
                                                                        color:
                                                                            AppColors.primaryColor,
                                                                        width: 2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: AppColors.primaryColor,
                                                                      fontSize: size.width > 340
                                                                          ? 16
                                                                          : 11),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      if (formKey.currentState
                                                                          .validate()) {
                                                                        unfocusKeyboard();
                                                                        _cardioController
                                                                            .storeMEdicalData(
                                                                                datatoChange: {
                                                                              "dataName":
                                                                                  "Cholesterol",
                                                                              "ldl": double.parse(
                                                                                  ldl.text),
                                                                              "hdl": double.parse(
                                                                                  hdl.text),
                                                                              "cholesterol":
                                                                                  double.parse(
                                                                                      cholesterol
                                                                                          .text)
                                                                            });
                                                                      }
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 4.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.primaryColor,
                                                                    border: Border.all(
                                                                        color: Colors.blue),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: _cardioController
                                                                        .updatingVitalValue
                                                                    ? const SizedBox(
                                                                        height: 33,
                                                                        width: 33,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color: Colors.white,
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "Update",
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      })
                                                ],
                                              )));
                                },
                                onGraphTap: () {
                                  List tempList = [];
                                  List optimizedVitalData = [];
                                  var date;
                                  for (int i = 0;
                                      i < _cardioController.CholestrolUpdated.length;
                                      i++) {
                                    date = (_cardioController.CholestrolUpdated[i]['date']);
                                    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                                    final String formatted = formatter.format(date);
                                    tempList.add(formatted);
                                    if (tempList.length > 1) {
                                      if (tempList[i - 1] == tempList[i]) {
                                        i = i++;
                                      } else {
                                        optimizedVitalData
                                            .add(_cardioController.CholestrolUpdated[i]);
                                      }
                                    } else {
                                      optimizedVitalData
                                          .add(_cardioController.CholestrolUpdated[i]);
                                    }
                                  }
                                  Map arg = {
                                    'vitalType': "Cholesterol",
                                    'status': optimizedVitalData.last['status'],
                                    'value': optimizedVitalData.last['value'].toString(),
                                    'data': optimizedVitalData
                                  };

                                  // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                  //Navigator.pushNamed(Get.context, 'cholestrol_screen', arguments: arg);
                                  _tabController.updateSelectedIconValue(
                                      value: AppTexts.healthProgramms);
                                  Get.to(MyVitalGraphScreen(
                                    data: arg,
                                    navPath: "",
                                  ));
                                },
                                color: Colors.red,
                              ),
                              CustomVitalCard(
                                name: "Visceral Fat",
                                // value: _cardioController
                                //             .lastUpdatedMedicaldata.cholesterol ==
                                //         null
                                //     ? "0.0"
                                //     : _cardioController
                                //         .lastUpdatedMedicaldata.cholesterol
                                //         .toString(),
                                value: _cardioController.viseralFFat.toString() == "0" ||
                                        _cardioController.viseralFFat == null ||
                                        _cardioController.viseralFFat.toString() == "null"
                                    ? "N/A"
                                    : _cardioController.viseralFFat.toString(),
                                imagePath: "assets/icons/fat-removebg-preview.png",
                                onTileTap: () {
                                  print("Visceral Fat tapped");
                                },
                                onGraphTap: () {
                                  List tempList = [];
                                  List optimizedVitalData = [];
                                  var date;
                                  print(_cardioController.vsFat);
                                  for (int i = 0; i < _cardioController.vsFat.length; i++) {
                                    date = (_cardioController.vsFat[i]['date']);
                                    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                                    final String formatted = formatter.format(date);
                                    tempList.add(formatted);
                                    if (tempList.length > 1) {
                                      if (tempList[i - 1] == tempList[i]) {
                                        i = i++;
                                      } else {
                                        optimizedVitalData.add(_cardioController.vsFat[i]);
                                      }
                                    } else {
                                      optimizedVitalData.add(_cardioController.vsFat[i]);
                                    }
                                  }
                                  Map arg = {
                                    'vitalType': "visceral_fat",
                                    'status': optimizedVitalData.last['status'],
                                    'value': optimizedVitalData.last['value'].toString(),
                                    'data': optimizedVitalData
                                  };
                                  // var xyzabc = arg;
                                  // print(xyzabc);
                                  optimizedVitalData.last['value'].toString() != "null" &&
                                          optimizedVitalData.last['value'].toString() != "0.0" &&
                                          optimizedVitalData.last['value'].toString() != "NaN"
                                      // ? Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg)
                                      ? {
                                          _tabController.updateSelectedIconValue(
                                              value: AppTexts.healthProgramms),
                                          Get.to(MyVitalGraphScreen(
                                            data: arg,
                                            navPath: "",
                                          )),
                                        }
                                      : Get.snackbar('Visceral Fat Test Not Taken', ' ',
                                          icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.favorite, color: Colors.white)),
                                          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM);
                                },
                                color: Colors.red,
                              ),
                              CustomVitalCard(
                                name: "BMI",
                                value: _cardioController.bmi.length == 0 ||
                                        _cardioController.bmi.length == null
                                    ? "0.0"
                                    : _cardioController.bmi.last['value'].toString(),
                                imagePath: "assets/icons/bmi-removebg-preview.png",
                                onTileTap: () {
                                  TextEditingController weight = TextEditingController();
                                  weight.text = _cardioController.retrivedMedicalData.weight == null
                                      ? ''
                                      : _cardioController.retrivedMedicalData.weight
                                          .toStringAsFixed(0)
                                          .toString();
                                  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
                                  const TextStyle titleTextStyle =
                                      TextStyle(color: AppColors.appItemTitleTextColor);
                                  final InputDecoration textInputDecoration = InputDecoration(
                                      errorMaxLines: 2,
                                      suffixIcon: const Icon(Icons.edit),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                          )));
                                  _cardioController.retrivedMedicalData.weight == null
                                      ? getDialog(
                                          'To add your vital answer the simple questionnaire!!!')
                                      : Get.defaultDialog(
                                          barrierDismissible: false,
                                          contentPadding: const EdgeInsets.all(15),
                                          titlePadding: const EdgeInsets.only(top: 20),
                                          title: 'BMI',
                                          radius: 4.0,
                                          titleStyle: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold),
                                          // onConfirm: () {
                                          //   if (_formKey.currentState.validate()) {
                                          //     _cardioController.storeMEdicalData(datatoChange: {
                                          //       "dataName": "BMI",
                                          //       "weight": double.parse(weight.text)
                                          //     });
                                          //     Get.back();
                                          //   }
                                          // },
                                          // textConfirm: 'Update',
                                          // confirmTextColor: Colors.white,
                                          // textCancel: 'Cancel',
                                          // onCancel: () {},
                                          content: Form(
                                              key: formKey,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Enter Your Weight',
                                                    style: titleTextStyle,
                                                  ),
                                                  Container(
                                                    height: 6.5.h,
                                                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                                                    child: TextFormField(
                                                      enabled:
                                                          !_cardioController.updatingVitalValue,
                                                      validator: ((String value) {
                                                        if (value.isNotEmpty) {
                                                          double s = double.parse(value);
                                                          if (s < 40) {
                                                            return "Value between 40 -  180";
                                                          } else if (s > 180) {
                                                            return "Value between 40 -  180";
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (value.isEmpty) {
                                                          return "Value between 40 -  180";
                                                        }
                                                        return null;
                                                      }),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: numberOnly,
                                                      controller: weight,
                                                      autovalidateMode: AutovalidateMode.always,
                                                      decoration: textInputDecoration,
                                                    ),
                                                  ),
                                                  GetBuilder<CardioGetXController>(
                                                      id: "status",
                                                      builder: (CardioGetXController context) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      Get.back();
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 4.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    border: Border.all(
                                                                        color:
                                                                            AppColors.primaryColor,
                                                                        width: 2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: AppColors.primaryColor,
                                                                      fontSize: size.width > 340
                                                                          ? 16
                                                                          : 11),
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: _cardioController
                                                                      .updatingVitalValue
                                                                  ? () {}
                                                                  : () {
                                                                      if (formKey.currentState
                                                                          .validate()) {
                                                                        unfocusKeyboard();
                                                                        _cardioController
                                                                            .storeMEdicalData(
                                                                                datatoChange: {
                                                                              "dataName": "BMI",
                                                                              "weight":
                                                                                  double.parse(
                                                                                      weight.text)
                                                                            });
                                                                      }
                                                                    },
                                                              child: Container(
                                                                height: 35,
                                                                width: width / 4.5,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 5, 8, 5),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.primaryColor,
                                                                    border: Border.all(
                                                                        color: Colors.blue),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: _cardioController
                                                                        .updatingVitalValue
                                                                    ? const SizedBox(
                                                                        height: 33,
                                                                        width: 33,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color: Colors.white,
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "Update",
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize:
                                                                                size.width > 340
                                                                                    ? 16
                                                                                    : 11),
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      })
                                                ],
                                              )));
                                },
                                onGraphTap: () {
                                  List tempList = [];
                                  List optimizedVitalData = [];
                                  var date;
                                  for (int i = 0; i < _cardioController.bmi.length; i++) {
                                    date = (_cardioController.bmi[i]['date']);
                                    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                                    final String formatted = formatter.format(date);
                                    tempList.add(formatted);
                                    if (tempList.length > 1) {
                                      if (tempList[i - 1] == tempList[i]) {
                                        i = i++;
                                      } else {
                                        optimizedVitalData.add(_cardioController.bmi[i]);
                                      }
                                    } else {
                                      optimizedVitalData.add(_cardioController.bmi[i]);
                                    }
                                  }
                                  Map arg = {
                                    'vitalType': "bmi",
                                    'status': optimizedVitalData.last['status'],
                                    'value': optimizedVitalData.last['value'].toString(),
                                    'data': optimizedVitalData
                                  };
                                  // var xyzabc = arg;
                                  // print(xyzabc);
                                  // Navigator.pushNamed(Get.context, 'vital_screen', arguments: arg);
                                  _tabController.updateSelectedIconValue(
                                      value: AppTexts.healthProgramms);
                                  Get.to(MyVitalGraphScreen(
                                    data: arg,
                                    navPath: "",
                                  ));
                                  print("Blood Pressure tapped");
                                },
                                color: Colors.yellow,
                              ),
                            ],
                          );
                        }),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                            child: Text(
                              "Recommended Diet",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.to(CustomDietList(context));
                            // (Route<dynamic> route) => false);
                            print("View All selected");
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                child: Text(
                                  "View All",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                child: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              offset: const Offset(1, 1),
                              color: Colors.grey.shade400,
                              blurRadius: 15)
                        ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: foodTileDetails
                                      .map((e) => CustomDietCard(
                                            name: e["name"],
                                            colors: e["color"],
                                            imgPath: e["imagePath"],
                                            onTap: e["onTap"],
                                          ))
                                      .toList()),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
                                child: Text(
                                  "Click the above icons for your personalized diet recommendations",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 20, bottom: 20),
                        child: SizedBox(
                          width: 70.w,
                          child: Text(
                            "Recommended Activities",
                            style: TextStyle(
                                color: Colors.blue, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      runSpacing: 3.0,
                      children: [
                        CustomActivityTile(
                          name: 'yoga',
                          imagePath: "assets/icons/Group 164.png",
                          durationType: "Min",
                          reminderText: "Set Reminder",
                          activityList: _yoga,
                          activityLoaded: activityLoaded,
                        ),
                        CustomActivityTile(
                          name: 'walking',
                          imagePath: "assets/icons/Group 168.png",
                          durationType: "Min",
                          reminderText: "Set Reminder",
                          activityList: _walking,
                          activityLoaded: activityLoaded,
                        ),
                        CustomActivityTile(
                          name: "sports",
                          imagePath: "assets/icons/Group 170.png",
                          durationType: "Min",
                          reminderText: "Set Reminder",
                          activityList: _sports,
                          activityLoaded: activityLoaded,
                        ),
                        CustomActivityTile(
                          name: "activites",
                          imagePath: "assets/icons/Group 171.png",
                          durationType: "Min",
                          reminderText: "Set Reminder",
                          activityList: _activities,
                          activityLoaded: activityLoaded,
                        ),
                      ],
                    ),
                    Visibility(
                      visible: tipsList.isNotEmpty,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 67.w,
                                child: Text(
                                  "Exclusive Articles for you",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  var affi =
                                      UpdatingColorsBasedOnAffiliations.selectedAffiliation.value;

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => TipsScreen(
                                                affi: affi,
                                                hmmNavigation: "true",
                                              )),
                                      (Route<dynamic> route) => false);
                                  print("View All selected");
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      "View All ",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 13,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: tipsList.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 52.h,
                          width: 100.w,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: tipsList.length,
                              itemBuilder: (BuildContext ctx, int i) {
                                return CustomAtricleTile(
                                  title: tipsList[i].health_tip_title,
                                  text: tipsList[i].message,
                                  imageUrl: tipsList[i].health_tip_blob_url,
                                  date: tipsList[i].health_tip_log,
                                  thumbnailUrl: tipsList[i].health_tip_blog_thum_url,
                                );
                              }),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                        child: Text(
                          "Experts Consultation for you",
                          style: TextStyle(
                              color: Colors.blue, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomExpertConsultant(
                            contentText: "Cardiologist",
                            imagePath: "assets/icons/consultant_cardio.jpg",
                            onTap: () {
                              //Old navigateion ⚪⚪
                              // _cardioController.cardiolosit(
                              //   consultType: "Doctor Consultation");

                              // New Navigation⚪⚪
                              Get.to(SearchByDocAndList(
                                specName: "Cardiology",
                              ));
                            }),
                        CustomExpertConsultant(
                            contentText: "Diet Consultation",
                            imagePath: "assets/icons/healthyLifestyleCardio.jpg",
                            onTap: () {
                              //Old navigateion ⚪⚪
                              // _cardioController.cardiolosit(
                              //   consultType: "Health Consultation");

                              // New Navigation⚪⚪
                              Get.to(SearchByDocAndList(
                                specName: "Diet Consultation",
                              ));
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 9.h,
                    )
                  ],
                );
              })),
    );
  }

  Widget CustomDietList(BuildContext context) {
    List foodTileDetails = [
      {
        "name": "Breakfast",
        "imagePath": "assets/icons/O____-removebg-preview.png",
        "color": [const Color(0xffda9080), const Color(0xffc5300f)],
        "onTap": () async {
          _showDialog(
              content: Column(
            children: [
              CustomDietCard(
                name: "Breakfast",
                imgPath: "assets/icons/O____-removebg-preview.png",
                colors: const [Color(0xffda9080), Color(0xffc5300f)],
              ),
              listOfFood(0),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    style: buttonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add),
                        Text(
                          'Log Food',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("naviFromCardio", true);
                      print(prefs.getBool("naviFromCardio").toString());
                      Get.back();
                      Get.to(MealTypeScreen(mealsListData: mealsListData[0], Screen: "cardio"));
                    }),
              ),
            ],
          ));
        }
      },
      {
        "name": "Lunch",
        "imagePath": "assets/icons/O___-removebg-preview.png",
        "color": [Colors.lightBlueAccent.shade100, Colors.lightBlueAccent],
        "onTap": () {
          _showDialog(
              content: Column(
            children: [
              CustomDietCard(
                name: "Lunch",
                imgPath: "assets/icons/O___-removebg-preview.png",
                colors: [Colors.lightBlueAccent.shade100, Colors.lightBlueAccent],
              ),
              listOfFood(1),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    style: buttonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add),
                        Text(
                          'Log Food',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("naviFromCardio", true);
                      print(prefs.getBool("naviFromCardio").toString());
                      Get.back();
                      Get.to(MealTypeScreen(mealsListData: mealsListData[1], Screen: "cardio"));
                    }),
              ),
            ],
          ));
        }
      },
      {
        "name": "Snacks",
        "imagePath": "assets/icons/O_-removebg-preview.png",
        "color": [Colors.pinkAccent.shade100, Colors.pinkAccent],
        "onTap": () {
          _showDialog(
              content: Column(
            children: [
              CustomDietCard(
                name: "Snacks",
                imgPath: "assets/icons/O_-removebg-preview.png",
                colors: [Colors.pinkAccent.shade100, Colors.pinkAccent],
              ),
              listOfFood(2),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    style: buttonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add),
                        Text(
                          'Log Food',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("naviFromCardio", true);
                      print(prefs.getBool("naviFromCardio").toString());
                      Get.back();
                      Get.to(MealTypeScreen(mealsListData: mealsListData[2], Screen: "cardio"));
                    }),
              ),
            ],
          ));
        }
      },
      {
        "name": "Dinner",
        "imagePath": "assets/icons/O111-removebg-preview.png",
        "color": [Colors.purpleAccent.shade100, Colors.purpleAccent],
        "onTap": () {
          _showDialog(
              content: Column(
            children: [
              CustomDietCard(
                name: "Dinner",
                imgPath: "assets/icons/O111-removebg-preview.png",
                colors: [Colors.purpleAccent.shade100, Colors.purpleAccent],
              ),
              listOfFood(3),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ElevatedButton(
                    style: buttonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add),
                        Text(
                          'Log Food',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool("naviFromCardio", true);
                      print(prefs.getBool("naviFromCardio").toString());
                      Get.back();
                      Get.to(MealTypeScreen(mealsListData: mealsListData[3], Screen: "cardio"));
                    }),
              ),
            ],
          ));
        }
      }
    ];

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text('Recommended Diet'),
          backgroundColor: AppColors.primaryAccentColor,
          leading: InkWell(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView.builder(
            itemCount: foodTileDetails.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4.0,
                  child: Column(
                    children: [
                      SizedBox(
                        child: Column(
                          children: [
                            Container(
                              height: 25.w,
                              width: 25.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: foodTileDetails[index]['color'],
                                ),
                                border: Border.all(width: 2.5, color: Colors.white),
                                borderRadius: BorderRadius.circular(250),
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 0),
                                      color: foodTileDetails[index]['color'][1],
                                      blurRadius: 8),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: Image.asset(foodTileDetails[index]['imagePath'])),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                foodTileDetails[index]['name'],
                                style: foodTileDetails[index]['onTap'] != null
                                    ? TextStyle(
                                        color: Colors.black45,
                                        fontSize: 20.sp,
                                        fontFamily: 'Popins',
                                        fontWeight: FontWeight.bold,
                                      )
                                    : TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins'),
                              ),
                            ),
                            listOfFood(index),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 20),
                              child: ElevatedButton(
                                  style: buttonStyle,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add),
                                      Text(
                                        ' Log ${foodTileDetails[index]['name']}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setBool("naviFromCardio", true);
                                    print(prefs.getBool("naviFromCardio").toString());
                                    Get.back();
                                    Get.to(MealTypeScreen(mealsListData: mealsListData[index], Screen: "cardio"));
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  unfocusKeyboard() {
    return FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget colorStatus(String value, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 4,
          backgroundColor: color,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  listOfFood(int i) {
    List<String> foodList = _foodMealType[i].split('+');
    foodList.remove('or');
    print(foodList);
    if (true) Size size = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: foodList
                  .map((String e) => SizedBox(
                        width: size.width > 350 ? getHorizontalSize(250) : getHorizontalSize(128),
                        child: Text(
                          "${foodList.indexOf(e) + 1}. ${e.capitalize}",
                          // foodLogList[0].food[0].foodDetails.foodName
                          // foodLogList!=null?(foodLogList.foodTimeCategory.toString()).capitalize():'',
                          //textAlign: TextAlign.center,
                          //maxFontSize: ScUtil().setSp(16),
                          //minFontSize: ScUtil().setSp(12),
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            //fontWeight: FontWeight.bold,
                            fontSize: getFontSize(16),
                            letterSpacing: 0.2,
                            color: Colors.black54,
                          ),
                        ),
                      ))
                  .toList(),
            )));
  }

  Size size =
      WidgetsBinding.instance.window.physicalSize / WidgetsBinding.instance.window.devicePixelRatio;

  double getHorizontalSize(double px) {
    return px * (size.width / 375);
  }

  ///This method is used to set padding/margin (for the top and bottom side) & height of the screen or widget according to the Viewport height.
  double getVerticalSize(double px) {
    num statusBar = MediaQuery.of(context).viewPadding.top;
    num screenHeight = size.height - statusBar;
    return screenHeight * (px / 812);
  }

  ///This method is used to set text font size according to Viewport
  double getFontSize(double px) {
    double height = getVerticalSize(px);
    double width = getHorizontalSize(px);
    if (height < width) {
      return height.toInt().toDouble();
    } else {
      return width.toInt().toDouble();
    }
  }

  getDialog(String questionaire) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            questionaire,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OKAY'),
              onPressed: () {
                Get.to(const CardioDashboard());
              },
            ),
          ],
        );
      },
    );
  }
}
