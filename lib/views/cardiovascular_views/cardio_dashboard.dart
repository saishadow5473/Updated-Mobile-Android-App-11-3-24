import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:add_2_calendar/add_2_calendar.dart' as a2c;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/helper/recommanded_helper.dart';
import 'package:ihl/models/recommended_food._model.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/MealTypeScreen.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/main_drawer.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../cardio_dashboard/controllers/getx_controller_cardio.dart';
import '../../cardio_dashboard/models/store_medical_data.dart';
import '../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../../new_design/presentation/pages/home/home_view.dart';
import '../vital_screen.dart';
import 'InfoScreen.dart';
import 'hpod_locations.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() =>
      replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

class CardioDashboard extends StatefulWidget {
  const CardioDashboard();

  @override
  State<CardioDashboard> createState() => _CardioDashboardState();
}

class _CardioDashboardState extends State<CardioDashboard> {
  var cardio_age;
  var cardio_gen;
  var cardio_ht;
  var cardio_wt;
  var cardio_ldl;
  var cardio_hdl;
  var cardio_cholestrol;
  var cardio_smoke;
  var cardio_diab;
  var cardio_hyper;
  double score = 0.0;
  var age,
      gender,
      height,
      weight,
      _weight,
      _height,
      bp,
      totalCholestrol,
      ldl,
      hdl,
      bmi,
      bmi_status,
      systolic_blood_pressure,
      systolic_blood_pressure_status,
      percentage_body_fat,
      percentage_body_fat_status,
      body_fat_mass,
      body_fat_mass_status,
      visceral_fat,
      visceral_fat_status,
      waist_to_hip_ratio,
      waist_to_hip_ratio_status,
      _iHLUserId,
      systolic,
      diastolic,
      __notAvailableKeys = [];
  List<List> _validation = [
    [80, 200],
    [50, 140],
    [40, 165],
    [80, 200],
    [80, 200],
    [80, 200],
  ];
  String visceralFats = 'no';
  String _age, _gender, _email, _fName, _lName;
  Map vitals;
  var valueForViseralFat;
  var viseralFFat;
  bool _questionScreen = false;
  Map _lastRetriveData;
  List<MealsListData> mealsListData = [];
  var loading = true;
  var vitalsExpired = '';
  bool getScoreComplete = false, _haveScore = false, hasBp = false, bPStatus = false;
  bool _score = false;
  String txt = 'Intermediate';
  dynamic clr = Colors.yellow;
  TextStyle txtStl1 = TextStyle();
  TextStyle txtStl2 = TextStyle();
  TextStyle txtStl3 = TextStyle();
  TextStyle txtStl4 = TextStyle();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bmiController = TextEditingController();
  final bpController = TextEditingController();
  final cholesteralController = TextEditingController();
  final _textController = TextEditingController();
  List _answers = [
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
  final double _width = 50;
  int _index = 0;
  List _recommendedDietMenuList = [];
  Map<String, dynamic> _recommendedActivityList;
  List<dynamic> _walking = [];
  List<dynamic> _sports = [];
  List<dynamic> _yoga = [];
  List<dynamic> _activities = [];

  List<String> _lastRetrieveKeys = [
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

  List<Map<String, dynamic>> _question = [
    {
      'question': 'Enter your Systolic Blood Pressure',
      'option': false,
      'optional': false,
      'choose': null
    },
    {
      'question': 'Enter your Diastolic Blood Pressure',
      'option': false,
      'optional': false,
      'choose': null
    },
    {'question': 'Enter your Weight', 'option': false, 'optional': false, 'choose': null},
    {
      'question': 'Enter your Total Cholesterol',
      'option': false,
      'optional': false,
      'choose': null
    },
    {'question': 'Enter your LDL Cholesterol', 'option': false, 'optional': false, 'choose': null},
    {'question': 'Enter your HDL Cholesterol', 'option': false, 'optional': false, 'choose': null},
    {'question': 'Do you smoke ?', 'option': true, 'optional': false, 'choose': null},
    {
      'question': 'Do you have any family \nhistory of diabetes ?',
      'option': true,
      'optional': false,
      'choose': null
    },
    {
      'question': 'Are you on hypertension \ntreatment ?',
      'option': true,
      'optional': false,
      'choose': null
    },
    {'question': 'Are you on statin regime ?', 'option': true, 'optional': true, 'choose': null},
    {'question': 'Are you on Aspirin Therapy ?', 'option': true, 'optional': true, 'choose': null},
    {
      'question': 'Choose Your Region',
      'option': true,
      'optional': false,
      'choose': [
        ['east', 'East'],
        ['west', 'West'],
        ['south', 'South'],
        ['north', 'North']
      ]
    },
    {
      'question': 'Food Preferences',
      'option': true,
      'optional': false,
      'choose': [
        ['veg', 'Vegetarian'],
        ['nonVeg', 'Non Vegetarian'],
        ['egg', 'Eggetarian']
      ]
    },
  ];
  Color startColor;
  Color endColor;
  List<String> mealType = ["BreakFast", "Lunch", "Snacks", "Dinner", "Early Meal", "Mid Meal"];
  List breakFast = [];
  List lunchMeal = [];
  List dinner = [];
  List snacks = [];
  List midMeal = [];
  List earlyMeal = [];

  List imageAssets = [
    'assets/images/diet/breakfast.png',
    'assets/images/diet/lunch.png',
    'assets/images/diet/snack.png',
    'assets/images/diet/dinner.png',
    'assets/images/diet/snack.png',
    'assets/images/diet/snack.png',
  ];
  List<String> _heading = [
    'Systolic BP',
    'DIastolic BP',
    'Weight',
    'Total Cholesterol',
    'LDL Cholesterol',
    'HDL Cholesterol',
    'Smoking Status',
    'History of Diabetes',
    'Hypertension Treatment',
    'Statin',
    'Aspirin',
    'Region',
    'Food Preferences'
  ];
  List<List> _validate = [
    [90, 200],
    [10, 150],
    [40, 180],
    [130, 320],
    [60, 200],
    [20, 100],
  ];
  List<List> _defaultDialogvalidate = [
    [90, 200],
    [10, 150],
    [40, 180],
    [],
    [130, 320],
    [60, 200],
    [20, 100],
  ];
  List<String> _defaultDialoghints = [
    'Value must be between 90 - 200',
    'Value must be between 10 - 150',
    'Value must be between 40 - 180',
    '',
    'Value must be between 130 - 320',
    'Value must be between 60 -200',
    'Value must be between 20 - 100',
  ];
  List<String> _hints = [
    'Value must be between 90 - 200',
    'Value must be between 10 - 150',
    'Value must be between 40 - 180',
    'Value must be between 130 - 320',
    'Value must be between 60 -200',
    'Value must be between 20 - 100',
    'Yes/No',
    'Yes/No',
    'Yes/No',
    'Yes/No',
    'Yes/No',
    'Yes/No',
    'Yes/No',
  ];
  List<String> _errors = [
    'Please Enter Your Blood Pressure',
    'Please Enter Your Total Cholestrol',
    'Please Enter Your Total Weight',
    'Please Enter Your LDL Cholestrol',
    'Please Enter Your HDL Cholestrol',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
    'Please Enter Yes/No',
  ];
  List _recommendedActivityGradientColors = [
    ['bacf6b', 'a6ce0e'],
    ['f56ac4', 'ad4789'],
    ['66809d', '458ad7'],
    ['8163AB', 'B387B9'],
    ['ed3f18', 'f57f64'],
  ];
  List _recommendedFoodGradientColors = [
    ['#ed3f18', '#f57f64'],
    ['#23b6e6', '#40E0D0'],
    ['#FE95B6', '#FF5287'],
    ['#6F72CA', '#1E1466'],
    ['#ed3f18', '#f57f64'],
  ];
  List<String> _foodMealType = [
    'Log Food',
    'Log Food',
    'Log Food',
    'Log Food',
  ];
  List<String> _dashBoardRetrieveKeys = [
    'systolic_blood_pressure',
    'diastolic_blood_pressure',
    'weight',
    'visceralfats',
    'Cholesterol',
    'ldl',
    'hdl',
  ];
  List<String> _dashboardheadings = [
    'Systolic',
    'Diastolic',
    'BMI',
    'Visceral Fat',
    'Cholesterol',
    'LDL',
    'HDL',
  ];
  int _currenttest = 0;
  List<int> _skipIndex = [3, 4, 5];
  String _smokerType = 'N/A', _token = '';
  final _cardioController = Get.put(CardioGetXController());

  a2c.Event buildEvent(
      {a2c.Recurrence recurrence, String title, String description, int mintuesValue}) {
    return a2c.Event(
      title: title + description,
      description: "Activity reminder by IHL",
      location: 'hCare',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(minutes: mintuesValue)),
      allDay: false,
      iosParams: a2c.IOSParams(
        reminder: Duration(minutes: 10),
      ),
      androidParams: a2c.AndroidParams(
        emailInvites: ["test@example.com"],
      ),
      recurrence: recurrence,
    );
  }

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  sortingMeal() {
    List foodList = _recommendedDietMenuList;
    if (foodList.length > 0) {
      for (var i = 0; i <= foodList.length - 1; i++) {
        var listEntities = foodList[i];
        var foodValue = RecommendedFood.fromJson(listEntities);
        // var foodEntryList = listEntities.entries.toList();

        if (foodValue.mealType == "breakfast") {
          _foodMealType[0] = foodValue.dishName;
        } else if (foodValue.mealType == "lunch") {
          _foodMealType[1] = foodValue.dishName;
        } else if (foodValue.mealType == "dinner") {
          _foodMealType[3] = foodValue.dishName;
        } else {
          _foodMealType[2] = foodValue.dishName;
        }
      }
    } else {
      _foodMealType[0] = 'Log Food';
      _foodMealType[1] = 'Log Food';
      _foodMealType[2] = 'Log Food';
      _foodMealType[3] = 'Log Food';
    }
  }

  asyncInit() async {
    await getKioskData();
    await getScore();
    await _getConusultantData();
    await getRecommendedFood();
    await getRecommendedActivity();
  }

  void getData() async {
    var listApis = ListApis();
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (mounted) {
        setState(() {
          mealsListData = value['food'];
          //loaded = true;
        });
      }
    });
  }

  Future retrieveMedicalData() async {
    final _response = await http.post(
      Uri.parse(API.iHLUrl + '/empcardiohealth/retrieve_medical_data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"ihl_user_id": _iHLUserId}),
    );
    if (_response.statusCode == 200) {
      List _resList = json.decode(_response.body);
      if (_resList.length > 0) {
        _lastRetriveData = _resList[0];
        var temp_score = _lastRetriveData['score'].toString();
        score = double.parse(temp_score);
        for (int i = 0; i <= _lastRetrieveKeys.length - 1; i++) {
          if (i < 6) {
            _answers[i] = _lastRetriveData[_lastRetrieveKeys[i]].toInt().toString();
          } else
            _answers[i] = _lastRetriveData[_lastRetrieveKeys[i]].toString().contains('true')
                ? 'yes'
                : _lastRetriveData[_lastRetrieveKeys[i]].toString().contains('false')
                    ? 'no'
                    : _lastRetriveData[_lastRetrieveKeys[i]].toString();
          if (i == 6) {
            if (_lastRetriveData['is_smoker'] == true ||
                _lastRetriveData['is_smoker'] == 'notGiven')
              _smokerType = _lastRetriveData['smoker_type'] ?? 'N/A';
          } else if (i == 0) {
            _textController.text = _answers[0] ?? '';
          }
        }
        _haveScore = true;
        if (mounted) {
          setState(() {
            oldUi = false;
            _vitalLoaded = false;
          });
        }
      } else {
        for (int i = 0; i <= 3; i++) {
          switch (i) {
            case 0:
              if (vitals == null) {
                String systolicG = '';
                _answers[0] = "$systolicG";
                _textController.text = _answers[0] ?? '';
              } else {
                String systolicG = vitals["systolic"].toString() ?? '';
                _answers[0] = "$systolicG";
                _textController.text = _answers[0] ?? '';
              }
              break;
            case 1:
              if (vitals == null) {
                String diastolicG = '';
                _answers[1] = "$diastolicG";
              } else {
                String diastolicG = vitals["diastolic"].toString() ?? '';
                _answers[1] = "$diastolicG";
              }

              break;
            case 2:
              double weight = double.parse(_weight.toString());
              _answers[2] = weight.toStringAsFixed(2).toString() ?? "";
              break;
          }
        }
        if (mounted) setState(() => oldUi = true);
      }
    }
  }

  getKioskData() async {
    // await _determinePosition();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var res = jsonDecode(data);
    _token = res['Token'];
    _fName = res['User']['firstName'];
    _fName ??= '';
    _lName = res['User']['lastName'];
    _lName ??= '';
    _email = res['User']['email'];
    _email ??= '';
    // _age = dob;
    vitals = res["LastCheckin"];
    _iHLUserId = res['User']['id'];
    if (vitals != null) {
      if (vitals['heightMeters'] != null && vitals['weightKG'] != null) {
        _height = vitals['heightMeters'];
        _weight = vitals['weightKG'];
      } else {
        _height = res['User']['heightMeters'];
        _weight = res['User']['userInputWeightInKG'];
      }
    } else {
      _height = res['User']['heightMeters'];
      _weight = res['User']['userInputWeightInKG'];
    }

    await retrieveMedicalData();
    if (mounted) setState(() {});

    if (vitals != null) {
      vitals.removeWhere((key, value) =>
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
          key != "percent_body_fat_status" &&

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
          key != "temperatureClass" &&
          //waist_to_hip_ratio
          key != "waist_hip_ratio" &&
          key != "waist_hip_ratio_status" &&
          //visceral_fat
          key != "visceral_fat" &&
          key != "visceral_fat_status" &&
          //body_fat_mass
          key != "body_fat_mass" &&
          key != "body_fat_mass_status");

      final sharedUserVitalData = await SharedPreferences.getInstance(); //visceral_fat
      var d = jsonDecode(sharedUserVitalData.getString(SPKeys.vitalsData));
      valueForViseralFat = d[0];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      viseralFFat = prefs.getString('ViseralValue') ?? 0;
      if (prefs.get("vf_status") != null) {
        var visceralFatStatus = prefs.get("vf_status");
        if (visceralFatStatus == "high" || visceralFatStatus == "High") {
          visceralFats = 'yes';
        } else {
          visceralFats = 'no';
        }
      }

      systolic = vitals['systolic'].toString() ?? '';
      diastolic = vitals['diastolic'].toString() ?? '';
      String datePattern = "MM/dd/yyyy";
      var dob = res['User']['dateOfBirth'].toString();
      DateTime today = DateTime.now();
      DateTime birthDate = DateFormat(datePattern).parse(dob);
      _age = (today.year - birthDate.year).toString();
      _gender = res['User']['gender'];
      _gender.toLowerCase() == 'm' ? _gender = 'Male' : _gender = 'Female';
      vitals.forEach((key, value) {
        if (key == "weightKG") {
          vitals["weightKG"] = double.parse((value).toStringAsFixed(2)) ?? 0.0;
        }
        if (key == "heightMeters") {
          vitals["heightMeters"] = double.parse((value).toStringAsFixed(2)) ?? 0.0;
        }
      });
      vitals.removeWhere((key, value) => value == "");
    }
    if (vitals.toString() != "null" && vitals.toString() != "[]" && vitals.toString() != "") {
      age = res['User']['dateOfBirth'];
      gender = res['User']['gender'];
      height = vitals['heightMeters'] ?? '';
      weight = vitals['weightKG'];

      if (weight == null) weight = res['User']['userInputWeightInKG'];
      // heightController.text = vitals['heightMeters'].toString() ?? '';
      // weightController.text = vitals['weightKG'].toString() ?? '';
      // bmiController.text = vitals['bmi'].toStringAsFixed(2) ?? '';
      var _bp = vitals['systolic'].toString() + '/' + vitals['diastolic'].toString();
      bpController.text = _bp ?? '';
      bp = _bp ?? '';

      bmi = vitals['bmi'];
      bmi_status = vitals['bmiClass'];
      systolic_blood_pressure =
          vitals['systolic'].toString() + '/' + vitals['diastolic'].toString();
      systolic_blood_pressure_status = vitals['bpClass'];
      hasBp = true;
      if (_haveScore) {
      } else {
        if (systolic_blood_pressure_status == 'normal') {
          bPStatus = false;
          _answers[8] = 'no';
        } else {
          bPStatus = true;
          _answers[8] = 'yes';
        }
      }

      // percentage_body_fat = vitals['percent_body_fat'];
      // percentage_body_fat_status = vitals['percent_body_fat_status'];
      // body_fat_mass = vitals['body_fat_mass'];
      // body_fat_mass_status = vitals['body_fat_mass_status'];
      // visceral_fat = vitals['visceral_fat'];
      // visceral_fat_status = vitals['visceral_fat_status'];
      // waist_to_hip_ratio = vitals['waist_hip_ratio'];
      // waist_to_hip_ratio_status = vitals['waist_hip_ratio_status'];
      checkAvailabilityOfVitals();
    } else {
      vitalsExpired = 'Expired';
      loading = false;
      hasBp = false;
      if (mounted) setState(() {});
      // await createMarker();
    }
  }

  List notAvailableKeys = [];

  checkAvailabilityOfVitals() async {
    ///1.)  if vital are older than a week , Than show map
    var lastCheckinDateString =
        int.parse(vitals['dateTime'].toString().replaceAll('/Date(', '').replaceAll(')/', ''));
    DateTime lastCheckinDate = DateTime.fromMillisecondsSinceEpoch(lastCheckinDateString);
    if (_haveScore) {
      if (lastCheckinDate.isBefore(DateTime.now().subtract(Duration(days: 7)))) {
        vitalsExpired = 'Expired';
        loading = false;
        List keys = ['bmi', 'systolic', 'diastolic'];
        for (int i = 0; i < keys.length; i++) {
          if (vitals.containsKey(keys[i].toString())) {
            //nothing
          } else {
            notAvailableKeys.add(keys[i].toString());
          }
        }
        loading = false;
        if (notAvailableKeys.length > 0) vitalsExpired = 'Missing';
        if (mounted) setState(() => oldUi = false);
        // await createMarker();
      }

      /// 2.) vitals are latest -> than check all the vital are available or not
      else {
        List keys = ['bmi', 'systolic', 'diastolic'];
        for (int i = 0; i < keys.length; i++) {
          if (vitals.containsKey(keys[i].toString())) {
            //nothing
          } else {
            notAvailableKeys.add(keys[i].toString());
          }
        }
        loading = false;
        if (notAvailableKeys.length > 0) vitalsExpired = 'Missing';
        setState(() => oldUi = false);
      }
    } else {
      setState(() => oldUi = true);
    }
  }

  var _currentValue = '';
  bool _foodandactivityLoaded = true;
  bool _vitalLoaded = true;
  var cholesterol;

  Future getRecommendedFood() async {
    if (double.parse(_answers[3]) > 320) {
      setState(() {
        cholesterol = "yes";
      });
    } else {
      if (mounted)
        setState(() {
          cholesterol = "no";
        });
    }
    getData();

    var res = await http.post(Uri.parse('${API.iHLUrl}/empcardiohealth/recommended_food'),
        body: json.encode({
          //"meal_type": "mid_meal", //early_morning breakfast mid_meal
          "cholesterol": "yes",
          "hypertension": "yes",
          "visceral_fats": visceralFats ?? 'no',
          "dish_type": _answers[12] == "notGiven"
              ? "all"
              : _answers[12].toString() == "veg"
                  ? 'all'
                  : _answers[12], // _answers[11], //eggetarianAndNonveg,nonVeg,all
          "region": _answers[11] == "notGiven" ? [""] : [_answers[11].substring(0, 1)]
        }));
    if (res.statusCode == 200) {
      _recommendedDietMenuList = json.decode(res.body);
      // getData();
      sortingMeal();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _foodandactivityLoaded = false;
      if (mounted) setState(() {});
    }
  }

  Future getRecommendedActivity() async {
    var res = await http.post(Uri.parse('${API.iHLUrl}/empcardiohealth/recommended_activity'),
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
      _foodandactivityLoaded = false;
    }
  }

  Future<bool> willPopFunction() async {
    Navigator.pop(context);
  }

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
      return Color(0xffff9800);
    } else if (status == 'Intermediate') {
      return Colors.orange.shade200;
    } else if (status == 'High') {
      return Colors.redAccent.shade400;
    }
  }

  int dailytarget = 0;

  getScore() async {
    final preferences = await SharedPreferences.getInstance();
    score = score > 0 ? score : await preferences.getDouble('emp_cardio_score') ?? 0;
    await calculatestatus(score);
    txtStl1 = await riskStatusTxtStyle(score, 'High');
    txtStl2 = await riskStatusTxtStyle(score, 'Intermediate');
    txtStl3 = await riskStatusTxtStyle(score, 'Low');
    txtStl4 = await riskStatusTxtStyle(score, 'BorderLine');

    if (mounted) {
      setState(() {
        getScoreComplete = true;
      });
    }
  }

  calculateRiskLevel(score) {
    var txt = score >= 20
        ? 'High'
        : score < 20 && score >= 7.5
            ? 'Intermediate'
            : score < 7.5 && score >= 5
                ? 'Borderline'
                : 'Low';
    // clr = colorForStatus(txt);
    return txt;
  }

  Future cardiovascularDataSaveDBAPI() async {
    resultLoading
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(),
              );
            })
        : new Container();

    genericDateTime(DateTime dateTime) {
      String str = dateTime.toString();
      var str1 = str.substring(0, str.indexOf(' '));
      var str2 = str.substring(str1.length + 1, str1.length + 6);
      // return DateTime.parse('$str1 00:00:00');
      var ss = str1 + " " + str2;
      // return DateTime.parse('$str1 $str2'+':00');
      return '$str1 $str2' + ':00';
    }

    String dateTime = await genericDateTime(DateTime.now());

    // try{
    StoreMedicalData medicalDataValuesToStore = StoreMedicalData(
      cholesterol: _answers[3] == '' ? 0 : double.parse(_answers[3]),
      diastolicBloodPressure: _answers[1] == '' ? 0 : double.parse(_answers[1]),
      systolicBloodPressure: _answers[0] == '' ? 0 : double.parse(_answers[0]),
      hdl: _answers[5] == '' ? 0 : double.parse(_answers[5]),
      ldl: _answers[4] == '' ? 0 : double.parse(_answers[4]),
      gender: gender.toString().contains('m') ? 'm' : 'f',
      foodPreference: _answers[12].toString(),
      weight: _answers[2] == '' ? 0 : double.parse(_answers[2]),
      hasFamilyHistoryDiabetes: _answers[7].toString(),
      hasHypertensionTreatment: _answers[8] == "yes" || _answers[8] == "no"
          ? _answers[8].toString()
          : bPStatus
              ? "yes"
              : "no",
      onAspirinTheraphy: _answers[10].toString(),
      isSmoker: _answers[6].toString(),
      region: _answers[11].toString(),
      onStatin: _answers[9].toString(),
      ihlUserId: _iHLUserId.toString(),
      storeLogTime: dateTime.toString(),
    );
    _cardioController.updatingVitalValue = true;
    // }catch(e) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text('Failed to Store try Again'),
    //       backgroundColor: AppColors.failure,
    //       duration: Duration(seconds: 5)));
    //   print('CATCH${e.toString()}');
    // }

    // Map _d = {
    //   "store_log_time": dateTime,
    //   "ihl_user_id": _iHLUserId,
    //   "systolic_blood_pressure": _answers[0] == '' ? 0 : double.parse(_answers[0]),
    //   "diastolic_blood_pressure": _answers[1] == '' ? 0 : double.parse(_answers[1]),
    //   "weight": _answers[2] == '' ? 0 : double.parse(_answers[2]),
    //   "Cholesterol": _answers[3] == '' ? 0 : double.parse(_answers[3]),
    //   "ldl": _answers[4] == '' ? 0 : double.parse(_answers[4]),
    //   "hdl": _answers[5] == '' ? 0 : double.parse(_answers[5]),
    //   "is_smoker": _answers[6],
    //   // "smoker_type": _smokerType,
    //   "has_family_history_diabetes": _answers[7],
    //   "has_hypertension_treatment": _answers[8] == "yes" || _answers[8] == "no"
    //       ? _answers[8]
    //       : bPStatus
    //           ? "yes"
    //           : "no",
    //   "on_statin": _answers[9], //yes/no
    //   "on_aspirin_theraphy": _answers[10],
    //   "region": _answers[11],
    //   "food_preference": _answers[12], //yes/no
    //   "gender": gender.toString().contains('m') ? 'm' : 'f',
    // };
    // print('=========$_d');

    ///todo =>  get the questionariie data here and send in the api but what about the score.
    try {
      final response = await http.post(
        Uri.parse(API.iHLUrl + '/empcardiohealth/store_medical_data'),
        headers: {
          'Content-Type': 'application/json',
          'Token': _token,
          'ApiToken':
              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
        },
        body: json.encode(medicalDataValuesToStore.toJson()),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (response.body != 'null' && response.body != '' && data["status"] != "failed") {
          // var markersDetails = data;
          if (data['response'] == 'exception') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to Calculate try Again'),
                backgroundColor: AppColors.failure,
                duration: Duration(seconds: 5)));
          } else {
            score = data['response'];
            final preferences = await SharedPreferences.getInstance();
            await preferences.setDouble('emp_cardio_score', score.toDouble());
            await Get.find<CardioGetXController>().updateUserdata();
            await retrieveMedicalData();
            setState(() {
              resultLoading = false;
            });
            return data;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to Store try Again'),
              backgroundColor: AppColors.failure,
              duration: Duration(seconds: 5)));
          setState(() => oldUi = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to Store try Again'),
            backgroundColor: AppColors.failure,
            duration: Duration(seconds: 5)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to Store try Again'),
          backgroundColor: AppColors.failure,
          duration: Duration(seconds: 5)));
      print(e.toString());
    }
  }

  Future<TextStyle> riskStatusTxtStyle(score, txt) async {
    String con = await calculatestatus(score);
    return TextStyle(
      color: con == txt ? colorForStatus(txt) : Colors.white70,
      //Colors.yellow.shade900,
      fontSize: getFontSize(
        con == txt ? 15 : 14,
      ),
      fontFamily: 'Poppins',
      shadows: [
        Shadow(
          offset: Offset(0.0, 0.0),
          blurRadius: 0.0,
          color: Colors.green.shade900,
        ),
        Shadow(
          offset: Offset(0.0, 0.0),
          blurRadius: 0.0,
          color: Colors.green.shade900,
        ),
      ],
      fontWeight: con == txt ? FontWeight.w700 : FontWeight.w500,
      letterSpacing: con == txt ? .48 : .42,
    );
  }

  Future<void> showPopupMenuDialog(BuildContext context, var chscore, String txt) async {
    // bool isChecking = false;
    // bool makeValidateVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // String reasonRadioBtnVal = "";
        // final _formKey = GlobalKey<FormState>();
        return WillPopScope(
          onWillPop: () {
            // Get.offAll(CardioDashboardNew(cond: true,));
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(12.0, 1.0, 12.0, 12.0),
            insetPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.fromLTRB(1.0, 5.0, 1.0, 1.0),
            elevation: 10,
            // backgroundColor: Colors.blue.shade400,
            title: Text(
              'Cardiovascular\n'
              'Test Result',
              style: TextStyle(
                color: FitnessAppTheme.grey,
                fontSize: ScUtil().setSp(20),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                if (resultLoading == false) {
                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SizedBox(height: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Center(
                                  child: Text(txt,
                                      style: TextStyle(
                                          fontSize: ScUtil().setSp(22),
                                          color: colorForStatus(txt),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins'))),
                              Center(
                                  child: Text("$chscore",
                                      style: TextStyle(
                                          fontSize: ScUtil().setSp(50),
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins'))),
                              // Center(child: Text("Score", style: TextStyle(fontSize:  ScUtil().setSp(22), color:AppColors.appTextColor,fontWeight: FontWeight.w600,fontFamily: 'Poppins'))),
                              SizedBox(height: ScUtil().setHeight(10)),
                              SfLinearGauge(
                                  interval: 10.0,
                                  ranges: <LinearGaugeRange>[
                                    LinearGaugeRange(
                                      startValue: 0,
                                      endValue: 4.9,
                                      color: colorForStatus('Low'),
                                    ),
                                    LinearGaugeRange(
                                      startValue: 5,
                                      endValue: 7.4,
                                      color: colorForStatus('Borderline'),
                                    ),
                                    LinearGaugeRange(
                                      startValue: 7.5,
                                      endValue: 20,
                                      color: colorForStatus('Intermediate'),
                                    ),
                                    LinearGaugeRange(
                                      startValue: 21,
                                      endValue: 100,
                                      color: colorForStatus('High'),
                                    )
                                  ],
                                  minimum: 0,
                                  maximum: 100,
                                  markerPointers: [LinearShapePointer(value: chscore ?? 50.4)]),
                              SizedBox(height: ScUtil().setHeight(15)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Disclaimer ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: getFontSize(
                                        14,
                                      ),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.42,
                                    ),
                                  ),
                                ),
                                Text(
                                  "IHL heart health calculator is only indicative & doesn't give any conclusive results or recommendations. Consult your Doctor in case of any heart health-related symptoms, diagnosis & treatment",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: getFontSize(
                                      14,
                                    ),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.42,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScUtil().setHeight(10)),
                          Center(
                            child: Container(
                              child: ButtonTheme(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Navigator.pushAndRemoveUntil(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           CardioDashboard(),
                                    //     ),
                                    //     (Route<dynamic> route) => false);
                                    final preferences = await SharedPreferences.getInstance();
                                    await preferences.setDouble(
                                        'emp_cardio_score', chscore.toDouble());
                                    await preferences.setBool(SPKeys.firstVisit, true);
                                    Get.offAll(CardioDashboardNew(
                                      cond: true,
                                      tabView: false,
                                    ));
                                  },
                                  child: Text("Dashboard"),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30)),
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                    backgroundColor: AppColors.primaryAccentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Center(child: CircularProgressIndicator()),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _analyseWidget() => Container(
        margin: EdgeInsets.only(
          left: getHorizontalSize(
            20,
          ),
          top: getVerticalSize(
            30,
          ),
          right: getHorizontalSize(
            20,
          ),
          bottom: getVerticalSize(
            30,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              34,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: getHorizontalSize(
              5,
            ),
            top: getVerticalSize(
              5,
            ),
            right: getHorizontalSize(
              5,
            ),
            bottom: getVerticalSize(
              5,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() => _currenttest++);
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         // ShowingKisokValues(),
              //         ShowRequiredTest(),
              //   ),
              // );
              // navigateOnCall(context);
              // billView(context, 'invoiceNo',true);
              // rsrs(context, 'invoiceNo1',true);
            },
            child: Container(
              alignment: Alignment.center,
              height: getVerticalSize(
                40,
              ),
              width: getHorizontalSize(
                106,
              ),
              padding: EdgeInsets.only(
                left: getHorizontalSize(
                  10,
                ),
                top: getVerticalSize(
                  13,
                ),
                right: getHorizontalSize(
                  10,
                ),
                bottom: getVerticalSize(
                  10,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  getHorizontalSize(
                    50,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    spreadRadius: getHorizontalSize(
                      2,
                    ),
                    blurRadius: getHorizontalSize(
                      2,
                    ),
                    offset: Offset(
                      0,
                      2,
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(Icons.refresh,color: Colors.white70,size: 15,),

                  Text(
                    'Proceed',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: getFontSize(
                        12,
                      ),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _circularScoreWidget() => Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white.withOpacity(0.9),
        borderRadius: BorderRadius.all(
          Radius.circular(100.0),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.2),
              offset: Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      // width: ScUtil()
      //     .setWidth(140),
      // height: ScUtil()
      //     .setHeight(140),
      child: Container(
          width: ScUtil().setWidth(120),
          height: ScUtil().setHeight(100),
          decoration: BoxDecoration(
            color: FitnessAppTheme.white,
            borderRadius: BorderRadius.all(
              Radius.circular(80.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: FitnessAppTheme.grey.withOpacity(0.2),
                  offset: Offset(1.1, 1.1),
                  blurRadius: 10.0),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: true,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ScUtil().setWidth(34),
                    ),
                    Text(
                      '$score',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.normal,
                        fontSize: ScUtil().setSp(29),
                        letterSpacing: 0.0,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      ' %',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.normal,
                          fontSize: ScUtil().setSp(25),
                          letterSpacing: 0.0,
                          color: FitnessAppTheme.grey.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              Text(
                'Score',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: ScUtil().setSp(14),
                  letterSpacing: 0.0,
                  color: FitnessAppTheme.grey.withOpacity(0.5),
                ),
              ),
            ],
          )));
  bool oldUi = true;
  bool resultLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _editKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Size size = MediaQuery.of(context).size;
    print("***** " + size.width.toString() + size.height.toString());
    return oldUi
        ? WillPopScope(
            onWillPop: willPopFunction,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primaryAccentColor,
                leading: IconButton(
// <<<<<<< Updated upstream
//                   // onPressed: () => Get.offAll(HomeScreen(
//                   //   introDone: true,
//                   // )),
//                   onPressed: () => Get.offAll(Home()),
// =======
                  onPressed: () {
                    Get.offAll(LandingPage());
                  },
// >>>>>>> Stashed changes
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
                title: Text(
                  'Heart Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getFontSize(
                      28,
                    ),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.28,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: HeaderClipper(82),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            // color: AppColors.primaryAccentColor.withOpacity(0.3),
                            // color: FitnessAppTheme.grey.withOpacity(0.1),
                            color: AppColors.primaryAccentColor,
                            height: size.height * 0.575,
                            width: size.width,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: getHorizontalSize(28),
                            top: getVerticalSize(0),
                            right: getHorizontalSize(28),
                            bottom: getVerticalSize(7),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Management',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: getFontSize(
                                        28,
                                      ),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.28,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Gap(25),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: getVerticalSize(
                                      10,
                                    ),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: 'Make your',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: getFontSize(
                                              13,
                                            ),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.26,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' cardiovascular health',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: getFontSize(
                                              13,
                                            ),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.26,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: getFontSize(
                                              13,
                                            ),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.26,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'better.',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            // color: AppColors.primaryAccentColor,
                                            fontSize: getFontSize(
                                              13,
                                            ),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.26,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: getVerticalSize(
                                    60,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 10),
                                              height: getVerticalSize(420),
                                              width: getHorizontalSize(305),
                                              decoration: BoxDecoration(
                                                color: Colors.black87.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(
                                                  getHorizontalSize(26),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: AnimatedContainer(
                                              width: getHorizontalSize(300),
                                              duration: Duration(milliseconds: 500),
                                              height: getVerticalSize(_currenttest < 5
                                                  ? 480
                                                  : _currenttest > 10
                                                      ? 520
                                                      : 450),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFFFFFFF),
                                                  borderRadius: BorderRadius.circular(
                                                    getHorizontalSize(
                                                      26,
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey.withOpacity(0.5),
                                                        offset: Offset(1, 2),
                                                        blurRadius: 3,
                                                        spreadRadius: 1.0)
                                                  ]),
                                              child: _questionScreen
                                                  ? Form(
                                                      key: _formKey,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              width: getHorizontalSize(245),
                                                              margin: EdgeInsets.only(
                                                                left: getHorizontalSize(10),
                                                                top: getVerticalSize(40),
                                                                right: getHorizontalSize(10),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.center,
                                                                mainAxisSize: MainAxisSize.max,
                                                                children: [
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Text(
                                                                        _heading[_currenttest],
                                                                        // "Heart Health",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                          color: AppColors
                                                                              .primaryColor,
                                                                          fontSize: getFontSize(
                                                                            _currenttest == 8
                                                                                ? 17
                                                                                : 20,
                                                                          ),
                                                                          fontFamily: 'Poppins',
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          letterSpacing: 0.42,
                                                                        ),
                                                                      ),
                                                                      Visibility(
                                                                        visible:
                                                                            _question[_currenttest]
                                                                                ['optional'],
                                                                        child: Text(
                                                                          '(Optional)',
                                                                          // "Heart Health",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          textAlign: TextAlign.left,
                                                                          style: TextStyle(
                                                                            color: AppColors
                                                                                .primaryColor,
                                                                            fontSize: getFontSize(
                                                                              12,
                                                                            ),
                                                                            fontFamily: 'Poppins',
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            letterSpacing: 1.2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            _question[_currenttest]['choose'] !=
                                                                    null
                                                                ? SizedBox.shrink()
                                                                : const Gap(14),
                                                            Container(
                                                              width: getHorizontalSize(
                                                                250,
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                children: [
                                                                  const Gap(10),
                                                                  // Visibility(
                                                                  //   visible:
                                                                  //       false,
                                                                  //   child:
                                                                  //       SizedBox(
                                                                  //     height:
                                                                  //         getVerticalSize(60),
                                                                  //     child:
                                                                  //         Text(
                                                                  //       "Your Last Known ${_heading[_currenttest]} is ${_lastRetriveData[_lastRetrieveKeys[_currenttest]]}",
                                                                  //       style: TextStyle(
                                                                  //         color: AppColors.primaryColor,
                                                                  //         fontSize: getFontSize(
                                                                  //           14,
                                                                  //         ),
                                                                  //         fontFamily: 'Poppins',
                                                                  //         fontWeight: FontWeight.w600,
                                                                  //         letterSpacing: 0.42,
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // ),

                                                                  SizedBox(
                                                                    height: getVerticalSize(60),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          _question[_currenttest]
                                                                              ['question'],
                                                                          style: TextStyle(
                                                                            color: AppColors
                                                                                .primaryColor,
                                                                            fontSize: getFontSize(
                                                                              14,
                                                                            ),
                                                                            fontFamily: 'Poppins',
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            letterSpacing: 0.42,
                                                                          ),
                                                                          textAlign: TextAlign.left,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  _question[_currenttest]
                                                                              ['choose'] !=
                                                                          null
                                                                      ? SizedBox.shrink()
                                                                      : Gap(10),
                                                                  _question[_currenttest]['option']
                                                                      ? _question[_currenttest]
                                                                                  ['choose'] !=
                                                                              null
                                                                          ? SizedBox(
                                                                              height: 210,
                                                                              child:
                                                                                  ListView.builder(
                                                                                itemCount: _question[
                                                                                            _currenttest]
                                                                                        ['choose']
                                                                                    .length,
                                                                                itemBuilder:
                                                                                    (ctx, index) {
                                                                                  return RadioListTile(
                                                                                    groupValue:
                                                                                        _currentValue,
                                                                                    value: _question[
                                                                                                _currenttest]
                                                                                            [
                                                                                            'choose']
                                                                                        [index][0],
                                                                                    onChanged: (v) {
                                                                                      setState(() {
                                                                                        _answers[
                                                                                            _currenttest] = v;
                                                                                        _currentValue =
                                                                                            v;
                                                                                      });
                                                                                    },
                                                                                    title: Text(_question[
                                                                                                _currenttest]
                                                                                            [
                                                                                            'choose']
                                                                                        [index][1]),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            )
                                                                          : Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceEvenly,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                    onPressed: () {
                                                                                      if (_currenttest ==
                                                                                          6) {
                                                                                        Get.defaultDialog(
                                                                                            title: 'Choose Type',
                                                                                            barrierDismissible: false,
                                                                                            content: Row(
                                                                                              mainAxisAlignment:
                                                                                                  MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                ElevatedButton(
                                                                                                  onPressed: () {
                                                                                                    _smokerType = 'current';
                                                                                                    setState(() => _answers[_currenttest] = 'yes');
                                                                                                    Get.back();
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'Current',
                                                                                                    style: TextStyle(color: _smokerType == 'current' ? Colors.white : AppColors.primaryColor),
                                                                                                  ),
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    primary: _smokerType == 'current' ? AppColors.primaryColor : Colors.white,
                                                                                                  ),
                                                                                                ),
                                                                                                ElevatedButton(
                                                                                                  onPressed: () {
                                                                                                    _smokerType = 'former';
                                                                                                    setState(() => _answers[_currenttest] = 'yes');
                                                                                                    Get.back();
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'Former',
                                                                                                    style: TextStyle(color: _smokerType == 'former' ? Colors.white : AppColors.primaryColor),
                                                                                                  ),
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    primary: _smokerType == 'former' ? AppColors.primaryColor : Colors.white,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ));
                                                                                      } else {
                                                                                        setState(() =>
                                                                                            _answers[_currenttest] =
                                                                                                'yes');
                                                                                      }
                                                                                    },
                                                                                    style: ElevatedButton
                                                                                        .styleFrom(
                                                                                      primary: _answers[
                                                                                                  _currenttest] ==
                                                                                              'yes'
                                                                                          ? AppColors
                                                                                              .primaryColor
                                                                                          : Colors
                                                                                              .white,
                                                                                    ),
                                                                                    child: Text(
                                                                                      'Yes',
                                                                                      style: TextStyle(
                                                                                          color: _answers[_currenttest] ==
                                                                                                  'yes'
                                                                                              ? Colors
                                                                                                  .white
                                                                                              : AppColors
                                                                                                  .primaryColor),
                                                                                    )),
                                                                                ElevatedButton(
                                                                                    onPressed: () {
                                                                                      if (_currenttest ==
                                                                                          6)
                                                                                        _smokerType =
                                                                                            'N/A';
                                                                                      setState(() =>
                                                                                          _answers[
                                                                                                  _currenttest] =
                                                                                              'no');
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                        primary: _answers[_currenttest] ==
                                                                                                'no'
                                                                                            ? AppColors
                                                                                                .primaryColor
                                                                                            : Colors
                                                                                                .white),
                                                                                    child: Text(
                                                                                        'No',
                                                                                        style: TextStyle(
                                                                                            color: _answers[_currenttest] ==
                                                                                                    'no'
                                                                                                ? Colors.white
                                                                                                : AppColors.primaryColor))),
                                                                              ],
                                                                            )
                                                                      : TextFormField(
                                                                          controller:
                                                                              _textController,
                                                                          keyboardType:
                                                                              _currenttest < 6
                                                                                  ? TextInputType
                                                                                      .number
                                                                                  : TextInputType
                                                                                      .name,
                                                                          validator: (v) {
                                                                            int valu = int.parse(
                                                                                v.split(RegExp(
                                                                                    r"(\.+)"))[0]);
                                                                            if (v.isEmpty) {
                                                                              return _errors[
                                                                                  _currenttest];
                                                                            } else if (valu <
                                                                                    _validate[
                                                                                            _currenttest]
                                                                                        [0] ||
                                                                                valu >
                                                                                    _validate[
                                                                                            _currenttest]
                                                                                        [1]) {
                                                                              return 'Please enter value between ${_validate[_currenttest][0]} - ${_validate[_currenttest][1]}';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          enableSuggestions: true,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            floatingLabelBehavior:
                                                                                FloatingLabelBehavior
                                                                                    .never,
                                                                            labelText: _heading[
                                                                                _currenttest],
                                                                            labelStyle: TextStyle(
                                                                              color: Colors.grey,
                                                                            ),
                                                                            hintText: _hints[
                                                                                _currenttest],
                                                                            hintStyle: TextStyle(
                                                                                color: AppColors
                                                                                    .primaryColor
                                                                                    .withOpacity(
                                                                                        0.3),
                                                                                fontSize: size
                                                                                            .width >
                                                                                        360
                                                                                    ? getFontSize(
                                                                                        size.width /
                                                                                            28)
                                                                                    : 12.5),
                                                                            alignLabelWithHint:
                                                                                false,
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          15.0),
                                                                              borderSide:
                                                                                  const BorderSide(
                                                                                color: AppColors
                                                                                    .primaryColor,
                                                                              ),
                                                                            ),
                                                                            filled: true,
                                                                            fillColor: Colors.white,
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                              borderSide:
                                                                                  const BorderSide(
                                                                                color: AppColors
                                                                                    .primaryColor,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          style: TextStyle(
                                                                              color: Colors.black),
                                                                        ),
                                                                  _currenttest > 10
                                                                      ? SizedBox.shrink()
                                                                      : const Gap(25),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        _currenttest > 0
                                                                            ? MainAxisAlignment
                                                                                .spaceEvenly
                                                                            : MainAxisAlignment
                                                                                .center,
                                                                    children: [
                                                                      Visibility(
                                                                        visible: _currenttest > 0,
                                                                        child: Container(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          margin: EdgeInsets.only(
                                                                            top: getVerticalSize(
                                                                              20,
                                                                            ),
                                                                            bottom: getVerticalSize(
                                                                              20,
                                                                            ),
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.white70,
                                                                            borderRadius:
                                                                                BorderRadius
                                                                                    .circular(
                                                                              getHorizontalSize(
                                                                                34,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child: Padding(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              left:
                                                                                  getHorizontalSize(
                                                                                5,
                                                                              ),
                                                                              top: getVerticalSize(
                                                                                5,
                                                                              ),
                                                                              right:
                                                                                  getHorizontalSize(
                                                                                5,
                                                                              ),
                                                                              bottom:
                                                                                  getVerticalSize(
                                                                                5,
                                                                              ),
                                                                            ),
                                                                            child: Container(
                                                                              alignment:
                                                                                  Alignment.center,
                                                                              height:
                                                                                  getVerticalSize(
                                                                                40,
                                                                              ),
                                                                              width:
                                                                                  getHorizontalSize(
                                                                                90,
                                                                              ),
                                                                              padding:
                                                                                  EdgeInsets.only(
                                                                                left:
                                                                                    getHorizontalSize(
                                                                                  10,
                                                                                ),
                                                                                right:
                                                                                    getHorizontalSize(
                                                                                  10,
                                                                                ),
                                                                              ),
                                                                              decoration:
                                                                                  BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                  getHorizontalSize(
                                                                                    50,
                                                                                  ),
                                                                                ),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors
                                                                                        .black54,
                                                                                    spreadRadius:
                                                                                        getHorizontalSize(
                                                                                      2,
                                                                                    ),
                                                                                    blurRadius:
                                                                                        getHorizontalSize(
                                                                                      2,
                                                                                    ),
                                                                                    offset: Offset(
                                                                                      0,
                                                                                      2,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: TextButton(
                                                                                onPressed: () {
                                                                                  if (_currenttest >
                                                                                      0) {
                                                                                    _textController
                                                                                        .clear();
                                                                                    if (_currenttest ==
                                                                                            9 &&
                                                                                        hasBp) {
                                                                                      setState(() =>
                                                                                          _currenttest =
                                                                                              8);
                                                                                    }
                                                                                    _currenttest--;
                                                                                    _textController
                                                                                            .text =
                                                                                        _answers[
                                                                                            _currenttest];

                                                                                    setState(() {});
                                                                                  }
                                                                                },
                                                                                child: Text(
                                                                                  'Prev',
                                                                                  textAlign:
                                                                                      TextAlign
                                                                                          .left,
                                                                                  style: TextStyle(
                                                                                    color: Colors
                                                                                        .black,
                                                                                    fontSize:
                                                                                        getFontSize(
                                                                                      15,
                                                                                    ),
                                                                                    fontFamily:
                                                                                        'Poppins',
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .w600,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        alignment: Alignment.center,
                                                                        margin: EdgeInsets.only(
                                                                          top: getVerticalSize(
                                                                            20,
                                                                          ),
                                                                          bottom: getVerticalSize(
                                                                            20,
                                                                          ),
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white70,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            getHorizontalSize(
                                                                              34,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: EdgeInsets.only(
                                                                            left: getHorizontalSize(
                                                                              5,
                                                                            ),
                                                                            top: getVerticalSize(
                                                                              5,
                                                                            ),
                                                                            right:
                                                                                getHorizontalSize(
                                                                              5,
                                                                            ),
                                                                            bottom: getVerticalSize(
                                                                              5,
                                                                            ),
                                                                          ),
                                                                          child: Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            height: getVerticalSize(
                                                                              40,
                                                                            ),
                                                                            width:
                                                                                getHorizontalSize(
                                                                              95,
                                                                            ),
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              left:
                                                                                  getHorizontalSize(
                                                                                10,
                                                                              ),
                                                                              right:
                                                                                  getHorizontalSize(
                                                                                10,
                                                                              ),
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                getHorizontalSize(
                                                                                  50,
                                                                                ),
                                                                              ),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors
                                                                                      .black54,
                                                                                  spreadRadius:
                                                                                      getHorizontalSize(
                                                                                    2,
                                                                                  ),
                                                                                  blurRadius:
                                                                                      getHorizontalSize(
                                                                                    2,
                                                                                  ),
                                                                                  offset: Offset(
                                                                                    0,
                                                                                    2,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: TextButton(
                                                                              onPressed: () async {
                                                                                if (_currenttest <
                                                                                    _question
                                                                                            .length -
                                                                                        1) {
                                                                                  if (_currenttest <
                                                                                      6) {
                                                                                    if (_formKey
                                                                                        .currentState
                                                                                        .validate()) {
                                                                                      _answers[
                                                                                              _currenttest] =
                                                                                          _textController
                                                                                              .text;
                                                                                      _currenttest++;
                                                                                      if (_answers[
                                                                                              _currenttest] ==
                                                                                          '') {
                                                                                        _textController
                                                                                            .clear();
                                                                                      } else {
                                                                                        _textController
                                                                                                .text =
                                                                                            _answers[
                                                                                                _currenttest];
                                                                                      }
                                                                                      setState(
                                                                                          () {});
                                                                                    }
                                                                                  } else {
                                                                                    if (_answers[
                                                                                            _currenttest] ==
                                                                                        '') {
                                                                                      if (_currenttest ==
                                                                                              9 ||
                                                                                          _currenttest ==
                                                                                              10) {
                                                                                        _answers[
                                                                                                _currenttest] =
                                                                                            'notGiven';
                                                                                        setState(() =>
                                                                                            _currenttest++);
                                                                                      }
                                                                                    } else {
                                                                                      if (_currenttest ==
                                                                                              7 &&
                                                                                          hasBp) {
                                                                                        setState(() =>
                                                                                            _currenttest =
                                                                                                8);
                                                                                      }
                                                                                      setState(() =>
                                                                                          _currenttest++);

                                                                                      if (_currenttest ==
                                                                                          11) {
                                                                                        _currentValue =
                                                                                            _answers[
                                                                                                11];
                                                                                      } else if (_currenttest ==
                                                                                          12) {
                                                                                        _currentValue =
                                                                                            _answers[
                                                                                                12];
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  if (mounted) {
                                                                                    setState(() {
                                                                                      resultLoading =
                                                                                          true;
                                                                                    });
                                                                                  }
                                                                                  if (_answers[
                                                                                          _currenttest] !=
                                                                                      '') {
                                                                                    await cardiovascularDataSaveDBAPI();

                                                                                    var txt =
                                                                                        calculateRiskLevel(
                                                                                            score);
                                                                                    score > 0
                                                                                        ? await showPopupMenuDialog(
                                                                                            context,
                                                                                            score
                                                                                                .toDouble(),
                                                                                            txt)
                                                                                        : Get.offAll(
                                                                                            CardioDashboardNew(
                                                                                            tabView:
                                                                                                false,
                                                                                          ));
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: Text(
                                                                                _currenttest <
                                                                                        _question
                                                                                                .length -
                                                                                            1
                                                                                    ? 'Next'
                                                                                    : 'Proceed',
                                                                                textAlign:
                                                                                    TextAlign.left,
                                                                                style: TextStyle(
                                                                                  color:
                                                                                      Colors.black,
                                                                                  fontSize:
                                                                                      getFontSize(
                                                                                    15,
                                                                                  ),
                                                                                  fontFamily:
                                                                                      'Poppins',
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .w600,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  // _analyseWidget(),
                                                                  _currenttest > 10
                                                                      ? SizedBox.shrink()
                                                                      : const Gap(45),
                                                                  SizedBox(
                                                                    height: getVerticalSize(18),
                                                                    width: getHorizontalSize(225),
                                                                    child: ListView.builder(
                                                                      itemBuilder: (ctx, index) =>
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  50),
                                                                          color: _currenttest ==
                                                                                  index
                                                                              ? AppColors
                                                                                  .primaryAccentColor
                                                                              : Colors.grey,
                                                                        ),
                                                                        margin: EdgeInsets.all(4),
                                                                        width: 10,
                                                                      ),
                                                                      itemCount: _question.length,
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                    ),
                                                                  ),
                                                                  // _circularScoreWidget(),
                                                                  Visibility(
                                                                    visible: (2 < _currenttest) &&
                                                                        (_currenttest < 6),
                                                                    child: TextButton(
                                                                      onPressed: () async {
                                                                        if (_currenttest !=
                                                                            _answers.length - 1) {
                                                                          if (_currenttest >= 6) {
                                                                            if (_currenttest == 7 &&
                                                                                hasBp) {
                                                                              _currenttest = 8;
                                                                              setState(() =>
                                                                                  _currenttest++);
                                                                            } else {
                                                                              setState(() {
                                                                                _answers[
                                                                                        _currenttest] =
                                                                                    "notGiven";
                                                                                _currenttest++;
                                                                              });
                                                                            }
                                                                          } else {
                                                                            setState(() {
                                                                              _answers[
                                                                                      _currenttest] =
                                                                                  '0';
                                                                              _currenttest++;
                                                                            });
                                                                          }
                                                                        } else {
                                                                          if (mounted) {
                                                                            setState(() {
                                                                              resultLoading = true;
                                                                            });
                                                                          }
                                                                          if (_answers[
                                                                                  _currenttest] !=
                                                                              '') {
                                                                            var chscore =
                                                                                await cardiovascularDataSaveDBAPI();
                                                                            var txt =
                                                                                calculateRiskLevel(
                                                                                    score);
                                                                            score > 0
                                                                                ? await showPopupMenuDialog(
                                                                                    context,
                                                                                    score
                                                                                        .toDouble(),
                                                                                    txt)
                                                                                : Get.offAll(
                                                                                    CardioDashboardNew(
                                                                                        tabView:
                                                                                            false),
                                                                                  );
                                                                          }
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                        'Skip',
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                          color: AppColors
                                                                              .primaryColor,
                                                                          fontSize: getFontSize(16),
                                                                          fontFamily: 'Poppins',
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          letterSpacing: 1.25,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                          Lottie.asset(
                                                            'assets/lottieFiles/hearthealth.json',
                                                            height: getVerticalSize(200),
                                                            width: getHorizontalSize(200),
                                                            fit: BoxFit.contain,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              'To know your heart health score , answer few questions related to your health.',
                                                              style: TextStyle(
                                                                color: AppColors.primaryColor,
                                                                fontSize: getFontSize(
                                                                  16,
                                                                ),
                                                                fontFamily: 'Poppins',
                                                                fontWeight: FontWeight.w600,
                                                                letterSpacing: 0.42,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          Gap(10),
                                                          Container(
                                                            alignment: Alignment.center,
                                                            width: getHorizontalSize(105),
                                                            margin: EdgeInsets.only(
                                                              top: getVerticalSize(
                                                                20,
                                                              ),
                                                              bottom: getVerticalSize(
                                                                20,
                                                              ),
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white70,
                                                              borderRadius: BorderRadius.circular(
                                                                getHorizontalSize(
                                                                  34,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                left: getHorizontalSize(
                                                                  5,
                                                                ),
                                                                top: getVerticalSize(
                                                                  5,
                                                                ),
                                                                right: getHorizontalSize(
                                                                  5,
                                                                ),
                                                                bottom: getVerticalSize(
                                                                  5,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                alignment: Alignment.center,
                                                                height: getVerticalSize(
                                                                  40,
                                                                ),
                                                                width: getHorizontalSize(
                                                                  95,
                                                                ),
                                                                padding: EdgeInsets.only(
                                                                  left: getHorizontalSize(
                                                                    10,
                                                                  ),
                                                                  right: getHorizontalSize(
                                                                    10,
                                                                  ),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                    getHorizontalSize(
                                                                      50,
                                                                    ),
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black54,
                                                                      spreadRadius:
                                                                          getHorizontalSize(
                                                                        2,
                                                                      ),
                                                                      blurRadius: getHorizontalSize(
                                                                        2,
                                                                      ),
                                                                      offset: Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: TextButton(
                                                                  onPressed: () async {
                                                                    setState(() =>
                                                                        _questionScreen = true);
                                                                  },
                                                                  child: Text(
                                                                    'Proceed',
                                                                    textAlign: TextAlign.left,
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: getFontSize(
                                                                        size.width / 30,
                                                                      ),
                                                                      fontFamily: 'Poppins',
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : CardioDashboardNew(
            tabView: false,
          );
    // DietJournalUI(
    //        appBar: AppBar(
    //          leading: IconButton(
    //            onPressed: () => Get.offAll(HomeScreen(
    //              introDone: true,
    //            )),
    //            icon: Icon(Icons.arrow_right_alt),
    //            color: Colors.white,
    //          ),
    //          backgroundColor: Colors.transparent,
    //          elevation: 0,
    //          automaticallyImplyLeading: false,
    //          title: Text(
    //            "Heart Health",
    //            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
    //          ),
    //          centerTitle: true,
    //        ),
    //        body: SingleChildScrollView(
    //          child: Column(
    //            crossAxisAlignment: CrossAxisAlignment.start,
    //            children: [
    //              Padding(
    //                padding: EdgeInsets.only(
    //                    left: ScUtil().setWidth(16),
    //                    right: ScUtil().setWidth(16),
    //                    top: ScUtil().setHeight(18),
    //                    bottom: ScUtil().setHeight(16)),
    //                child: InkWell(
    //                  onTap: score > 0
    //                      ? () => Get.to(
    //                          InfoScreen(
    //                            score: score.toInt(),
    //                          ),
    //                          transition: Transition.rightToLeft)
    //                      : () => setState(() => oldUi = true),
    //                  child: Container(
    //                    decoration: BoxDecoration(
    //                      color: FitnessAppTheme.white,
    //                      borderRadius: BorderRadius.only(
    //                          topLeft: Radius.circular(8.0),
    //                          bottomLeft: Radius.circular(8.0),
    //                          bottomRight: Radius.circular(8.0),
    //                          topRight: Radius.circular(68.0)),
    //                      boxShadow: <BoxShadow>[
    //                        BoxShadow(
    //                            color: FitnessAppTheme.grey.withOpacity(0.2),
    //                            offset: Offset(1.1, 1.1),
    //                            blurRadius: 10.0),
    //                      ],
    //                    ),
    //                    child: score > 0
    //                        ? Column(
    //                            children: <Widget>[
    //                              Padding(
    //                                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
    //                                padding: EdgeInsets.only(left: ScUtil().setWidth(10)),
    //                                child: Row(
    //                                  children: <Widget>[
    //                                    Expanded(
    //                                      child: Padding(
    //                                          padding: EdgeInsets.only(
    //                                            left: ScUtil().setWidth(8),
    //                                            right: ScUtil().setWidth(8),
    //                                          ),
    //                                          child: Column(
    //                                            children: <Widget>[
    //                                              Row(
    //                                                children: <Widget>[
    //                                                  Container(
    //                                                    height: ScUtil().setWidth(48),
    //                                                    width: ScUtil().setHeight(2),
    //                                                    decoration: BoxDecoration(
    //                                                      color: AppColors.primaryColor
    //                                                          .withOpacity(0.5),
    //                                                      borderRadius: BorderRadius.all(
    //                                                          Radius.circular(4.0)),
    //                                                    ),
    //                                                  ),
    //                                                  Padding(
    //                                                      padding: EdgeInsets.symmetric(
    //                                                          horizontal: ScUtil().setWidth(8),
    //                                                          vertical: ScUtil().setHeight(8)),
    //                                                      child: Column(
    //                                                        mainAxisAlignment:
    //                                                            MainAxisAlignment.center,
    //                                                        crossAxisAlignment:
    //                                                            CrossAxisAlignment.start,
    //                                                        children: <Widget>[
    //                                                          Padding(
    //                                                            padding: EdgeInsets.only(
    //                                                                left: ScUtil().setHeight(4),
    //                                                                bottom: ScUtil().setHeight(2)),
    //                                                            child: Row(
    //                                                              mainAxisAlignment:
    //                                                                  MainAxisAlignment.start,
    //                                                              children: [
    //                                                                Text(
    //                                                                  'Status',
    //                                                                  textAlign: TextAlign.center,
    //                                                                  style: TextStyle(
    //                                                                    fontFamily: FitnessAppTheme
    //                                                                        .fontName,
    //                                                                    fontWeight: FontWeight.w500,
    //                                                                    fontSize: 16,
    //                                                                    letterSpacing: -0.1,
    //                                                                    color: FitnessAppTheme.grey
    //                                                                        .withOpacity(0.5),
    //                                                                  ),
    //                                                                ),
    //                                                                Gap(5),
    //                                                                Visibility(
    //                                                                  visible: true,
    //                                                                  child: Icon(
    //                                                                    Icons.info,
    //                                                                    color:
    //                                                                        AppColors.primaryColor,
    //                                                                    size: getSize(21),
    //                                                                  ),
    //                                                                )
    //                                                              ],
    //                                                            ),
    //                                                          ),
    //                                                          Row(
    //                                                            mainAxisAlignment:
    //                                                                MainAxisAlignment.center,
    //                                                            crossAxisAlignment:
    //                                                                CrossAxisAlignment.end,
    //                                                            children: <Widget>[
    //                                                              SizedBox(
    //                                                                // width: 30,
    //                                                                // height: 30,
    //                                                                width: ScUtil().setWidth(30),
    //                                                                height: ScUtil().setHeight(30),
    //                                                                child: Image.asset(
    //                                                                    "assets/images/diet/eaten.png"),
    //                                                              ),
    //                                                              Padding(
    //                                                                  padding: EdgeInsets.only(
    //                                                                      left:
    //                                                                          ScUtil().setWidth(4),
    //                                                                      bottom: ScUtil()
    //                                                                          .setHeight(3)),
    //                                                                  child: Text(
    //                                                                    score >= 20
    //                                                                        ? 'High'
    //                                                                        : score < 20 &&
    //                                                                                score >= 7.5
    //                                                                            ? 'Intermediate'
    //                                                                            : score < 7.5 &&
    //                                                                                    score >= 5
    //                                                                                ? 'Borderline'
    //                                                                                : 'Low',
    //                                                                    textAlign: TextAlign.center,
    //                                                                    style: TextStyle(
    //                                                                      fontFamily:
    //                                                                          FitnessAppTheme
    //                                                                              .fontName,
    //                                                                      fontWeight:
    //                                                                          FontWeight.w600,
    //                                                                      fontSize:
    //                                                                          ScUtil().setSp(16),
    //                                                                      color: FitnessAppTheme
    //                                                                          .darkerText,
    //                                                                    ),
    //                                                                  )),
    //                                                            ],
    //                                                          )
    //                                                        ],
    //                                                      ))
    //                                                ],
    //                                              ),
    //                                            ],
    //                                          )),
    //                                    ),
    //                                    Padding(
    //                                      padding: const EdgeInsets.all(8.0),
    //                                      child: CustomPaint(
    //                                        //                             foregroundPainter: new MyPainter(
    //                                        //     lineColor: Colors.amber,
    //                                        //     completeColor: Colors.blueAccent,
    //                                        //     completePercent: percentage,
    //                                        //     width: 8.0
    //                                        // ),
    //                                        painter: CurvePainter(
    //                                          colors: [
    //                                            AppColors.primaryColor,
    //                                            AppColors.primaryColor,
    //                                            AppColors.primaryColor,
    //                                          ],
    //                                          angle: (360) * (score / 100),
    //                                        ),
    //                                        child: Container(
    //                                          width: 100,
    //                                          height: 108,
    //                                          alignment: Alignment.center,
    //                                          child: Text('${score.toString()} %',
    //                                              style: TextStyle(
    //                                                color: AppColors.textitemTitleColor,
    //                                                fontSize: getFontSize(
    //                                                  18,
    //                                                ),
    //                                                fontFamily: 'Poppins',
    //                                                fontWeight: FontWeight.w600,
    //                                                letterSpacing: 0.42,
    //                                              )),
    //                                        ),
    //                                      ),
    //                                    ),
    //                                  ],
    //                                ),
    //                              ),
    //                            ],
    //                          )
    //                        : Container(
    //                            alignment: Alignment.center,
    //                            height: getVerticalSize(85),
    //                            child: TextButton(
    //                              child: Text(
    //                                'To know your heart health score , \nanswer few questions related to your health.',
    //                                textAlign: TextAlign.center,
    //                              ),
    //                              onPressed: () => setState(() => oldUi = true),
    //                            ),
    //                          ),
    //                  ),
    //                ),
    //              ),
    //              Visibility(
    //                visible: false,
    //                child: Text(
    //                  'Improve your heart health by following recommandation tips',
    //                  textAlign: TextAlign.center,
    //                  style: TextStyle(
    //                    color: AppColors.primaryColor,
    //                    fontSize: getFontSize(
    //                      18,
    //                    ),
    //                    fontFamily: 'Poppins',
    //                    fontWeight: FontWeight.w400,
    //                    letterSpacing: 0.42,
    //                  ),
    //                ),
    //              ),
    //              SizedBox(
    //                  height: getVerticalSize(250),
    //                  width: getHorizontalSize(420),
    //                  child: _vitalLoaded
    //                      ? ListView.builder(
    //                          itemBuilder: (ctx, index) => Shimmer.fromColors(
    //                            baseColor: Colors.white,
    //                            highlightColor: Colors.grey.withOpacity(0.3),
    //                            child: Container(
    //                              width: getHorizontalSize(125),
    //                              height: getVerticalSize(180),
    //                              decoration: BoxDecoration(
    //                                borderRadius: const BorderRadius.only(
    //                                  bottomRight: Radius.circular(8.0),
    //                                  bottomLeft: Radius.circular(8.0),
    //                                  topLeft: Radius.circular(8.0),
    //                                  topRight: Radius.circular(40.0),
    //                                ),
    //                                color: Colors.red,
    //                              ),
    //                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    //                              child: Text('Hello'),
    //                            ),
    //                            direction: ShimmerDirection.ltr,
    //                          ),
    //                          itemCount: 4,
    //                          scrollDirection: Axis.horizontal,
    //                        )
    //                      : ListView.builder(
    //                          itemCount: _dashBoardRetrieveKeys.length,
    //                          scrollDirection: Axis.horizontal,
    //                          itemBuilder: (ctx, i) {
    //                            return _listContainer(
    //                              key: _dashboardheadings[i],
    //                              value: i == 3
    //                                  ? _lastRetriveData[_dashBoardRetrieveKeys[i]]
    //                                  : _lastRetriveData[_dashBoardRetrieveKeys[i]]
    //                                      .toInt()
    //                                      .toString(),
    //                              // iconSize: 5,
    //                              status: null,
    //                              icon: FontAwesomeIcons.solidHeart,
    //                              controller: heightController,
    //                              index: i,
    //                              color: i == 2
    //                                  ? colorselcterforListContainer().BackgroundColor(
    //                                      calcBmi(
    //                                          height: _height.toString(),
    //                                          weight: _lastRetriveData[_dashBoardRetrieveKeys[i]]
    //                                              .toString()),
    //                                      _dashboardheadings[i])
    //                                  : i == 3
    //                                      ? colorselcterforListContainer().BackgroundColor(
    //                                          viseralFFat.toString(), _dashboardheadings[i])
    //                                      : colorselcterforListContainer().BackgroundColor(
    //                                          _lastRetriveData[_dashBoardRetrieveKeys[i]]
    //                                              .toString(),
    //                                          _dashboardheadings[i]),
    //                            );
    //                          })),
    //              Text(
    //                'Update your vitals periodically for accurate recommendations',
    //                textAlign: TextAlign.center,
    //                style: TextStyle(
    //                  color: Colors.grey,
    //                  fontSize: getFontSize(
    //                    14,
    //                  ),
    //                  fontFamily: 'Poppins',
    //                  fontWeight: FontWeight.w400,
    //                  letterSpacing: 0.42,
    //                ),
    //              ),
    //              SizedBox(
    //                height: getVerticalSize(15),
    //              ),
    //              Padding(
    //                padding: const EdgeInsets.only(left: 8),
    //                child: Text(
    //                  'Diet Recommendations',
    //                  textAlign: TextAlign.right,
    //                  style: TextStyle(
    //                    color: AppColors.primaryAccentColor,
    //                    fontSize: getFontSize(
    //                      18,
    //                    ),
    //                    fontFamily: 'Poppins',
    //                    fontWeight: FontWeight.w600,
    //                    letterSpacing: 0.42,
    //                  ),
    //                ),
    //              ),
    //              SizedBox(
    //                  height: score != 0 && _foodandactivityLoaded
    //                      ? getVerticalSize(220)
    //                      : getVerticalSize(301),
    //                  width: getHorizontalSize(420),
    //                  child: score != 0 && _foodandactivityLoaded
    //                      ? ListView.builder(
    //                          itemBuilder: (ctx, index) => Shimmer.fromColors(
    //                            baseColor: Colors.white,
    //                            highlightColor: Colors.grey.withOpacity(0.3),
    //                            child: Container(
    //                              width: getHorizontalSize(125),
    //                              height: getVerticalSize(50),
    //                              decoration: BoxDecoration(
    //                                borderRadius: BorderRadius.only(
    //                                  bottomRight: Radius.circular(8.0),
    //                                  bottomLeft: Radius.circular(8.0),
    //                                  topLeft: Radius.circular(8.0),
    //                                  topRight: Radius.circular(40.0),
    //                                ),
    //                                color: Colors.red,
    //                              ),
    //                              margin: EdgeInsets.only(
    //                                top: 20,
    //                                right: 10,
    //                                left: 10,
    //                              ),
    //                              child: Text('Hello'),
    //                            ),
    //                            direction: ShimmerDirection.ltr,
    //                          ),
    //                          itemCount: 4,
    //                          scrollDirection: Axis.horizontal,
    //                        )
    //                      : ListView.builder(
    //                          itemCount: 4,
    //                          scrollDirection: Axis.horizontal,
    //                          itemBuilder: (ctx, foodIndex) {
    //                            var _foodList = _foodMealType[foodIndex].split('+');
    //
    //                            return Column(
    //                              children: [
    //                                Stack(
    //                                  clipBehavior: Clip.hardEdge,
    //                                  children: [
    //                                    Container(
    //                                      width: getHorizontalSize(125),
    //                                      height: getVerticalSize(200),
    //                                      decoration: BoxDecoration(
    //                                        borderRadius: BorderRadius.only(
    //                                          bottomRight: Radius.circular(8.0),
    //                                          bottomLeft: Radius.circular(8.0),
    //                                          topLeft: Radius.circular(8.0),
    //                                          topRight: Radius.circular(40.0),
    //                                        ),
    //                                        boxShadow: <BoxShadow>[
    //                                          BoxShadow(
    //                                              color: HexColor(_recommendedFoodGradientColors[
    //                                                      foodIndex > 5
    //                                                          ? Random().nextInt(5)
    //                                                          : foodIndex][0])
    //                                                  .withOpacity(0.6),
    //                                              offset: const Offset(1.1, 4.0),
    //                                              blurRadius: 8.0),
    //                                        ],
    //                                        gradient: LinearGradient(
    //                                          colors: <HexColor>[
    //                                            HexColor(_recommendedFoodGradientColors[
    //                                                foodIndex > 5
    //                                                    ? Random().nextInt(5)
    //                                                    : foodIndex][0]),
    //                                            HexColor(_recommendedFoodGradientColors[
    //                                                foodIndex > 5
    //                                                    ? Random().nextInt(5)
    //                                                    : foodIndex][1]),
    //                                          ],
    //                                          begin: Alignment.topLeft,
    //                                          end: Alignment.bottomRight,
    //                                        ),
    //                                        color: Colors.white,
    //                                      ),
    //                                      margin: EdgeInsets.only(
    //                                        top: 20,
    //                                        right: 10,
    //                                        left: 10,
    //                                      ),
    //                                      alignment: Alignment.center,
    //                                      child: Column(
    //                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                                        children: [
    //                                          MediaQuery.of(context).size.height > 600
    //                                              ? Gap(60)
    //                                              : Gap(35),
    //                                          Text(
    //                                            mealType[foodIndex],
    //                                            textAlign: TextAlign.center,
    //                                            maxLines: 1,
    //                                            style: TextStyle(
    //                                              fontFamily: FitnessAppTheme.fontName,
    //                                              // fontWeight: FontWeight.w600,
    //                                              fontSize: ScUtil().setSp(16),
    //                                              letterSpacing: 0.5,
    //                                              color: FitnessAppTheme.white,
    //                                            ),
    //                                          ),
    //                                          Padding(
    //                                            padding: const EdgeInsets.all(8.0),
    //                                            child: SingleChildScrollView(
    //                                              child: Column(
    //                                                  mainAxisAlignment: MainAxisAlignment.center,
    //                                                  children: _foodList
    //                                                      .map((e) => SizedBox(
    //                                                            width: getHorizontalSize(125),
    //                                                            child: Text(
    //                                                              e.capitalize,
    //
    //                                                              // foodLogList[0].food[0].foodDetails.foodName
    //                                                              // foodLogList!=null?(foodLogList.foodTimeCategory.toString()).capitalize():'',
    //                                                              textAlign: TextAlign.center,
    //                                                              // maxFontSize: ScUtil().setSp(16),
    //                                                              //minFontSize: ScUtil().setSp(12),
    //                                                              maxLines: 1,
    //                                                              style: TextStyle(
    //                                                                fontFamily:
    //                                                                    FitnessAppTheme.fontName,
    //                                                                //fontWeight: FontWeight.bold,
    //                                                                fontSize: getFontSize(14),
    //                                                                letterSpacing: 0.2,
    //                                                                color: Colors.white,
    //                                                              ),
    //                                                            ),
    //                                                          ))
    //                                                      .toList()),
    //                                            ),
    //                                          ),
    //                                        ],
    //                                      ),
    //                                    ),
    //                                    Positioned(
    //                                      top: ScUtil().setHeight(0),
    //                                      left: ScUtil().setWidth(0),
    //                                      child: Container(
    //                                          width: ScUtil().setWidth(65),
    //                                          height: ScUtil().setHeight(65),
    //                                          decoration: BoxDecoration(
    //                                            color:
    //                                                FitnessAppTheme.nearlyWhite.withOpacity(0.25),
    //                                            shape: BoxShape.circle,
    //                                          ),
    //                                          child: Image.asset(imageAssets[foodIndex],
    //                                              height: 55, width: 55)
    //                                          // child: Image.asset(
    //                                          //   'assets/images/diet/breakfast.png',
    //                                          //   height: 55,
    //                                          //   width: 55,
    //                                          // ),
    //                                          ),
    //                                    ),
    //                                  ],
    //                                ),
    //                                TextButton(
    //                                  onPressed: () => Get.to(MealTypeScreen(
    //                                      mealsListData: mealsListData[foodIndex],
    //                                      cardioNavigate: true)),
    //                                  child: Text(
    //                                    'Log ${mealType[foodIndex]}',
    //                                    textAlign: TextAlign.center,
    //                                    softWrap: true,
    //                                    style: TextStyle(
    //                                      color: AppColors.primaryAccentColor,
    //                                      fontSize: getFontSize(
    //                                        14,
    //                                      ),
    //                                      fontFamily: 'Poppins',
    //                                      fontWeight: FontWeight.w600,
    //                                    ),
    //                                  ),
    //                                )
    //                              ],
    //                            );
    //                          })),
    //              Padding(
    //                padding: const EdgeInsets.only(left: 8),
    //                child: Text(
    //                  'Healthy Habits & Excerise',
    //                  textAlign: TextAlign.right,
    //                  style: TextStyle(
    //                    color: AppColors.primaryAccentColor,
    //                    fontSize: getFontSize(
    //                      18,
    //                    ),
    //                    fontFamily: 'Poppins',
    //                    fontWeight: FontWeight.w600,
    //                    letterSpacing: 0.2,
    //                  ),
    //                ),
    //              ),
    //              SizedBox(
    //                height: _foodandactivityLoaded
    //                    ? getVerticalSize(220)
    //                    : MediaQuery.of(context).size.height > 600
    //                        ? getVerticalSize(281)
    //                        : getVerticalSize(320),
    //                width: getHorizontalSize(420),
    //                child: _foodandactivityLoaded
    //                    ? ListView.builder(
    //                        itemBuilder: (ctx, index) => Shimmer.fromColors(
    //                          baseColor: Colors.white,
    //                          highlightColor: Colors.grey.withOpacity(0.3),
    //                          child: Container(
    //                            width: getHorizontalSize(125),
    //                            height: getVerticalSize(50),
    //                            decoration: BoxDecoration(
    //                              borderRadius: BorderRadius.only(
    //                                bottomRight: Radius.circular(8.0),
    //                                bottomLeft: Radius.circular(8.0),
    //                                topLeft: Radius.circular(8.0),
    //                                topRight: Radius.circular(40.0),
    //                              ),
    //                              color: Colors.red,
    //                            ),
    //                            margin: EdgeInsets.only(
    //                              top: 20,
    //                              right: 10,
    //                              left: 10,
    //                            ),
    //                            child: Text('Hello'),
    //                          ),
    //                          direction: ShimmerDirection.ltr,
    //                        ),
    //                        itemCount: 4,
    //                        scrollDirection: Axis.horizontal,
    //                      )
    //                    : ListView.builder(
    //                        scrollDirection: Axis.horizontal,
    //                        itemCount: _walking.length +
    //                            _sports.length +
    //                            _yoga.length +
    //                            _activities.length,
    //                        itemBuilder: (ctx, activityIndex) {
    //                          return activityIndex < _walking.length
    //                              ? _recommendedDietMenu(
    //                                  duration: _walking[activityIndex]['duration_in_mintues'],
    //                                  onTap: () async {
    //                                    if (io.Platform.isIOS) {
    //                                      var status = await Permission.calendar.status;
    //                                      if (status.isDenied) {
    //                                        Permission.calendar.request();
    //                                        openAppSettings();
    //                                      } else if (status.isPermanentlyDenied) {
    //                                        showDialog(
    //                                            context: context,
    //                                            builder: (BuildContext context) =>
    //                                                CupertinoAlertDialog(
    //                                                  title: new Text("Calendar Access Denied"),
    //                                                  content: new Text(
    //                                                      "Allow Calendar permission to continue"),
    //                                                  actions: <Widget>[
    //                                                    CupertinoDialogAction(
    //                                                      isDefaultAction: true,
    //                                                      child: Text("Yes"),
    //                                                      onPressed: () async {
    //                                                        await openAppSettings();
    //                                                        Get.back();
    //                                                      },
    //                                                    ),
    //                                                    CupertinoDialogAction(
    //                                                      child: Text("No"),
    //                                                      onPressed: () => Get.back(),
    //                                                    )
    //                                                  ],
    //                                                ));
    //                                      } else {
    //                                        a2c.Add2Calendar.addEvent2Cal(buildEvent(
    //                                            recurrence: a2c.Recurrence(
    //                                              frequency: a2c.Frequency.daily,
    //                                              endDate: DateTime.now().add(Duration(days: 30)),
    //                                            ),
    //                                            title: _walking[activityIndex]['activity_name'],
    //                                            description: ' (Duration : ' +
    //                                                _walking[activityIndex]['duration_in_mintues'] +
    //                                                ' Min)',
    //                                            mintuesValue: 30));
    //                                      }
    //                                    } else {
    //                                      inputTimeSelect(_walking[activityIndex]['activity_name'] +
    //                                          ' (Duration : ' +
    //                                          _walking[activityIndex]['duration_in_mintues'] +
    //                                          ' in Min)');
    //                                    }
    //                                  },
    //                                  log: 'Set Reminder',
    //                                  activity: _walking[activityIndex]['activity_name'],
    //                                  color: _recommendedActivityGradientColors[
    //                                      activityIndex > 4 ? Random().nextInt(5) : activityIndex])
    //                              : activityIndex < _walking.length + _sports.length
    //                                  ? _recommendedDietMenu(
    //                                      duration: _sports[activityIndex - _walking.length]
    //                                          ['duration_in_mintues'],
    //                                      onTap: () async {
    //                                        if (io.Platform.isIOS) {
    //                                          var status = await Permission.calendar.status;
    //                                          if (status.isDenied) {
    //                                            Permission.calendar.request();
    //                                            openAppSettings();
    //                                          } else if (status.isPermanentlyDenied) {
    //                                            showDialog(
    //                                                context: context,
    //                                                builder: (BuildContext context) =>
    //                                                    CupertinoAlertDialog(
    //                                                      title: new Text("Calendar Access Denied"),
    //                                                      content: new Text(
    //                                                          "Allow Calendar permission to continue"),
    //                                                      actions: <Widget>[
    //                                                        CupertinoDialogAction(
    //                                                          isDefaultAction: true,
    //                                                          child: Text("Yes"),
    //                                                          onPressed: () async {
    //                                                            await openAppSettings();
    //                                                            Get.back();
    //                                                          },
    //                                                        ),
    //                                                        CupertinoDialogAction(
    //                                                          child: Text("No"),
    //                                                          onPressed: () => Get.back(),
    //                                                        )
    //                                                      ],
    //                                                    ));
    //                                          } else {
    //                                            a2c.Add2Calendar.addEvent2Cal(buildEvent(
    //                                                recurrence: a2c.Recurrence(
    //                                                  frequency: a2c.Frequency.daily,
    //                                                  endDate:
    //                                                      DateTime.now().add(Duration(days: 30)),
    //                                                ),
    //                                                title: _sports[activityIndex - _walking.length]
    //                                                    ['activity_name'],
    //                                                description: ' (Duration : ' +
    //                                                    _sports[activityIndex - _walking.length]
    //                                                        ['duration_in_mintues'] +
    //                                                    ' Min)',
    //                                                mintuesValue: 30));
    //                                          }
    //                                        } else {
    //                                          inputTimeSelect(
    //                                              _sports[activityIndex - _walking.length]
    //                                                      ['activity_name'] +
    //                                                  ' (Duration : ' +
    //                                                  _sports[activityIndex - _walking.length]
    //                                                      ['duration_in_mintues'] +
    //                                                  ' in Min)');
    //                                        }
    //                                      },
    //                                      log: 'Set Reminder',
    //                                      activity: _sports[activityIndex - _walking.length]
    //                                          ['activity_name'],
    //                                      color: _recommendedActivityGradientColors[activityIndex > 4
    //                                          ? Random().nextInt(5)
    //                                          : activityIndex])
    //                                  : activityIndex <
    //                                          _walking.length + _sports.length + _activities.length
    //                                      ? _recommendedDietMenu(
    //                                          duration: _activities[activityIndex - (_walking.length + _sports.length)]
    //                                              ['duration_in_mintues'],
    //                                          onTap: () async {
    //                                            if (io.Platform.isIOS) {
    //                                              var status = await Permission.calendar.status;
    //                                              if (status.isDenied) {
    //                                                Permission.calendar.request();
    //                                                openAppSettings();
    //                                              } else if (status.isPermanentlyDenied) {
    //                                                showDialog(
    //                                                    context: context,
    //                                                    builder: (BuildContext context) =>
    //                                                        CupertinoAlertDialog(
    //                                                          title: new Text(
    //                                                              "Calendar Access Denied"),
    //                                                          content: new Text(
    //                                                              "Allow Calendar permission to continue"),
    //                                                          actions: <Widget>[
    //                                                            CupertinoDialogAction(
    //                                                              isDefaultAction: true,
    //                                                              child: Text("Yes"),
    //                                                              onPressed: () async {
    //                                                                await openAppSettings();
    //                                                                Get.back();
    //                                                              },
    //                                                            ),
    //                                                            CupertinoDialogAction(
    //                                                              child: Text("No"),
    //                                                              onPressed: () => Get.back(),
    //                                                            )
    //                                                          ],
    //                                                        ));
    //                                              } else {
    //                                                a2c.Add2Calendar.addEvent2Cal(buildEvent(
    //                                                    recurrence: a2c.Recurrence(
    //                                                      frequency: a2c.Frequency.daily,
    //                                                      endDate: DateTime.now()
    //                                                          .add(Duration(days: 30)),
    //                                                    ),
    //                                                    title: _activities[activityIndex -
    //                                                            (_walking.length + _sports.length)]
    //                                                        ['activity_name'],
    //                                                    description: ' (Duration : ' +
    //                                                        _activities[activityIndex -
    //                                                                (_walking.length +
    //                                                                    _sports.length)]
    //                                                            ['duration_in_mintues'] +
    //                                                        ' Min)',
    //                                                    mintuesValue: 30));
    //                                              }
    //                                            } else {
    //                                              inputTimeSelect(_activities[activityIndex -
    //                                                          (_walking.length + _sports.length)]
    //                                                      ['activity_name'] +
    //                                                  ' (Duration : ' +
    //                                                  _activities[activityIndex -
    //                                                          (_walking.length + _sports.length)]
    //                                                      ['duration_in_mintues'] +
    //                                                  ' in Min)');
    //                                            }
    //                                          },
    //                                          log: 'Set Reminder',
    //                                          activity: _activities[activityIndex - (_walking.length + _sports.length)]
    //                                              ['activity_name'],
    //                                          color: _recommendedActivityGradientColors[activityIndex > 4
    //                                              ? Random().nextInt(5)
    //                                              : activityIndex])
    //                                      : _recommendedDietMenu(
    //                                          duration:
    //                                              _yoga[activityIndex - (_walking.length + _sports.length + _activities.length)]
    //                                                  ['duration_in_mintues'],
    //                                          onTap: () async {
    //                                            if (io.Platform.isIOS) {
    //                                              var status = await Permission.calendar.status;
    //                                              if (status.isDenied) {
    //                                                Permission.calendar.request();
    //                                                openAppSettings();
    //                                              } else if (status.isPermanentlyDenied) {
    //                                                showDialog(
    //                                                    context: context,
    //                                                    builder: (BuildContext context) =>
    //                                                        CupertinoAlertDialog(
    //                                                          title: new Text(
    //                                                              "Calendar Access Denied"),
    //                                                          content: new Text(
    //                                                              "Allow Calendar permission to continue"),
    //                                                          actions: <Widget>[
    //                                                            CupertinoDialogAction(
    //                                                              isDefaultAction: true,
    //                                                              child: Text("Yes"),
    //                                                              onPressed: () async {
    //                                                                await openAppSettings();
    //                                                                Get.back();
    //                                                              },
    //                                                            ),
    //                                                            CupertinoDialogAction(
    //                                                              child: Text("No"),
    //                                                              onPressed: () => Get.back(),
    //                                                            )
    //                                                          ],
    //                                                        ));
    //                                              } else {
    //                                                a2c.Add2Calendar.addEvent2Cal(buildEvent(
    //                                                    recurrence: a2c.Recurrence(
    //                                                      frequency: a2c.Frequency.daily,
    //                                                      endDate: DateTime.now()
    //                                                          .add(Duration(days: 30)),
    //                                                    ),
    //                                                    title: _yoga[activityIndex -
    //                                                            (_walking.length +
    //                                                                _sports.length +
    //                                                                _activities.length)]
    //                                                        ['activity_name'],
    //                                                    description: ' (Duration : ' +
    //                                                        _yoga[activityIndex -
    //                                                                (_walking.length +
    //                                                                    _sports.length +
    //                                                                    _activities.length)]
    //                                                            ['duration_in_mintues'] +
    //                                                        ' Min)',
    //                                                    mintuesValue: 30));
    //                                              }
    //                                            } else {
    //                                              inputTimeSelect(_yoga[activityIndex -
    //                                                          (_walking.length +
    //                                                              _sports.length +
    //                                                              _activities.length)]
    //                                                      ['activity_name'] +
    //                                                  ' (Duration : ' +
    //                                                  _yoga[activityIndex -
    //                                                          (_walking.length +
    //                                                              _sports.length +
    //                                                              _activities.length)]
    //                                                      ['duration_in_mintues'] +
    //                                                  ' in Min)');
    //                                            }
    //                                          },
    //                                          log: 'Set Reminder',
    //                                          activity:
    //                                              _yoga[activityIndex - (_walking.length + _sports.length + _activities.length)]
    //                                                  ['activity_name'],
    //                                          color: _recommendedActivityGradientColors[
    //                                              activityIndex > 4 ? Random().nextInt(5) : activityIndex]);
    //                        },
    //                      ),
    //              ),
    //              Padding(
    //                padding: const EdgeInsets.only(left: 8),
    //                child: Text(
    //                  'Customized Expert Consultation for you',
    //                  textAlign: TextAlign.right,
    //                  style: TextStyle(
    //                    color: AppColors.primaryAccentColor,
    //                    fontSize: getFontSize(
    //                      18,
    //                    ),
    //                    fontFamily: 'Poppins',
    //                    fontWeight: FontWeight.w600,
    //                    letterSpacing: 0.2,
    //                  ),
    //                ),
    //              ),
    //              SizedBox(
    //                  height: getVerticalSize(290),
    //                  width: getHorizontalSize(380),
    //                  child: ListView.builder(
    //                      scrollDirection: Axis.horizontal,
    //                      itemCount: recommended.length,
    //                      itemBuilder: (BuildContext context, int index) {
    //                        dynamic stts = recommended[index]['availabilityStatus'];
    //                        try {
    //                          return _customizedExpert(
    //                            recommended[index]['availabilityStatus'],
    //                            recommended[index]['name'],
    //                            recommended[index]['consultant_speciality'].join(','),
    //                            recommended[index]['profile_picture'],
    //                            () {
    //                              final Map<String, dynamic> _d = recommended[index];
    //                              _d['livecall'] = false;
    //                              Get.to(
    //                                  BookAppointment(
    //                                    doctor: recommended[index],
    //                                    specality: recommended[index]['consultant_speciality'],
    //                                  ),
    //                                  transition: Transition.zoom);
    //                            },
    //                          );
    //                        } catch (e) {
    //                          return Shimmer.fromColors(
    //                            baseColor: Colors.white,
    //                            highlightColor: Colors.grey.withOpacity(0.3),
    //                            child: Container(
    //                              width: getHorizontalSize(125),
    //                              height: getVerticalSize(200),
    //                              decoration: BoxDecoration(
    //                                borderRadius: BorderRadius.only(
    //                                  bottomRight: Radius.circular(8.0),
    //                                  bottomLeft: Radius.circular(8.0),
    //                                  topLeft: Radius.circular(8.0),
    //                                  topRight: Radius.circular(40.0),
    //                                ),
    //                                color: Colors.red,
    //                              ),
    //                              margin: EdgeInsets.only(
    //                                top: 20,
    //                                right: 10,
    //                                left: 10,
    //                              ),
    //                              child: Text('Hello'),
    //                            ),
    //                            direction: ShimmerDirection.ltr,
    //                          );
    //                        }
    //                      })),
    //            ],
    //          ),
    //        ),
    //      );
  }

  inputTimeSelect(String alarmtitile) async {
    final TimeOfDay picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
              data:
                  Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.blue)),
              child: child),
        );
      },
    );
    FlutterAlarmClock.createAlarm(picked.hour.hours.inHours, picked.minute.minutes.inMinutes,
        title: alarmtitile.toString());
  }

  http.Client _client = http.Client();
  List recommended = [];

  _getConusultantData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];
    // setState(() {
    recommended.clear();
    // });
    try {
      // setState(() {
      //   _isloading = true;
      // });
      http.Client _client = http.Client(); //3gb
      final response1 = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
      );
      // ignore: unrelated_type_equality_checks
      Map res;
      if (response1.statusCode == 200) {
        res = jsonDecode(response1.body);
        if (this.mounted) {
          setState(() {
            recommended = RecommandedHealper().spliter(res);
            getConsultantImageURL(recommended);
            update(recommended);
            // _isloading = false;
          });
        }
      } else {}
      return response1;
    } catch (e) {
      print(e.toString());
      // setState(() {
      //   _isloading = false;
      // });
      return [];
    }
  }

  // ignore: missing_return
  Future<String> getConsultantImageURL(List doctor) async {
    if (doctor.isNotEmpty) {
      for (int s = 0; s < doctor?.length; s++) {
        try {
          if (doctor[s]['profile_picture'] == null) {
            var map = doctor[s]['vendor_id'] == "GENIX"
                ? [doctor[s]['vendor_consultant_id'], doctor[s]['vendor_id']]
                : [doctor[s]['ihl_consultant_id'], doctor[s]['vendor_id']];
            var bodyGenix = jsonEncode(<String, dynamic>{
              'vendorIdList': [map[0]],
              "consultantIdList": [""],
            });
            var bodyIhl = jsonEncode(<String, dynamic>{
              'consultantIdList': [map[0]],
              "vendorIdList": [""],
            });
            final response = await _client.post(
              Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
              body: map[1] == "GENIX" ? bodyGenix : bodyIhl,
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
            );
            if (response.statusCode == 200) {
              var imageOutput = json.decode(response.body);
              var consultantImage, base64Image;
              var consultantIDAndImage =
                  map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
              for (var i = 0; i < consultantIDAndImage.length; i++) {
                // if (widget.doctor['ihl_consultant_id'] ==
                if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
                  base64Image = consultantIDAndImage[i]['base_64'].toString();
                  base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
                  base64Image = base64Image.replaceAll('}', '');
                  base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
                  if (this.mounted) {
                    setState(() {
                      consultantImage = base64Image;
                      if (consultantImage == null || consultantImage == "") {
                        doctor[s]['profile_picture'] = AvatarImage.defaultUrl;
                        // return AvatarImage.defaultUrl;
                      } else {
                        doctor[s]['profile_picture'] = consultantImage;
                        // return consultantImage;
                      }
                    });
                  }
                  recommended[s]['profile_picture'] = doctor[s]['profile_picture'];
                }
              }
            } else {
              return AvatarImage.defaultUrl;
            }
          }
        } catch (e) {
          print(e.toString());
          if (this.mounted) {
            doctor[s]['profile_picture'] = AvatarImage.defaultUrl;
            return AvatarImage.defaultUrl;
          }
        }
      }
    }
  }

  Session session1;

  void connect() {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

//check the crossbar for status update
  String status = 'offline';

  Future update(List doctor) async {
    if (doctor.isNotEmpty)
      for (int i = 0; i < doctor?.length; i++) {
        if (session1 != null) {
          session1.close();
        }
        connect();
        var doctorId = doctor[i]['ihl_consultant_id'];
        session1 = await client.connect().first;
        try {
          final subscription = await session1.subscribe('ihl_update_doctor_status_channel',
              options: SubscribeOptions(get_retained: true));
          subscription.eventStream.listen((event) {
            Map data = event.arguments[0];
            var docStatus = data['data']['status'];
            if (mounted)
              setState(() {
                recommended[i]['availabilityStatus'] = data['data']['status'];
              });
            if (data['sender_id'] == doctorId) {
              if (this.mounted) {
                setState(() {
                  status = docStatus;
                  doctor[i]['availabilityStatus'] = docStatus;
                  recommended[i]['availabilityStatus'] = docStatus;
                });
              }
            }
          });
        } on Abort catch (abort) {
          print(abort.message.message);
        }
      }
  }

  Widget _customizedExpert(String status, name, specification, imageUrl, VoidCallback onTap) {
    _statusbg<Color>() {
      if (status == 'Online') return Colors.green;
      if (status == 'Offline') return Colors.grey;
      if (status == 'Busy') return Colors.orange;
    }

    return Padding(
      padding: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 1,
          shadowColor: _statusbg(),
          shape: RoundedRectangleBorder(
            //side: BorderSide(color: Colors.black, width: 0.09),
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white38,
          child: SizedBox(
            height: getVerticalSize(280),
            width: getHorizontalSize(160),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                //height: getVerticalSize(260),
                //width: getHorizontalSize(160),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          //offset: Offset(2, 0),
                          blurRadius: 1.0,
                          spreadRadius: 0.8)
                    ],
                    //border: Border.all(color: Colors.black, width: 0.09),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     // Card(
                    //     //   elevation: 4,
                    //     //   shadowColor: Colors.grey,
                    //     //   color: _statusbg(),
                    //     //   child: Center(
                    //     //     child: Padding(
                    //     //       padding: const EdgeInsets.all(1.0),
                    //     //       child: Text(
                    //     //         status.toString(),
                    //     //         style: TextStyle(
                    //     //             color: Colors.white, fontSize: 10),
                    //     //       ),
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    Container(
                      height: getVerticalSize(210),
                      width: getHorizontalSize(160),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.memory(
                                    base64Decode(imageUrl),
                                    fit: BoxFit.cover,
                                    height: 80,
                                    width: 80,
                                  ) ??
                                  Center(
                                    child: CircularProgressIndicator(),
                                  )),
                          SizedBox(
                            height: 2,
                          ),
                          SizedBox(
                            width: 100,
                            child: Center(
                              child: Text(
                                name.toString(),
                                // 'asfdfdas dasfadf',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: getFontSize(15),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            //height: 10,
                            width: 70,
                            child: Center(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Container(
                            //height: 60,
                            width: 130,
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(25)),
                            child: Center(
                              child: AutoSizeText(
                                // _spec(specification),
                                specification.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(height: 1.2, color: Colors.blue, fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ), //Column
            ), //Padding
          ), //SizedBox
        ),
      ),
    );
  }

  Size size =
      WidgetsBinding.instance.window.physicalSize / WidgetsBinding.instance.window.devicePixelRatio;

  ///This method is used to set padding/margin (for the left and Right side) & width of the screen or widget according to the Viewport width.
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
    var height = getVerticalSize(px);
    var width = getHorizontalSize(px);
    if (height < width) {
      return height.toInt().toDouble();
    } else {
      return width.toInt().toDouble();
    }
  }

  ///This method is used to set smallest px in image height and width
  double getSize(double px) {
    var height = getVerticalSize(px);
    var width = getHorizontalSize(px);
    if (height < width) {
      return height.toInt().toDouble();
    } else {
      return width.toInt().toDouble();
    }
  }
}

class HeaderClipper extends CustomClipper<Path> {
  final double radius;

  HeaderClipper(this.radius);

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 2 * radius)
      ..arcToPoint(Offset(size.width - radius, size.height - radius),
          radius: Radius.circular(radius))
      ..lineTo(radius, size.height - radius)
      ..arcToPoint(Offset(0, size.height), radius: Radius.circular(radius), clockwise: false)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StatsPainter extends CustomPainter {
  final double width;
  final double offset;
  final double radius;

  StatsPainter({this.width, this.offset, this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final border1 =
        BorderSide(color: Colors.yellow.shade600, width: width, style: BorderStyle.solid);

    final border2 = BorderSide(color: Colors.white, width: width, style: BorderStyle.solid);

    var p = pi;
    // var by = 1;//percentage between 40-50
    var by = 2; //percentage between 90-100

    canvas.drawArc(
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), -pi, pi / (radius >= 50 ? 2.45 : 2.2), false,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), pi, pi / (0.5), false,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), -p,p, false,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), -p,p*by, false,
      Rect.fromCircle(center: Offset(offset, offset), radius: radius), 2,
      pi * 1, false,
      border1.toPaint()..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), pi / (radius >= 50 ? 1.16 : 1.15), -(radius >= 50 ? 1.32 : 1.3) * pi,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), 2.14, -(1.32) * pi,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), p-.4,-p+.9,
      // Rect.fromCircle(center: Offset(offset, offset), radius: radius), p-.4,-p+.9,
      Rect.fromCircle(center: Offset(offset, offset), radius: radius), 2,
      -pi * 1,
      false,
      border2.toPaint()..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant StatsPainter oldDelegate) {
    return false;
  }
}

class CurvePainter extends CustomPainter {
  final double angle;
  final List<Color> colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10; //14
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius = math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 12; //16
    canvas.drawArc(new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 16; //20
    canvas.drawArc(new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360 - (365 - angle)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 13; //22
    canvas.drawArc(new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278), degreeToRadians(360), false, shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );

    ///main strock//  14
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10; //14
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)), false, paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 8 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 4, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}

// ignore: camel_case_types
class colorselcterforListContainer {
  List<Color> c = [];

  // ignore: non_constant_identifier_names
  BackgroundColor(var value, var type) {
    var i;
    List<Color> normalColor = [Colors.green, Colors.green[200]];
    List<Color> dangerColor = [Colors.red, Colors.red[200]];
    List<Color> littleDangerColor = [Colors.orange, Colors.orange[200]];
    List<Color> notGivenColor = [Colors.blue, Colors.blue[200]];
    switch (type) {
      case 'Systolic':
        value == "null" || value == "notGiven" ? i = 0 : i = double.parse(value);
        //139
        if (i > 0 && i <= 139) {
          return c = normalColor;
        } else if (i > 139) {
          return c = dangerColor;
        }
        // if ((89 < i) && (i < 201)) {
        //   return c = normalColor;
        // } else if (201 < i) {
        //   return c = dangerColor;
        // } else if (89 > i) {
        //   return c = littleDangerColor;
        // }
        else {
          return c = notGivenColor;
        }
        break;
      case 'Diastolic':
        value == "null" || value == "notGiven" ? i = 0 : i = double.parse(value);
        if (i > 0 && i <= 79) {
          return c = normalColor;
        } else if (i > 79) {
          return c = dangerColor;
        }
        // if ((59 < i) && (i < 130)) {
        //   return c = normalColor;
        // } else if (130 < i) {
        //   return c = dangerColor;
        // } else if (89 > i) {
        //   return c = littleDangerColor;
        // }
        else {
          return c = notGivenColor;
        }
        break;
      case 'BMI':
        value == "null" || value == "notGiven" || value == null
            ? i = 0
            : value is int
                ? i = value
                : i = double.parse(value);
        if (i <= 18) {
          return c = littleDangerColor;
        } else if (18 < i && i < 22) {
          return c = normalColor;
        } else if (23 < i && i < 27) {
          // return c = overWeightColor;
          return c = dangerColor;
        } else if (i > 27) {
          return c = dangerColor;
        } else {
          return c = notGivenColor;
        }
        break;

      case 'Visceral Fat':
        value == "null" || value == "notGiven" || value == "0" ? i = 0 : i = double.parse(value);
        if ((0 < i) && (i < 100)) {
          return c = normalColor;
        } else if (100 < i) {
          return c = dangerColor;
        } else if (0 > i) {
          return c = littleDangerColor;
        } else {
          return c = notGivenColor;
        }
        break;
      case 'Cholesterol':
        value == "null" || value == "notGiven" ? i = 0 : i = double.parse(value);
        if (i <= 200) {
          return c = normalColor;
        } else if (i > 200 && i < 239) {
          return c = littleDangerColor;
        } else if (i > 239) {
          return c = dangerColor;
        } else {
          return c = notGivenColor;
        }
        break;
      case 'LDL':
        value == "null" || value == "notGiven" ? i = 0 : i = double.parse(value);
        if (i < 100) {
          return c = normalColor;
        } else if (i >= 160) {
          return c = dangerColor;
        } else if (i > 100 && i < 160) {
          return c = littleDangerColor;
        } else {
          return c = notGivenColor;
        }
        break;
      case 'HDL':
        value == "null" || value == "notGiven" ? i = 0 : i = double.parse(value);
        if (i >= 60) {
          return c = normalColor;
        } else if (i <= 40) {
          return c = dangerColor;
        } else if (i < 60 && i > 40) {
          return c = littleDangerColor;
        } else {
          return c = notGivenColor;
        }
        break;
      default:
        return c = normalColor;
        break;
    }
  }
}

/// calculate bmi🎇🎇
int calcBmi({height, weight}) {
  double parsedH;
  double parsedW;
  if (height == null || weight == null) {
    return null;
  }

  parsedH = double.tryParse(height);
  parsedW = double.tryParse(weight);

  if (parsedH != null && parsedW != null) {
    int bmi = parsedW ~/ (parsedH * parsedH);
    return bmi;
  }
  return null;
}
