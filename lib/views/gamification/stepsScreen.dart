import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/ChartModel.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/journal_graph.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:strings/strings.dart';

import '../../new_design/app/config/permission_config.dart';
import '../../new_design/app/utils/appText.dart';
import 'dateutils.dart';

int _start = 24;
const eigthHour = const Duration(hours: 8);
ValueNotifier<int> sshoursStr = ValueNotifier<int>(0);
// String sminutesStr = '00';
var sminutesStr = ValueNotifier<int>(0);
// String ssecondsStr = '00';
ValueNotifier<int> ssecondsStr = ValueNotifier<int>(0);
var started = false;
var ssubmitted = false;
var startStepFlag = false;
var startStepValue = 0;
int initialStepsValue = 0;

///these are the steps recorded already for the day , we will get from the api...
int initialMinValue = 0;

///these are the min recorded already for the day , we will get from the api...
int initialHourValue = 0;

///these are the hour recorded already for the day , we will get from the api...
int initialSecondValue = 0;

///these are the hour recorded already for the day , we will get from the api...
int initialDurationValueInSec = 0;

///these are the hour recorded already for the day , we will get from the api...
var _calorieBurn = '0', _currentCalore = '0';
// int stodaySteps = 0;
ValueNotifier<int> stodaySteps = ValueNotifier<int>(0);
bool sflag = true;
Stream<int> stimerStream;
StreamSubscription<int> stimerSubscription;
StreamSubscription<int> _subscription;
List<DailyStatUiModel> _weekSteps = [
  defaultDailyStat,
  defaultDailyStat,
  defaultDailyStat,
  defaultDailyStat,
  defaultDailyStat,
  defaultDailyStat,
  defaultDailyStat,
];

/// Self contained step counter 💡

List stepActivityList = [];

class StepsScreen extends StatefulWidget {
  StepsScreen({Key key, this.activities});
  var activities;

  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  int _maxDuration = 1000;
  http.Client _client = http.Client(); //3gb
  ExpandableController _expandableController = ExpandableController();
  int _selectedPanel;
  Pedometer _pedometer;
  // StreamSubscription<int> _subscription;
  // int _stepCountValue = 0;
  // var _calorieBurn = '0';
  int goal = 10000;
  double weight = 1;
  double height = 1;
  Map extracted = {};
  int _selectedIndicator = 0;
  DateTime _currentDay = DateTime.now();
  Map allData = {};
  Map graphData = {};
  double kmPerStep = 0.000762;
  String ihlUserId;
  bool sixtySecComplete = false;
  List<DailyCalorieData> dailyChartData = [];
  List<DailyCalorieData> graphDataList = [];
  String _weekDurationText = '', _monthDurationText = '';
  bool nodata = false;
  List apiStepData = [];
  DateTime _selectdWeeklyDate = DateTime.now(), _selectedMonthlyDate = DateTime.now();
  bool displayNextWeekBtn = false, displayNextBtn = false;

  // String sshoursStr = '00';
  // String sminutesStr = '00';
  // String ssecondsStr = '00';
  List<DailyStatUiModel> _monthlySteps = [];
  bool _monthlyLoading = false;
  final ScrollController _controller = ScrollController();
  final double _width = 32;

  var _timer;
  void _animateToIndex(int index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          index * _width,
          duration: Duration(seconds: 3),
          curve: Curves.fastOutSlowIn,
        ); //do your stuff here
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_controller.hasClients) {

    //   }
    // });
  }

  double _scale;
  AnimationController _aniMatecontroller;
  @override
  void initState() {
    _aniMatecontroller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
    stepInitState();
    super.initState(); // timeOut();
  }

  @override
  void dispose() {
    super.dispose();
    _aniMatecontroller.dispose();
  }

  bool isLoadingCompleted = false;
  stepInitState() async {
    ihlUserId = await _getIhlUserId();
    if (started == false) {
      var ssec = await getInitialStepsValue(widget.activities);
      // await graphCalculation(widget.activities);
      await checkForAppExitWhileStepsCountOn(ssec);
    }

    await setCurrentWeek();
    await setCurrentMonth();
    // var daysInWeek = AppDateUtils.getDaysInWeek(today);
    // DateTime _firstDayOfTheweek =
    //     today.subtract(new Duration(days: today.weekday - 1));
    await getUserAndStepData();
    await getWeightHeight();

    if (mounted) {
      setState(() {
        isLoadingCompleted = true;
      });
    }
  }

  checkForAppExitWhileStepsCountOn(ssec) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool startStop = pref.getBool('startStop') ?? false;
    var startTimingOfSteps;
    if (startStop == true) {
      startStepValue = pref.getInt('startStepValue');
      startTimingOfSteps = pref.getString('startTimingOfSteps');
      var diffInSec;
      if (startTimingOfSteps.toString() != null) {
        var d1 = DateTime.parse(startTimingOfSteps);
        var now = DateTime.now();
        diffInSec = now.difference(d1).inSeconds + ssec;
      }
      if (started != true) {
        initPlatformState();
        stimerStream = stopWatchStream();
        stimerSubscription = stimerStream.listen((int newTick) {
          // newTick= newTick*60;
          sshoursStr.value = int.parse(
              (((newTick + (diffInSec)) / (60 * 60)) % 60).floor().toString().padLeft(2, '0'));
          sminutesStr.value =
              int.parse((((newTick + diffInSec) / 60) % 60).floor().toString().padLeft(2, '0'));
          ssecondsStr.value =
              int.parse(((newTick + diffInSec) % 60).floor().toString().padLeft(2, '0'));
        });
      }
      if (mounted) {
        setState(() {
          started = true;
        });
        startStepFlag = false;

        ///start the duration
      }
    }

    ///saving the startStepValue
    ///so that we know , on which step it is start  and also time..
    ///after this
    ///STEP:1 ->   FROM INIT STATE WE CHECK THAT IS THERE ANY OLD STEPS IS GOING IN...
    ///IF IT IS NOT THAN THAT S OKAY NORMAL FLOW
    ///OTHERWISE ->  it will automatically start and will start from there
  }

  String getWeekDisplayDate(DateTime dateTime) {
    return '${AppDateUtils.firstDateOfWeek(dateTime).toFormatString('dd MMM')} - ${AppDateUtils.lastDateOfWeek(dateTime).toFormatString('dd MMM')}';
  }

  String getMonthText(DateTime dateTime) {
    return '${DateFormat("MMMM").format(dateTime).substring(0, 3)} ${DateFormat("yyyy").format(dateTime)}';
  }

  void setCurrentWeek() async =>
      setState(() => _weekDurationText = getWeekDisplayDate(_selectdWeeklyDate));
  void setCurrentMonth() async =>
      setState(() => _monthDurationText = getMonthText(_selectdWeeklyDate));
  void setPreviousMonth() async {
    // await getLogStepsApi(ihlUserId: ihlUserId);
    _selectedMonthlyDate = DateTime(_selectedMonthlyDate.year, _selectedMonthlyDate.month, 1);
    _selectedMonthlyDate = _selectedMonthlyDate.subtract(Duration(days: 1));

    setNextMonthButtonVisibility();
    setState(() => _monthDurationText = getMonthText(_selectedMonthlyDate));

    await getLogStepsApi(ihlUserId: ihlUserId);

    // print(_weekText);
  }

  void setNextMonth() async {
    int lastDay = DateTime(_selectedMonthlyDate.year, _selectedMonthlyDate.month + 1, 0).day;
    _selectedMonthlyDate = DateTime(_selectedMonthlyDate.year, _selectedMonthlyDate.month, lastDay);
    _selectedMonthlyDate = _selectedMonthlyDate.add(Duration(days: 1));

    setNextMonthButtonVisibility();
    await getLogStepsApi(ihlUserId: ihlUserId);

    setState(() => _monthDurationText = getMonthText(_selectedMonthlyDate));
    // setNextWeekButtonVisibility();
    // _weekSteps = [];
    // _weekSteps = List.filled(7, defaultDailyStat);
    // await getLogStepsApi(ihlUserId: ihlUserId);
    // print('Api Called Done');
    // print(_weekText);
  }

  void setPreviousWeek() async {
    // await getLogStepsApi(ihlUserId: ihlUserId);

    _selectdWeeklyDate = _selectdWeeklyDate.subtract(Duration(days: 7));
    _weekSteps = [];
    _weekSteps = List.filled(7, defaultDailyStat);
    await getLogStepsApi(ihlUserId: ihlUserId);
    setNextWeekButtonVisibility();

    setState(() => _weekDurationText = getWeekDisplayDate(_selectdWeeklyDate));
    // print(_weekText);
  }

  void setNextWeekButtonVisibility() =>
      displayNextWeekBtn = !_selectdWeeklyDate.isSameDate(DateTime.now());

  void setNextMonthButtonVisibility() {
    if (_selectedMonthlyDate.month == DateTime.now().month) {
      displayNextBtn = false;
    } else {
      displayNextBtn = true;
    }
  }

  int getTotalNumberofDays() =>
      DateTime(_selectedMonthlyDate.year, _selectedMonthlyDate.month + 1, 0).day;

  void setNextWeek() async {
    // print(DateTime.now().month);
    _selectdWeeklyDate = _selectdWeeklyDate.add(Duration(days: 7));
    setNextWeekButtonVisibility();
    _weekSteps = [];
    _weekSteps = List.filled(7, defaultDailyStat);
    await getLogStepsApi(ihlUserId: ihlUserId);
    setState(() => _weekDurationText = getWeekDisplayDate(_selectdWeeklyDate));
  }

  Widget _tableBuilder({Map data}) {
    List<DataRow> rows = [];
    data.forEach((k, v) {
      rows.add(
        DataRow(cells: [
          DataCell(
            Text(
              k.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(v.toString()),
          )
        ]),
      );
    });
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  rows: rows,
                  columns: [
                    DataColumn(
                      label: Text('More info'),
                    ),
                    DataColumn(
                      label: Text('Details'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageIndicatorText(String text) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Theme.of(Get.context).primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  text,
                  style: Theme.of(Get.context).textTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 17.0,
                      ),
                ),
              ),
            )));
  }

  Widget _previousMonthButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: RawMaterialButton(
        onPressed: () => setPreviousMonth(),
        elevation: 2.0,
        fillColor: Theme.of(Get.context).primaryColor,
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(4.0),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _nextMonthButton() {
    return Visibility(
      visible: displayNextBtn,
      child: Align(
        alignment: Alignment.bottomRight,
        child: RawMaterialButton(
          onPressed: () => setNextMonth(),
          elevation: 2.0,
          fillColor: Theme.of(Get.context).primaryColor,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
          ),
          padding: EdgeInsets.all(4.0),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  Widget _previousWeekButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: RawMaterialButton(
        onPressed: () => setPreviousWeek(),
        elevation: 2.0,
        fillColor: Theme.of(Get.context).primaryColor,
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(4.0),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _nextWeekButton() {
    return Visibility(
      visible: displayNextWeekBtn,
      child: Align(
        alignment: Alignment.bottomRight,
        child: RawMaterialButton(
          onPressed: () => setNextWeek(),
          elevation: 2.0,
          fillColor: Theme.of(Get.context).primaryColor,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
          ),
          padding: EdgeInsets.all(4.0),
          shape: CircleBorder(),
        ),
      ),
    );
  }

  Future _getMonthSteps(List a) async {
// DateTime localDate = DateFormat('dd-MM-yyyy').format(selectedDate)
    _maxDuration = 1000;
    setState(() => _monthlyLoading = true);
    _monthlySteps = [];
    _monthlySteps.addAll(List.filled(getTotalNumberofDays(), defaultDailyStat));
    print(_monthlySteps.length);
    for (var i = 0; i < _monthlySteps.length; i++) {
      DateTime localDate = DateTime(_selectedMonthlyDate.year, _selectedMonthlyDate.month, i + 1);
      String formatedLocalDate = DateFormat('dd-MM-yyyy').format(localDate);

      a.forEach((element) {
        if (formatedLocalDate.compareTo(element['logged_date'].toString().substring(0, 10)) == 0 &&
            _selectedMonthlyDate.month.isEqual(localDate.month)) {
          _monthlySteps[i] = DailyStatUiModel(
              steps: int.parse(element['steps_taken']),
              isToday: localDate.isSameDate(_selectedMonthlyDate));
          // print('Local Date : $localDate ');
        }
      });
    }
    setState(() => _monthlyLoading = false);

    print('Total Days: ${_monthlySteps[0].steps}');
    // setState(() => _montly = false);
  }

  Future _getWeekSteps(List a) async {
    _maxDuration = 1000;
    var daysInWeek = AppDateUtils.getDaysInWeek(_selectdWeeklyDate);
    var todayPosition = _selectdWeeklyDate.weekday - 1;
    _selectedIndicator = todayPosition;
    for (var i = 0; i <= 6; i++) {
      var date = daysInWeek[i];
      var localDate = DateFormat('dd-MM-yyyy').format(date);

      a.forEach((element) {
        if (localDate.compareTo(element['logged_date'].toString().substring(0, 10)) == 0) {
          _weekSteps[i] = DailyStatUiModel(
            steps: int.parse(element['steps_taken']),
            isToday: _selectdWeeklyDate.isSameDate(date),
          );
          print(element['logged_date']);
        } else {}
      });
      // print('Api Date : $apiDate');
    }
    // }
  }

  getInitialStepsValue(activities) async {
    bool oldLogic = false;
    if (oldLogic) {
      ///here we calculate the steps from the calorie and assign to the initialStepsValue variable to show the
      ///we will get this calorie from the getTodaysFoodLogApi ,
      double ccal = 0.0;
      var stepsFromApi = 0;
      int ssec = 0;
      double i1;
      int j1;
      if (ccal != 0.0 && ssec != 0) {
        ccal = 0.0;
        ssec = 0;
      }
      for (int i = 0; i < activities.length; i++) {
        // if(activities[i]['activityDetails'][0]['activityDetails'][0]['activityId']=='activity_103'){
        if (activities[i].activityDetails[0].activityDetails[0].activityId == 'activity_103') {
          try {
            i1 = double.tryParse(activities[i].totalCaloriesBurned) ?? 0.0;
            j1 = int.parse(
                (activities[i].activityDetails[0].activityDetails[0].activityDuration.toString()) ??
                    '0');
          } catch (e) {
            print(e);
            i1 = 0.0;
            j1 = 0;
          }
          ccal = ccal + i1;
          ssec = ssec + j1;
        }
      }
      print(ccal);
      stepsFromApi = await calculateStepsFromBurnedCalorie(ccal);
      // if(stepsFromApi==0){initialStepsValue=0;}
      await assignToRightHeir(stepsFromApi, ccal, ssec);
      return ssec;
      // initialStepsValue = 44;
      ///it will be assigned 0 if today user didn't log any Steps , this should be pretty clear...
    } else {
      final response1 = await _getStepsData(ihlUserId: ihlUserId);
      if (response1.statusCode == 200) {
        // print('====${response1.body.toString()}');
        List a = json.decode(response1.body);
        double ccal = 0.0;
        int stepsFromApi = 0;
        int ssec = 0;
        if (a.isNotEmpty &&
            DateFormat('dd-MM-yyyy HH:mm:ss')
                .parse(a[a.length - 1]['logged_date'])
                .isSameDate(DateTime.now())) {
          ccal = double.tryParse(a[a.length - 1]['calories_burned']) ?? 0.0;
          stepsFromApi = int.tryParse(a[a.length - 1]['steps_taken']) ?? 0;
          ssec = int.tryParse(a[a.length - 1]['duration']) ?? 0;
        }
        await assignToRightHeir(stepsFromApi, ccal, ssec);
        return ssec;
      } else {
        print('decode failed for get steps api');
      }
    }
  }

  convertDateTimetoStamp(dateTime) {
    DateTime dt = DateFormat('dd-MM-yyyy HH:mm:ss').parse(dateTime);
    var timeInEpoch = dt.millisecondsSinceEpoch; // TimeStamp to DateTime
    print("current phone data is: $timeInEpoch");
    return timeInEpoch;
  }

  graphCalculation(activities) async {
    var epochLogTime;
    var convertedStepsFromCal;
    dailyChartData = [];
    // activities[i].totalCaloriesGained
    for (int i = 0; i < activities.length; i++) {
      print(DateTime.now().subtract(Duration(days: 0)).toString().substring(8, 10));
      if (DateTime.now().subtract(Duration(days: 0)).toString().substring(5, 7) ==
          activities[i].logTime.substring(3, 5)) {
        if (DateTime.now().subtract(Duration(days: 0)).toString().substring(8, 10) ==
            activities[i].logTime.substring(0, 2)) {
          epochLogTime = convertDateTimetoStamp(activities[i].logTime.toString());
          var now = DateTime.fromMillisecondsSinceEpoch(epochLogTime);
          print(
            int.parse(
              DateFormat("h:mma").format(now).substring(0, 1),
            ),
          );
          convertedStepsFromCal = await calculateStepsFromBurnedCalorie(
              double.parse(activities[i].totalCaloriesBurned));

          dailyChartData.add(
            DailyCalorieData(
              now,
              convertedStepsFromCal,
            ),
          );
        }
      }
    }
    // return dailyChartData;
    graphDataList = [];
    graphDataList = dailyChartData;
    if (mounted) {
      setState(() {
        if (graphDataList.isEmpty) {
          nodata = true;
        }
        graphDataList;
      });
    }
  }

  calculateStepsFromBurnedCalorie(calorie) {
    if (calorie != 0 || calorie.toString() != 'null') {
      var sssttteeepppsss = 0;
      //write ythe logoc for the calorie to steps....
      sssttteeepppsss = (calorie * 22.727).toInt(); //100 meter => 4.4 cal
      // if (this.mounted) {
      //   setState(() {
      return sssttteeepppsss;
    } else {
      return 0;
    }
  }

  assignToRightHeir(steps, calorie, ssec) {
    initialStepsValue = steps;
    var mmin = (ssec / 60).toInt();
    if (mmin > 59) {
      ///convert it in hour by divide 60
      int hhour = (mmin / 60).toInt();
      initialMinValue = mmin - (hhour * 60);
      initialHourValue = hhour;
      initialSecondValue = ssec - (mmin * 60) - (hhour * 60 * 60);
      initialDurationValueInSec = ssec;
    } else if (mmin <= 59 && mmin > 0) {
      initialHourValue = 0;
      initialMinValue = mmin;
      initialSecondValue = ssec - (mmin * 60);
      initialDurationValueInSec = ssec;
    } else {
      initialMinValue = 0;
      initialHourValue = 0;
      initialSecondValue = ssec;
      initialDurationValueInSec = ssec;
    }

    sshoursStr.value = int.parse(
        ((((initialHourValue * 60 * 60)) / (60 * 60)) % 60).floor().toString().padLeft(2, '0'));
    sminutesStr.value =
        int.parse(((((initialMinValue * 60)) / 60) % 60).floor().toString().padLeft(2, '0'));
    ssecondsStr.value = int.parse((initialSecondValue % 60).floor().toString().padLeft(2, '0'));
    stodaySteps.value = steps;
    // _calorieBurn = calorie.toString();
  }

  timeOut() {
    ///after 60 second we make the timeout variable(sixtySecComplete) true
    _timer = Timer.periodic(
      eigthHour,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
            print(_start.toString());
          });
          // logSteps(ihlUserId: ihlUserId);

          //     .then((value){
          //   print('value===>>>>>>>>>>');m
          //   print(value);
          // });
        }
      },
    );
  }

  getUserAndStepData() async {
    await getLogStepsApi(ihlUserId: ihlUserId);

    // await getData();
    if (this.mounted) {
      setState(() {
        allData = extracted;
        print('Step Data $extracted');
        // graphData = allData;
        if (allData.length != 0) {
          var mapKeyskeys = allData.keys;
          graphData[mapKeyskeys.last] = allData[mapKeyskeys.last];
          print('Graph Data ${graphData[mapKeyskeys.last]}');
          print('Data :$allData');
        }
      });
    }
    return ihlUserId;
  }

  double kms() {
    // double toSend = _stepCountValue * kmPerStep * 100;
    double toSend = stodaySteps.value * kmPerStep * 100;
    int clean = toSend.toInt();
    toSend = clean / 100;
    return (toSend);
  }

  double _currentkmsDistance() {
    double _toSend = _currentStep * kmPerStep * 100;
    int clean = _toSend.toInt();
    _toSend = clean / 100;
    return (_toSend);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(int stepCountValue) {}
  var _cur = 0;
  void startListening() {
    _pedometer = Pedometer();
    _pedometer.pedometerStream.listen((event) => _cur = event);
    print('Start Stepts :$_cur');
    _subscription = _pedometer.pedometerStream.listen(
      getstodaySteps,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void stopListening() {
    print("end Step $_cur");
    _subscription.cancel();
  }

  var count = 0;
  // Box<int> stepsBox = Hive.box('steps');
  // var stepsBox = await SharedPreferences.getInstance();

  Box<int> stepsBox = Hive.box('steps');
  void _onData(int newValue) async {
    // var stepsBox = await SharedPreferences.getInstance();
    // stodaySteps =  await getstodaySteps(newValue,stepsBox);
    // if (this.mounted) {
    // setState(() {
    //   _stepCountValue = newValue;
    setToday();
    // getCalorie(_stepCountValue);
    getCalorie(stodaySteps.value - initialStepsValue);
    getCurrentColories(_currentStep);
    // count = 10;
    //in every 8 hour
    // and every time from init state
    // if(count>100){
    //   count=0;
    //   //call the log api
    //   logSteps(
    //     // steps: _stepCountValue.toString(),
    //     steps: stodaySteps.toString(),
    //     caloriesBurned: _calorieBurn.toString(),
    //     distanceCovered: kms().toString(),
    //     duration: '',
    //     logTime: genericDateTime(DateTime.now()).toString(),
    //     ihlUserId: '$ihlUserId',
    //   );
    // }
    // });
    // }
  }

  sharedPDataForExitScenario(startStop) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (startStop == true) {
      prefs.setInt('startStepValue', startStepValue);
      prefs.setBool('startStop', true);
      prefs.setString('startTimingOfSteps', DateTime.now().toString());
    } else {
      prefs.setBool('startStop', false);
    }
  }

  getstodaySteps(int value) async {
    // var stepsBox = await SharedPreferences.getInstance();
    print(value);
    if (startStepFlag) {
      startStepValue = value;
      startStepFlag = false;
      await sharedPDataForExitScenario(true);
    }
    int savedStepsCountKey = 999999;
    int savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;
    if (value < savedStepsCount) {
      // Upon device reboot, pedometer resets. When this happens, the saved counter must be reset as well.
      savedStepsCount = 0;
      // persist this value using a package of your choice here
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }

    // load the last day saved using a package of your choice here
    int lastDaySavedKey = 888888;
    int lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    // When the day changes, reset the daily steps count
    // and Update the last day saved as the day changes.
    if (lastDaySaved < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = value;

      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }

    // if(mounted){
    //   setState(() {
    //     stodaySteps.value = value - savedStepsCount;
    ///old logic above line , \\\ New Logic getting value form api below line
    stodaySteps.value = initialStepsValue + value - startStepValue;
    // stodaySteps.value = value - startStepValue;
    _currentStep = value - startStepValue;
    print(_currentStep);
    stepsBox.put(todayDayNo, stodaySteps.value);
    // return stodaySteps; // this is your daily steps value.
    _onData(stodaySteps.value);
  }

  logSteps(
      {ihlUserId, distanceCovered, duration, caloriesBurned, steps, google_fit, logTime}) async {
    try {
      http.Client _client = http.Client(); //3gb
      print(jsonEncode(<String, dynamic>{
        "ihl_user_id": "$ihlUserId",
        "distance_covered": "$distanceCovered",
        "duration": "$duration",
        "calories_burned": "$caloriesBurned",
        "steps_travelled": "$steps",
        "log_time": "$logTime",
        "google_fit": google_fit
      }));
      print({
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      });
      final response1 = await _client.post(
        Uri.parse(API.iHLUrl + '/consult/log_stepwalker_details'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{
          "ihl_user_id": "$ihlUserId",
          "distance_covered": "$distanceCovered",
          "duration": "$duration",
          "calories_burned": "$caloriesBurned",
          "steps_travelled": "$steps",
          "log_time": "$logTime",
          "google_fit": google_fit
        }),
      );
      if (response1.statusCode == 200) {
        // print('====${response1.body.toString()}');
        var finalOutPut = json.decode(response1.body);
        if (finalOutPut['status'] == 'success' &&
            finalOutPut['response'] == "logged successfully") {
          print('successfully logged');
        }
        return true;
      } else {
        print('failed!!!>>>====${response1.statusCode.toString()}');
        print('====${response1.body.toString()}');
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void logActivity(burnedCalorie, duration, isLogSucced) async {
    if (mounted) {
      setState(() {
        ssubmitted = true;
      });
    }
    if (isLogSucced) {
      final prefs = await SharedPreferences.getInstance();
      String iHLUserId = prefs.getString('ihlUserId');

      var data = {
        "user_ihl_id": iHLUserId,
        "activity_log_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "calories_burned":
            (double.parse(burnedCalorie) - double.parse(getCalorie(initialStepsValue)))
                .toStringAsFixed(2),
        "activity_details": [
          {
            "activity_details": [
              {
                "activity_id": "activity_103",
                "activity_name": "StepCounter(IHL)",
                "activity_duration": '$duration' //duration
              },
            ]
          }
        ]
      };
      print(data);
      var _cul = double.parse(
          (double.parse(burnedCalorie) - double.parse(getCalorie(initialStepsValue)))
              .toStringAsFixed(2));
      if (_cul > 0.01) {
        LogApis.logUserActivityApi(data: data).then((value) {
          if (value != null) {
            setState(() {
              ssubmitted = false;
            });
            var listApis = ListApis();
            listApis.getUserTodaysFoodLogHistoryApi().then((value) {
              // Get.close(1);
              getInitialStepsValue(value['activity']);

              ///write the function to get this particular activity , add all the duration and burned calorie of todays as obvious
              ///and than assign to that particular variable
              ///and than again when user click on stop same process will happen.
              graphCalculation(value['activity']);
              // Get.off(TodayActivityScreen(todaysActivityData: value['activity'], otherActivityData: value['previous_activity'],));
            });
            Get.snackbar('', '${camelize('Activity')} logged successfully.',
                icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.check_circle, color: Colors.white)),
                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                backgroundColor: HexColor('#6F72CA'),
                colorText: Colors.white,
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.BOTTOM);
          } else {
            setState(() {
              ssubmitted = false;
            });
            Get.snackbar('Oops!', 'There was a problem logging your activity. Try again.',
                icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.check_circle, color: Colors.white)),
                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                duration: Duration(seconds: 5),
                snackPosition: SnackPosition.BOTTOM);
          }
        });
      } else {
        if (mounted) {
          setState(() {
            ssubmitted = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          ssubmitted = false;
        });
      }
      Get.snackbar('Oops!', 'There was a problem logging your activity. Try again.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check_circle, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  getCalorie(step) {
    double addCal = step / 22.727; //100 meter => 4.4 cal

    _calorieBurn = addCal.toStringAsFixed(2); //addCal.toStringAsFixed(2);

    return _calorieBurn;
  }

  getCurrentColories(_currentStep) {
    double addCal = _currentStep / 22.727; //100 meter => 4.4 cal

    _currentCalore = addCal.toStringAsFixed(2); //addCal.toStringAsFixed(2);

    return _currentCalore;
  }

  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");
  List createList(Map map) {
    List list = [];
    map.forEach((key, value) {
      list.add({
        'value': value,
        'date': DateTime.parse(key),
      });
    });
    return list;
  }

  // DateTime
  genericDateTime(DateTime dateTime) {
    String str = dateTime.toString();
    var str1 = str.substring(0, str.indexOf(' '));
    var str2 = str.substring(str1.length + 1, str1.length + 6);
    // return DateTime.parse('$str1 00:00:00');
    var ss = str1 + " " + str2;

    // return DateTime.parse('$str1 $str2'+':00');
    return '$str1 $str2' + ':00';
  }

  setToday() async {
    ///yha par fate check krlo or use reset krdo
    // allData[genericDateTime(DateTime.now()).toString()] = _stepCountValue;
    allData[genericDateTime(DateTime.now()).toString()] = stodaySteps.value;
    if (this.mounted) {
      setState(() {});
    }
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(SPKeys.stepCounter, json.encode(allData));
  }

  getLogStepsApi({ihlUserId}) async {
    try {
      // http.Client _client = http.Client(); //3gb
      // final response1 = await _client.get(
      //   Uri.parse(API.iHLUrl +
      //       '/consult/get_stepwalker_details?ihl_user_id=$ihlUserId'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'ApiToken': '${API.headerr['ApiToken']}',
      //     'Token': '${API.headerr['Token']}',
      //   },
      // );
      final response1 = await _getStepsData(ihlUserId: ihlUserId);
      if (response1.statusCode == 200) {
        // print('====${response1.body.toString()}');
        List a = json.decode(response1.body);
        apiStepData = a;
        // await _getWeekSteps(a);

        await _getWeekSteps(a);
        await _getMonthSteps(a);
        Map g = {};
        keyContains(aa) {
//       print('keyContains =>'+'${aa.toString().substring(0,2)}');
          var isAvailable = ['false'];
//       var ad = DateTime.parse('$aa');
          g.forEach((k, v) {
//        var kd = DateTime.parse('$k');
            print(k.substring(0, 2));
            print(aa.substring(0, 2));
            if (k.substring(0, 2) == aa.substring(0, 2)) {
//        if(kd.day==ad.day){
              isAvailable = ['true', k];
            }
          });
          return isAvailable;
        }

        for (int i = 0; i < a.length; i++) {
          var b1 = keyContains(a[i]['logged_date']);
          if (b1[0] == 'true') {
            print('if $i');
            g[b1[1]] = g[b1[1]] + int.parse(a[i]['steps_taken'].toString());
          } else {
            print('else $i');
            g[a[i]['logged_date']] = int.parse(a[i]['steps_taken'].toString());
          }
          print('g is this....' + g.toString());
        }
        g.forEach((k, v) {
          //k ko ghumao..... phir value put kro<<<<<
          var l = k.split(' ');
          List l01 = l[0].split('-');
          var l1 = l01.reversed.toList();
          var y = l1[0] + "-" + l1[1] + "-" + l1[2] + " " + l[1];
          graphData['$y'] = '$v';
        });
        if (this.mounted) {
          setState(() {});
        }
        print('this is graph data===>>>>' + '$graphData');
      } else {
        print('failed!!!>>>====${response1.statusCode.toString()}');
        print('====${response1.body.toString()}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getWeightHeight() async {
    var prefs = await SharedPreferences.getInstance();
    weight = prefs.getDouble(SPKeys.weight);
    height = prefs.getDouble(SPKeys.height);
    if (height != null) {
      kmPerStep = height * 0.415 / 1000;
    }
  }

  Widget cardItem({String title, String subTitle}) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                title.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                subTitle.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardItem1({String title, String subTitle}) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Text(
              //   title.toString(),
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: sshoursStr.value > 0,
                    child: ValueListenableBuilder(
                      valueListenable: sshoursStr,
                      builder: (context, value, widget) {
                        String v = value.toString();
                        if (value.toString().length < 2) {
                          v = '0' + value.toString();
                        }
                        return Text(
                          v.toString() + ':',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: sminutesStr,
                    builder: (context, value, widget) {
                      String v = value.toString();
                      if (value.toString().length < 2) {
                        v = '0' + value.toString();
                      }
                      return Text(
                        v.toString() + ':',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: ssecondsStr,
                    builder: (context, value, widget) {
                      String v = value.toString();
                      if (value.toString().length < 2) {
                        v = '0' + value.toString();
                      }
                      return Text(
                        v.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      );
                    },
                  ),
                ],
              ),
              Text(
                subTitle.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardItem2({String title, String subTitle}) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Text(
              //   title.toString(),
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              // ),
              ValueListenableBuilder(
                valueListenable: stodaySteps,
                builder: (context, value, widget) {
                  String v = value.toString();
                  // if (value.toString().length < 2) {
                  //   v = '0' + value.toString();
                  // }
                  v = getCalorie(stodaySteps.value);
                  return Text(
                    '${double.tryParse(_calorieBurn).toInt().toString() ?? '0'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  );
                },
              ),
              Text(
                subTitle.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardItem3({String title, String subTitle}) {
    return Expanded(
      child: Card(
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Text(
              //   title.toString(),
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              // ),
              ValueListenableBuilder(
                valueListenable: stodaySteps,
                builder: (context, value, widget) {
                  String v = value.toString();
                  // if (value.toString().length < 2) {
                  //   v = '0' + value.toString();
                  // }
                  v = kms().toString();
                  return Text(
                    v.toString() + ' km',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  );
                },
              ),
              Text(
                subTitle.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphStat() {
    return _buildWeekIndicators(_weekSteps, 1);
  }

  _getDayDecoratedBox(bool isToday) {
    if (isToday) {
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: Theme.of(Get.context).primaryColor,
      );
    } else {
      return BoxDecoration();
    }
  }

  Widget _buildMonthlyDayIndicator(
    DailyStatUiModel model,
    int position,
  ) {
    final width = 14.0;
    return InkWell(
      onTap: () => setState(
        () => _selectedIndicator = position,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 45.0,
            height: 22.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: position == _selectedIndicator
                    ? Theme.of(Get.context).colorScheme.secondary
                    : Colors.white,
              ),
              child: Center(
                child: AutoSizeText(
                  '${model.steps}',
                  textAlign: TextAlign.center,
                  style: position == _selectedIndicator
                      ? Theme.of(Get.context)
                          .textTheme
                          .bodyLarge
                          .copyWith(fontSize: 12.0, color: Colors.white)
                      : Theme.of(Get.context)
                          .textTheme
                          .bodyLarge
                          .copyWith(fontSize: 12.0, color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Expanded(
            child: NeumorphicIndicator(
              width: width,
              percent: model.steps / _maxDuration,
            ),
          ),
          SizedBox(height: 8.0),
          DecoratedBox(
            decoration: _getDayDecoratedBox(position == _selectedIndicator),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                position.toString(),
                style: Theme.of(Get.context).textTheme.bodyLarge.copyWith(
                      fontSize: 13,
                      color: position == _selectedIndicator
                          ? Theme.of(Get.context).primaryColorLight
                          : Theme.of(Get.context).primaryColor,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayIndicator(DailyStatUiModel model, int position, String day) {
    final width = 14.0;
    return InkWell(
      onTap: () => setState(
        () => _selectedIndicator = position,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 45.0,
            height: 25.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: position == _selectedIndicator
                    ? Theme.of(Get.context).colorScheme.secondary
                    : Colors.white,
              ),
              child: Center(
                child: AutoSizeText(
                  '${model.steps}',
                  textAlign: TextAlign.center,
                  style: position == _selectedIndicator
                      ? Theme.of(Get.context)
                          .textTheme
                          .bodyLarge
                          .copyWith(fontSize: 12.0, color: Colors.white)
                      : Theme.of(Get.context)
                          .textTheme
                          .bodyLarge
                          .copyWith(fontSize: 12.0, color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Expanded(
            child: NeumorphicIndicator(
              width: width,
              percent: model.steps / _maxDuration,
            ),
          ),
          SizedBox(height: 8.0),
          DecoratedBox(
            decoration: _getDayDecoratedBox(model.isToday),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                day,
                style: Theme.of(Get.context).textTheme.bodyLarge.copyWith(
                      fontSize: 13,
                      color: model.isToday
                          ? Theme.of(Get.context).primaryColorLight
                          : Theme.of(Get.context).primaryColor,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _monthlyIndicators(
    List<DailyStatUiModel> monthData,
  ) {
    for (var step in monthData) {
      int currentStep = step.steps;
      if (currentStep > _maxDuration) {
        _maxDuration = (currentStep / 1000).ceil() * 1000;
      }
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height / 3.8,
        child: ListView.builder(
          controller: _controller,
          itemCount: monthData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) => _buildMonthlyDayIndicator(monthData[index], index + 1),
        ));
  }

  Widget _buildWeekIndicators(List weekData, int type) {
    for (var step in weekData) {
      int currentStep = step.steps;
      if (currentStep > _maxDuration) {
        _maxDuration = (currentStep / 1000).ceil() * 1000;
      }
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildDayIndicator(weekData[0], 0, 'Mon'),
          _buildDayIndicator(weekData[1], 1, 'Tue'),
          _buildDayIndicator(weekData[2], 2, 'Wed'),
          _buildDayIndicator(weekData[3], 3, 'Thu'),
          _buildDayIndicator(weekData[4], 4, 'Fri'),
          _buildDayIndicator(weekData[5], 5, 'Sat'),
          _buildDayIndicator(weekData[6], 6, 'Sun'),
        ],
      ),
    );
  }

  ScrollController _scrollController = ScrollController();
  final TabBarController _tabController = Get.find();
  String _dropDownValue = 'Weekly';
  Widget _buildDropDownButton() {
    return Container(
      height: 35,
      width: 110,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryColor.withOpacity(0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: false,
          value: _dropDownValue,
          style: TextStyle(color: Colors.white),
          onChanged: (v) {
            setState(() => _dropDownValue = v);
            if (_dropDownValue.compareTo('Weekly') == 0) {
              _selectedIndicator = _selectdWeeklyDate.weekday - 1;
            } else {
              _selectedIndicator = _selectedMonthlyDate.day;
              _animateToIndex(_selectedIndicator);
            }
            setState(() {});
          },
          items: [
            DropdownMenuItem(
              child: Text(
                'Weekly',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              value: 'Weekly',
            ),
            DropdownMenuItem(
              child: Text(
                'Monthly',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              value: 'Monthly',
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _aniMatecontroller.value;
    return WillPopScope(
      onWillPop: () {
        //  Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => HomeScreen(
        //             introDone: true,
        //           )),
        //   (Route<dynamic> route) => false);
        gTabBarController.index = 0;
        _tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
        Get.to(ManageHealthScreenTabs());
        return null;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: CustomPaint(
            painter: BackgroundPainter(
              primary: AppColors.primaryColor.withOpacity(0.7),
              secondary: AppColors.primaryColor,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: SafeArea(
                child: isLoadingCompleted
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BackButton(
                                onPressed: () {
                                  //  Navigator.pushAndRemoveUntil(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => HomeScreen(introDone: true)),
                                  //   (Route<dynamic> route) => false);
                                  gTabBarController.index = 0;
                                  _tabController.updateSelectedIconValue(
                                      value: AppTexts.manageHealth);
                                  Get.to(ManageHealthScreenTabs());
                                },
                                color: Colors.white,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Today\'s Progress',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25),
                                  ),
                                  Text(
                                    DateTimeFormat.format(DateTime.now(),
                                        format: DateTimeFormats.american),
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 40,
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: ScUtil().setHeight(10)),
                            child: ValueListenableBuilder(
                              valueListenable: stodaySteps,
                              builder: (context, value, widget) {
                                String v = value.toString();
                                return SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                    customColors: CustomSliderColors(
                                      trackColor: Colors.black45,
                                      progressBarColors: [
                                        Colors.yellow,
                                        Colors.red,
                                      ],
                                      dotColor: Colors.black,
                                    ),
                                    customWidths: CustomSliderWidths(
                                      progressBarWidth: 10,
                                      trackWidth: 10,
                                    ),
                                    infoProperties: InfoProperties(
                                      bottomLabelStyle: TextStyle(color: Colors.white),
                                      mainLabelStyle: TextStyle(color: Colors.white),
                                      topLabelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                      ),
                                      // topLabelText: '$_stepCountValue',
                                      topLabelText: '$v',
                                      // bottomLabelText: ' Goal: ' + goal.toString(),
                                      // bottomLabelText: '',
                                      modifier: (percentage) => 'Steps',
                                    ),
                                  ),
                                  min: 0,
                                  max: goal.toDouble(),
                                  // initialValue: _stepCountValue > goal
                                  initialValue: stodaySteps.value > goal
                                      ? goal.toDouble()
                                      : stodaySteps.value.toDouble(),
                                  // : _stepCountValue.toDouble(),
                                );
                              },
                            ),
                          ),
                          Center(
                            child: InkWell(
                              onTap: started
                                  ? () async {
                                      if (mounted) {
                                        setState(() {
                                          _aniMatecontroller.reverse();
                                          started = false;
                                        });
                                        //stop the duration
                                        stimerSubscription?.cancel();
                                        stimerStream = null;
                                        stopListening();
                                        int dur = //initialDurationValueInSec;
                                            int.parse(sshoursStr.value.toString()) * 60 * 60 +
                                                int.parse(sminutesStr.value.toString()) * 60 +
                                                int.parse(ssecondsStr.value.toString());
                                        dur = dur - initialDurationValueInSec;
                                        var _currentStep = stodaySteps.value - initialStepsValue;
                                        if (_currentStep > 0) {
                                          bool isLogSucced = await logSteps(
                                            // steps: _stepCountValue.toString(),
                                            // steps: _currentStep,
                                            steps: stodaySteps.value - initialStepsValue,
                                            caloriesBurned: _currentCalore,
                                            distanceCovered: _currentkmsDistance().toString(),
                                            google_fit: false,
                                            duration: '$dur',
                                            logTime: genericDateTime(DateTime.now()).toString(),
                                            ihlUserId: '$ihlUserId',
                                          );

                                          logActivity('$_calorieBurn', dur, isLogSucced);
                                          await getLogStepsApi(ihlUserId: ihlUserId);
                                          if (mounted) setState(() {});
                                        }
                                        await sharedPDataForExitScenario(false);
                                      }
                                    }
                                  : () async {
                                      bool _activityPermission =
                                          await PermissionHandlerUtil.hasPermissionOrRequest(
                                              Platform.isAndroid
                                                  ? await Permission.activityRecognition
                                                  : await Permission.sensors);
                                      if (_activityPermission) {
                                        if (mounted) {
                                          setState(() {
                                            _aniMatecontroller.forward();
                                            started = true;
                                          });
                                          startStepFlag = true;
                                          initPlatformState();
                                          //start the duration
                                          stimerStream = stopWatchStream();
                                          stimerSubscription = stimerStream.listen((int newTick) {
                                            // newTick= newTick*60;
                                            sshoursStr.value = int.parse(
                                                (((newTick + (initialDurationValueInSec)) /
                                                            (60 * 60)) %
                                                        60)
                                                    .floor()
                                                    .toString()
                                                    .padLeft(2, '0'));
                                            sminutesStr.value = int.parse(
                                                (((newTick + initialDurationValueInSec) / 60) % 60)
                                                    .floor()
                                                    .toString()
                                                    .padLeft(2, '0'));
                                            ssecondsStr.value = int.parse(
                                                ((newTick + initialDurationValueInSec) % 60)
                                                    .floor()
                                                    .toString()
                                                    .padLeft(2, '0'));
                                          });
                                        }
                                      }
                                    },
                              child: Transform.scale(
                                scale: _scale,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 15),
                                  height: ScUtil().setHeight(35),
                                  width: ScUtil().setWidth(150),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                            // color: Colors.white,
                                            color: started
                                                ? AppColors.primaryColor.withOpacity(0.5)
                                                : AppColors.primaryColor.withOpacity(0.9),
                                            spreadRadius: 2,
                                            blurRadius: 9,
                                            offset: Offset(3, 3)),
                                        BoxShadow(
                                            color: started ? Colors.white24 : Colors.white,
                                            // color: AppColors.primaryAccentColor,
                                            spreadRadius: 2,
                                            blurRadius: 9,
                                            offset: Offset(-3, -3)),
                                      ]),
                                  child: ssubmitted == false
                                      ? AutoSizeText(
                                          started ? "Stop" : "Start",
                                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                                        )
                                      : CircularProgressIndicator(
                                          color: FitnessAppTheme.white, strokeWidth: 1.5),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // _stepCountValue <= goal
                              stodaySteps.value <= goal
                                  ? cardItem1(
                                      title: int.parse(sshoursStr.value.toString()) < 1
                                          ? "${sminutesStr.value}:${ssecondsStr.value}"
                                          : "${sshoursStr.value}:${sminutesStr.value}:${ssecondsStr.value}",
                                      subTitle: 'Duration')
                                  : cardItem(subTitle: 'complete', title: 'Goal'),
                              cardItem2(title: '$_calorieBurn', subTitle: 'Calories'),
                              cardItem3(title: kms().toString() + ' km', subTitle: 'Distance'),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.50,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            '   My progress',
                                            style: TextStyle(
                                                color: CardColors.titleColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        _buildDropDownButton(),
                                      ],
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: ScUtil().setWidth(8)),
                                      padding:
                                          EdgeInsets.symmetric(vertical: ScUtil().setHeight(8)),
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
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
                                              offset: Offset(2.1, 2.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                      child: _dropDownValue == 'Weekly'
                                          ? _buildGraphStat()
                                          : _monthlyLoading
                                              ? CircularProgressIndicator()
                                              : _monthlyIndicators(
                                                  _monthlySteps,
                                                ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _dropDownValue == 'Weekly'
                                            ? _previousWeekButton()
                                            : _previousMonthButton(),
                                        _pageIndicatorText(_dropDownValue == 'Weekly'
                                            ? _weekDurationText
                                            : _monthDurationText),
                                        _dropDownValue == 'Weekly'
                                            ? displayNextWeekBtn
                                                ? _nextWeekButton()
                                                : SizedBox(
                                                    width: ScUtil().setWidth(75),
                                                  )
                                            : displayNextBtn
                                                ? _nextMonthButton()
                                                : SizedBox(
                                                    width: ScUtil().setWidth(40),
                                                  ),
                                      ],
                                    ),
                                    Text(
                                      'History',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: ScUtil().setSp(20),
                                        color: AppColors.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  reverse: true,
                                  itemCount: apiStepData.length,
                                  itemBuilder: (ctx, stepIndex) {
                                    DateTime dt = DateFormat('dd-MM-yyyy HH:mm:ss')
                                        .parse(apiStepData[stepIndex]['logged_date']);
                                    ExpandableController _expandableController =
                                        ExpandableController();

                                    return Column(
                                      children: <Widget>[
                                        //ignore: missing_required_param
                                        ExpandablePanel(
                                          controller: _expandableController,
                                          theme: ExpandableThemeData(
                                            animationDuration: Duration(milliseconds: 500),
                                            hasIcon: false,
                                            useInkWell: true,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: ListTile(
                                            onTap: () {
                                              _expandableController.toggle();
                                            },
                                            leading: Image.network(
                                              'https://flyclipart.com/thumb2/the-number-of-st-steps-icon-with-png-and-vector-format-360548.png',
                                              height: 30,
                                            ),
                                            trailing: Text(
                                              apiStepData[stepIndex]['steps_taken'],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 20),
                                            ),
                                            title: Text(
                                              DateTimeFormat.relative(dt) + ' ago',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0xff6d6e71),
                                              ),
                                            ),
                                          ),
                                          expanded: Container(
                                            alignment: Alignment.center,
                                            color: Colors.grey[100],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  DateTimeFormat.format(dt,
                                                      format: DateTimeFormats.american),
                                                ),
                                                _tableBuilder(data: {
                                                  'Steps': apiStepData[stepIndex]['steps_taken'],
                                                  'Date': DateFormat('dd MMMM yyyy').format(dt),
                                                  'Calories': apiStepData[stepIndex]
                                                      ['calories_burned'],
                                                  'Distance':
                                                      apiStepData[stepIndex]['distance'] + ' km',
                                                  'Duration': formatTime(int.parse(
                                                      apiStepData[stepIndex]['duration'])),
                                                })
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.dividerColor,
                                          height: 5,
                                        )
                                      ],
                                    );
                                  }),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: LinearProgressIndicator(),
                      )),
              ),
            ),
          ),
        ),
        // floatingActionButton: Padding(
        //   padding: EdgeInsets.only(bottom: ScUtil().setHeight(35)),
        //   child: Container(
        //     width: ScUtil().setWidth(50),
        //     height: ScUtil().setHeight(50),
        //     decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        //       BoxShadow(
        //           color: AppColors.primaryAccentColor.withOpacity(0.5),
        //           blurRadius: 25.0,
        //           spreadRadius: 10)
        //     ]),
        //     child: Visibility(
        //       visible: true,
        //       child: FloatingActionButton(
        //         shape: CircleBorder(
        //             side: BorderSide(
        //                 width: 2,
        //                 color: AppColors.primaryAccentColor,
        //                 style: BorderStyle.solid)),
        //         child: ssubmitted == false
        //             ? AutoSizeText(
        //                 started ? "Stop" : "Start",
        //                 style: TextStyle(fontSize: 16.0),
        //               )
        //             : CircularProgressIndicator(
        //                 color: FitnessAppTheme.white, strokeWidth: 1.5),
        //         // color: AppColors.primaryAccentColor,
        //         // textColor: Colors.white,
        //         // onPressed: () async {
        //         //   try {
        //         //     print('Called');
        //         //   } catch (e) {
        //         //     print('Error on $e');
        //         //   }
        //         // },
        //         onPressed: started
        //             ? () async {
        //                 if (mounted) {
        //                   setState(() {
        //                     started = false;
        //                   });

        //                   //stop the duration
        //                   stimerSubscription?.cancel();
        //                   stimerStream = null;
        //                   stopListening();
        //                   int dur = //initialDurationValueInSec;
        //                       int.parse(sshoursStr.value.toString()) * 60 * 60 +
        //                           int.parse(sminutesStr.value.toString()) * 60 +
        //                           int.parse(ssecondsStr.value.toString());
        //                   dur = dur - initialDurationValueInSec;
        //                   bool isLogSucced = await logSteps(
        //                     // steps: _stepCountValue.toString(),
        //                     // steps: _currentStep,
        //                     steps: stodaySteps.value - initialStepsValue,
        //                     caloriesBurned: _currentCalore,
        //                     distanceCovered: _currentkmsDistance().toString(),
        //                     duration: '$dur',
        //                     logTime: genericDateTime(DateTime.now()).toString(),
        //                     ihlUserId: '$ihlUserId',
        //                   );
        //                   await sharedPDataForExitScenario(false);

        //                   logActivity('$_calorieBurn', dur, isLogSucced);
        //                   await getLogStepsApi(ihlUserId: ihlUserId);
        //                   setState(() {});
        //                 }
        //               }
        //             : () async {
        //                 if (mounted) {
        //                   setState(() {
        //                     started = true;
        //                   });
        //                   startStepFlag = true;
        //                   initPlatformState();
        //                   //start the duration
        //                   stimerStream = stopWatchStream();
        //                   stimerSubscription =
        //                       stimerStream.listen((int newTick) {
        //                     // newTick= newTick*60;
        //                     sshoursStr.value = int.parse(
        //                         (((newTick + (initialDurationValueInSec)) /
        //                                     (60 * 60)) %
        //                                 60)
        //                             .floor()
        //                             .toString()
        //                             .padLeft(2, '0'));
        //                     sminutesStr.value = int.parse(
        //                         (((newTick + initialDurationValueInSec) / 60) %
        //                                 60)
        //                             .floor()
        //                             .toString()
        //                             .padLeft(2, '0'));
        //                     ssecondsStr.value = int.parse(
        //                         ((newTick + initialDurationValueInSec) % 60)
        //                             .floor()
        //                             .toString()
        //                             .padLeft(2, '0'));
        //                   });
        //                 }
        //               },
        //       ),
        //     ),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      // counter = counter+59;
      streamController.add(counter);
      if (!sflag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  _getStepsData({ihlUserId}) async {
    try {
      http.Client _client = http.Client(); //3gb
      final response1 = await _client.get(
        Uri.parse(API.iHLUrl + '/consult/get_stepwalker_details?ihl_user_id=$ihlUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      return response1;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  _getIhlUserId() async {
    var prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString(SPKeys.stepCounter);
    if (raw == null || raw == '') {
      raw = '{}';
    }
    extracted = await json.decode(raw);

    ///for ihl user id =>
    var userData = prefs.get(SPKeys.userData);
    userData = userData == null || userData == '' ? '{"User":{}}' : userData;
    Map res = await jsonDecode(userData);
    ihlUserId = res['User']['id'];
    print('User Id :' + ihlUserId);
    return ihlUserId;
  }
}
