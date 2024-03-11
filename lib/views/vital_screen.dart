import 'package:flutter/material.dart';
import 'package:ihl/constants/cardTheme.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/widgets/vitalScreen/vital_graph.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../widgets/vitalScreen/journal_entry.dart';

//Global variables
var gproteinl,
    gproteinh,
    gecll,
    geclh,
    gicll,
    giclh,
    glowSmmReference,
    glowBmcReference,
    glowPbfReference,
    gacceptablePbfReference,
    ghighPbfReference,
    glowFatReference,
    gacceptableFatReference,
    ghighFatReference,
    gwaisttoheightratiolow,
    gHeight,
    gWeight,
    gBmi,
    gwaisttoheightratiohigh;

/// Vital screen 🎈🎈
class VitalScreen extends StatelessWidget {
  static const String id = 'vital_screen';
  ScrollController _scrollController = ScrollController();

  Widget _switchVitalData({
    String data,
    value,
    context,
  }) {
    switch (data) {
      case 'Cholesterol':
        return _vitallownrmlhighStatus(
            value: value,
            interval: 4.0,
            max: 40.0,
            min: 0.0,
            context: context,
            nrmlStart: gecll,
            nrmlEnd: geclh,
            obeseEnd: 40.0,
            obeseStart: geclh,
            highShow: true);
        break;
      case 'ECW':
        return _vitallownrmlhighStatus(
            value: value,
            interval: 4.0,
            max: 40.0,
            min: 0.0,
            context: context,
            nrmlStart: gecll,
            nrmlEnd: geclh,
            obeseEnd: 40.0,
            obeseStart: geclh,
            highShow: true);
        break;
      case 'ICW':
        return _vitallownrmlhighStatus(
          context: context,
          value: value,
          interval: 4.0,
          max: 40.0,
          min: 0.0,
          nrmlStart: gicll,
          nrmlEnd: giclh,
          obeseStart: giclh,
          obeseEnd: 40.0,
          highShow: true,
        );
        break;
      case 'MINERAL':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 1.0,
            max: 10.0,
            min: 0.0,
            nrmlStart: 2.00,
            nrmlEnd: 10.0,
            lowStart: 0.0,
            lowEnd: 2.0);
        break;
      case 'SMM':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 10.0,
            max: 100.0,
            min: 0.0,
            nrmlStart: glowSmmReference,
            nrmlEnd: 100.0,
            lowStart: 0.0,
            lowEnd: glowSmmReference);
        break;
      case 'BMC':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 1.0,
            max: 10.0,
            min: 0.0,
            nrmlStart: glowBmcReference,
            nrmlEnd: 100.0,
            lowStart: 0.0,
            lowEnd: glowBmcReference);
        break;
      case 'PBF':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 10.0,
            max: 100.0,
            min: 0.0,
            nrmlStart: glowPbfReference,
            nrmlEnd: ghighPbfReference,
            highShow: true,
            obeseStart: ghighPbfReference,
            obeseEnd: 100.0);
        break;
      case 'BCM':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 5.0,
            max: 50.0,
            min: 0.0,
            nrmlStart: 20.0,
            nrmlEnd: 50.0,
            lowStart: 0.0,
            lowEnd: 20.0);
        break;
      case 'BFM':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 5.0,
            max: 50.0,
            min: 0.0,
            nrmlStart: glowFatReference,
            nrmlEnd: ghighFatReference,
            highShow: true,
            obeseStart: ghighFatReference,
            obeseEnd: 50.0);
        break;
      case 'VF':
        return _vitalnrmlHighStatus(
            context: context,
            value: int.tryParse(value.toString()) > 0 ? value : '0',
            interval: 25.0,
            max: 200.0,
            min: 0.0,
            nrmlStart: 0.0,
            nrmlEnd: 100.0,
            highStart: 100.0,
            highEnd: 200.0);
        break;
      case 'BMR':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 300.0,
            max: 2500.0,
            min: 1000.0,
            lowStart: 0.0,
            lowEnd: 1200.00,
            nrmlStart: 1200.0,
            nrmlEnd: 2500.0);
        break;
      case 'WtHR':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 1.0,
            max: 5.0,
            min: 0.0,
            nrmlStart: gwaisttoheightratiolow,
            nrmlEnd: gwaisttoheightratiohigh,
            highShow: true,
            obeseStart: gwaisttoheightratiohigh,
            obeseEnd: 5.0);
        break;
      case 'WAIST HIP':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 0.5,
            max: 3.0,
            min: 0.0,
            nrmlStart: 0.80,
            nrmlEnd: 0.90,
            highShow: true,
            obeseStart: 0.90,
            obeseEnd: 3.0);
        break;
      case 'TEMP':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 10.0,
            max: 120.0,
            min: 80.0,
            nrmlStart: 97.00,
            nrmlEnd: 99.00,
            highShow: true,
            obeseStart: 99.00,
            obeseEnd: 120.0);
        break;
      case 'PULSE':
        return _vitallownrmlhighStatus(
          context: context,
          interval: 25.0,
          min: 30.0,
          max: 150.0,
          nrmlStart: 60.0,
          nrmlEnd: 99.00,
          obeseStart: 99.00,
          obeseEnd: 150.00,
          value: value,
          highShow: true,
        );
        break;
      case 'FAT':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 10.0,
            max: 50.0,
            min: 0.0,
            nrmlStart: glowFatReference,
            nrmlEnd: ghighFatReference,
            highShow: true,
            obeseStart: ghighFatReference,
            obeseEnd: 50.0);
        break;
      case 'ECG':
        return _vitalnrmlHighStatus(
          context: context,
          value: value,
          interval: 20.0,
          min: 60.0,
          max: 150.0,
          nrmlStart: 60.0,
          nrmlEnd: 100.0,
          highStart: 100.0,
          highEnd: 150.0,
        );
        break;
      case 'BP':
        var a = value.split('/');
        return _vitalnrmlHighStatus(
            context: context,
            value: a[0],
            interval: 20.0,
            max: 250.0,
            min: 70.0,
            nrmlStart: 70.00,
            nrmlEnd: 139.00,
            highStart: 139.00,
            highEnd: 250.00);
        break;
      default:
        return Text('No Range Found');
    }
  }

  Widget _vitallownrmlhighStatus(
      {String value,
      BuildContext context,
      obeseStart,
      obeseEnd,
      nrmlStart,
      nrmlEnd,
      interval,
      min,
      max,
      bool highShow}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: ScUtil().setHeight(10)),
        SfLinearGauge(
            interval: interval,
            ranges: <LinearGaugeRange>[
              LinearGaugeRange(
                startValue: min,
                endValue: nrmlStart,
                color: colorForStatus('Underweight'),
              ),
              LinearGaugeRange(
                startValue: nrmlStart,
                endValue: nrmlEnd,
                color: colorForStatus('Normal'),
              ),
              highShow
                  ? LinearGaugeRange(
                      startValue: nrmlEnd,
                      endValue: max,
                      color: colorForStatus('Obese'),
                    )
                  : LinearGaugeRange(startValue: 0, endValue: 0, color: colorForStatus('Normal')),
            ],
            minimum: min,
            maximum: max,
            markerPointers: [LinearShapePointer(value: double.parse(value))]),
        SizedBox(height: ScUtil().setHeight(15)),
        Container(
          width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Underweight'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'Low : Below $nrmlStart',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              // Navigator.pop(context);
            },
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Normal'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'Normal : $nrmlStart - $nrmlEnd',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              // Navigator.pop(context);
            },
          ),
        ),
        highShow
            ? Container(
                width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: colorForStatus('Obese'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    'High : $nrmlEnd above ',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Navigator.pop(context);
                  },
                ),
              )
            : SizedBox.shrink(),
        SizedBox(height: ScUtil().setHeight(15)),
      ],
    );
  }

  Widget _vitalnrmlHighStatus(
      {value, BuildContext context, nrmlStart, nrmlEnd, highStart, highEnd, interval, min, max}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: ScUtil().setHeight(10)),
        SfLinearGauge(
            interval: interval,
            ranges: <LinearGaugeRange>[
              LinearGaugeRange(
                startValue: nrmlStart,
                endValue: nrmlEnd,
                color: colorForStatus('Normal'),
              ),
              LinearGaugeRange(
                startValue: highStart,
                endValue: highEnd,
                color: colorForStatus('Obese'),
              ),
            ],
            minimum: min,
            maximum: max,
            markerPointers: [LinearShapePointer(value: double.parse(value))]),
        SizedBox(height: ScUtil().setHeight(15)),
        Container(
          width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Normal'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'Normal : $nrmlStart - $nrmlEnd',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              //  Navigator.pop(context);
            },
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Obese'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'High : $highStart and above',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              //  Navigator.pop(context);
            },
          ),
        ),
        SizedBox(height: ScUtil().setHeight(15)),
      ],
    );
  }

  Widget _vitallownrmlStatus(
      {value, BuildContext context, lowStart, lowEnd, nrmlStart, nrmlEnd, interval, min, max}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: ScUtil().setHeight(10)),
        SfLinearGauge(
            interval: interval,
            ranges: <LinearGaugeRange>[
              LinearGaugeRange(
                startValue: lowStart,
                endValue: lowEnd,
                color: colorForStatus('Underweight'),
              ),
              LinearGaugeRange(
                startValue: nrmlStart,
                endValue: nrmlEnd,
                color: colorForStatus('Normal'),
              ),
            ],
            minimum: min,
            maximum: max,
            markerPointers: [LinearShapePointer(value: double.parse(value))]),
        SizedBox(height: ScUtil().setHeight(15)),
        Container(
          width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Underweight'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'Low : $lowEnd',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              //  Navigator.pop(context);
            },
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          // Will take 50% of screen space
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: colorForStatus('Normal'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              'Normal : $nrmlStart and above',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              //  Navigator.pop(context);
            },
          ),
        ),
        SizedBox(height: ScUtil().setHeight(15)),
      ],
    );
  }

  colorForStatus(riskLevel) {
    if (riskLevel == 'Underweight') {
      return Color(0xfffdc135);
    } else if (riskLevel == 'Normal') {
      return Color(0xff7ac744);
    } else if (riskLevel == 'Overweight') {
      return Color(0xfffd712c);
    } else if (riskLevel == 'Obese') {
      return Color(0xffed4438);
    } else if (riskLevel == 'Border Line') {
      return Color(0xfffd712c);
    }
  }

  int calcBmi({height, weight}) {
    double parsedH;
    double parsedW;
    if (height == null || weight == null) {
      return null;
    }

    parsedH = double.tryParse(height.toString());
    parsedW = double.tryParse(weight.toString());
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);
      gBmi = double.parse(bmi.toString());
      return bmi;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Map routeData = ModalRoute.of(context).settings.arguments;

    final String value = routeData['value'];
    final String status = routeData['status'];
    final String vitalType = routeData['vitalType'];
    final List data = routeData['data'];
    var color;
    if (vitalsUI[vitalType]['acr'] == "BMR")
      color = AppColors.primaryColor;
    else
      color = cardTheme1['text'][data.last['status']];

    color ??= Colors.blueAccent;
    scrolltoBottom(int pos) {
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        _scrollController.animateTo(_scrollController.offset + pos,
            duration: Duration(milliseconds: 100), curve: Curves.linear);
      });
    }

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    final shadow = BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 2),
    );
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: CustomPaint(
            painter: BackgroundPainter(
                primary: color.withOpacity(0.8), secondary: color.withOpacity(0.0)),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          BackButton(
                            color: Colors.white,
                          ),
                          Text(
                            vitalsUI[vitalType]['name'].length < 15
                                ? vitalsUI[vitalType]['name']
                                : vitalsUI[vitalType]['acr'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScUtil().setSp(30),
                            ),
                          ),
                          SizedBox(
                            width: ScUtil().setWidth(40),
                          )
                        ],
                      ),
                      Text(
                        vitalsUI[vitalType]['name'].length >= 15 ? vitalsUI[vitalType]['name'] : '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: ScUtil().setSp(15),
                        ),
                      ),
                      vitalsUI[vitalType]['acr'] != "BMR"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    value.toString() + ' ' + vitalsUI[vitalType]['unit'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScUtil().setSp(25),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Hero(
                                    tag: vitalType + 'screen',
                                    child: Image.asset(vitalsUI[vitalType]['icon'],
                                        height: ScUtil().setSp(30), color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: vitalsUI[vitalType]['acr'] != "BMR"
                                      ? Text(
                                          //removed autosizetext it caused render issue
                                          status,
                                          maxLines: 4,
                                          textAlign: TextAlign.center,
                                          // maxFontSize: ScUtil().setSp(20),
                                          // minFontSize: ScUtil().setSp(15),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScUtil().setSp(20),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            )
                          : Column(children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Hero(
                                  tag: vitalType + 'screen',
                                  child: Image.asset(vitalsUI[vitalType]['icon'],
                                      height: ScUtil().setSp(30), color: Colors.white),
                                ),
                              ),
                              Text(
                                value.toString() + ' ' + vitalsUI[vitalType]['unit'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScUtil().setSp(25),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ])
                    ],
                  ),
                ),
                vitalsUI[vitalType]['acr'] != "BMR"
                    ? SizedBox(
                        height: ScUtil().setHeight(20),
                      )
                    : SizedBox(
                        height: ScUtil().setHeight(5),
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: <Widget>[
                              Visibility(
                                visible: vitalsUI[vitalType]['acr'] != "BMR",
                                child: Card(
                                  child: VitalGraph(
                                    data: data,
                                    isBP: vitalType == 'bp',
                                  ),
                                  color: CardColors.bgColor,
                                ),
                              ),
                              SizedBox(
                                height: ScUtil()
                                    .setHeight(vitalsUI[vitalType]['acr'] != "BMR" ? 30 : 0),
                              ),
                              Visibility(
                                visible: vitalsUI[vitalType]['acr'] != "BMR",
                                child: Card(
                                  color: CardColors.bgColor,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.8),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            margin: EdgeInsets.all(10),
                                            child: Center(
                                              child: vitalsUI[vitalType]['unit'] != ''
                                                  ? Column(
                                                      children: <Widget>[
                                                        RichText(
                                                          text: TextSpan(
                                                            text: value.toString(),
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: ScUtil().setSp(20)),
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      '${vitalsUI[vitalType]['unit']} ',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.white,
                                                                      fontSize:
                                                                          ScUtil().setSp(13))),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      value.toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              ScUtil().setSp(60) / value.length),
                                                    ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  RichText(
                                                    text: TextSpan(
                                                      text:
                                                          'Your ${vitalsUI[vitalType]['name']} is ',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: CardColors.titleColor,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "$value " +
                                                                '${vitalsUI[vitalType]['unit']}.',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 16)),
                                                        TextSpan(
                                                          text: '\nStatus:',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w800,
                                                            color: CardColors.titleColor,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' $status',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                              fontSize: 16),
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
                                      // vitalsUI[vitalType]['acr'] != "Cholesterol"
                                      //     ?
                                      StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          if (vitalsUI[vitalType]['acr'] == 'WEIGHT') {
                                            calcBmi(height: gHeight, weight: gWeight);
                                          }
                                          return SingleChildScrollView(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width - 100,
                                              color: Colors.transparent,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  // SizedBox(height: 5),
                                                  Container(
                                                    child: vitalsUI[vitalType]['acr'] == 'BMI' ||
                                                            vitalsUI[vitalType]['acr'] == 'WEIGHT'
                                                        ? Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceEvenly,
                                                            children: <Widget>[
                                                              SizedBox(
                                                                  height: ScUtil().setHeight(10)),
                                                              SfLinearGauge(
                                                                  interval: 10.0,
                                                                  ranges: <LinearGaugeRange>[
                                                                    LinearGaugeRange(
                                                                      startValue: 0,
                                                                      endValue: 18.5,
                                                                      color: colorForStatus(
                                                                          'Underweight'),
                                                                    ),
                                                                    LinearGaugeRange(
                                                                      startValue: 18.5,
                                                                      endValue: 22.99,
                                                                      color:
                                                                          colorForStatus('Normal'),
                                                                    ),
                                                                    LinearGaugeRange(
                                                                      startValue: 23,
                                                                      endValue: 27.5,
                                                                      color: colorForStatus(
                                                                          'Overweight'),
                                                                    ),
                                                                    LinearGaugeRange(
                                                                      startValue: 27.5,
                                                                      endValue: 50.0,
                                                                      color:
                                                                          colorForStatus('Obese'),
                                                                    )
                                                                  ],
                                                                  minimum: 0,
                                                                  maximum: 50,
                                                                  markerPointers: [
                                                                    LinearShapePointer(
                                                                        value: double.parse(
                                                                            vitalsUI[vitalType]
                                                                                        ['acr'] ==
                                                                                    'WEIGHT'
                                                                                ? gBmi.toString()
                                                                                : value))
                                                                  ]),
                                                              SizedBox(
                                                                  height: ScUtil().setHeight(15)),
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                    0.6, // Will take 50% of screen space
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary: colorForStatus(
                                                                        'Underweight'),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'Underweight : Below 18.5',
                                                                    style: TextStyle(
                                                                        color: Colors.white),
                                                                  ),
                                                                  onPressed: () {
                                                                    //Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                    0.6, // Will take 50% of screen space
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary:
                                                                        colorForStatus('Normal'),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'Normal : 18.5 - 22.99',
                                                                    style: TextStyle(
                                                                        color: Colors.white),
                                                                  ),
                                                                  onPressed: () {
                                                                    // Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                    0.6, // Will take 50% of screen space
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary: colorForStatus(
                                                                        'Overweight'),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'Overweight : 23.0 - 27.5',
                                                                    style: TextStyle(
                                                                        color: Colors.white),
                                                                  ),
                                                                  onPressed: () {
                                                                    // Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                    0.6, // Will take 50% of screen space
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary:
                                                                        colorForStatus('Obese'),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    'Obese : 27.5 and above',
                                                                    style: TextStyle(
                                                                        color: Colors.white),
                                                                  ),
                                                                  onPressed: () {
                                                                    // Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: ScUtil().setHeight(15)),
                                                            ],
                                                          )
                                                        : vitalsUI[vitalType]['acr'] == 'SPO2'
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceEvenly,
                                                                children: <Widget>[
                                                                  SizedBox(
                                                                      height:
                                                                          ScUtil().setHeight(10)),
                                                                  SfLinearGauge(
                                                                      interval: 10.0,
                                                                      ranges: <LinearGaugeRange>[
                                                                        LinearGaugeRange(
                                                                          startValue: 70,
                                                                          endValue: 94.99,
                                                                          color: colorForStatus(
                                                                              'Obese'),
                                                                        ),
                                                                        LinearGaugeRange(
                                                                          startValue: 95,
                                                                          endValue: 100,
                                                                          color: colorForStatus(
                                                                              'Normal'),
                                                                        ),
                                                                      ],
                                                                      minimum: 70,
                                                                      maximum: 100,
                                                                      markerPointers: [
                                                                        LinearShapePointer(
                                                                            value:
                                                                                double.parse(value))
                                                                      ]),
                                                                  SizedBox(
                                                                      height:
                                                                          ScUtil().setHeight(15)),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6, // Will take 50% of screen space
                                                                    child: ElevatedButton(
                                                                      style:
                                                                          ElevatedButton.styleFrom(
                                                                        primary: colorForStatus(
                                                                            'Normal'),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  5.0),
                                                                        ),
                                                                      ),
                                                                      child: Text(
                                                                        'Healthy : 95 and above',
                                                                        style: TextStyle(
                                                                            color: Colors.white),
                                                                      ),
                                                                      onPressed: () {
                                                                        // Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    // Will take 50% of screen space
                                                                    child: ElevatedButton(
                                                                      style:
                                                                          ElevatedButton.styleFrom(
                                                                        primary:
                                                                            colorForStatus('Obese'),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  5.0),
                                                                        ),
                                                                      ),
                                                                      child: Text(
                                                                        'Low : 95 Below',
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                      onPressed: () {
                                                                        //  Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          ScUtil().setHeight(15)),
                                                                ],
                                                              )
                                                            : vitalsUI[vitalType]['acr'] ==
                                                                    'PROTEIN'
                                                                ? _vitallownrmlStatus(
                                                                    value: value,
                                                                    context: context,
                                                                    min: 0.0,
                                                                    interval: 5.0,
                                                                    lowEnd: gproteinl,
                                                                    max: 40.0,
                                                                    nrmlEnd: 40.0,
                                                                    nrmlStart: gproteinl,
                                                                    lowStart: 0.0)
                                                                : vitalsUI[vitalType]['acr'] ==
                                                                        'Cholesterol'
                                                                    ? Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceEvenly,
                                                                        children: <Widget>[
                                                                          SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(10)),
                                                                          SfLinearGauge(
                                                                              interval: 100,
                                                                              ranges: <
                                                                                  LinearGaugeRange>[
                                                                                LinearGaugeRange(
                                                                                  startValue: 140,
                                                                                  endValue: 200,
                                                                                  color:
                                                                                      colorForStatus(
                                                                                          'Normal'),
                                                                                ),
                                                                                LinearGaugeRange(
                                                                                  startValue: 200,
                                                                                  endValue: 239,
                                                                                  color: colorForStatus(
                                                                                      'Border Line'),
                                                                                ),
                                                                                LinearGaugeRange(
                                                                                  startValue: 239,
                                                                                  endValue: 400,
                                                                                  color:
                                                                                      colorForStatus(
                                                                                          'Obese'),
                                                                                )
                                                                              ],
                                                                              minimum: 140,
                                                                              maximum: 400,
                                                                              markerPointers: [
                                                                                LinearShapePointer(
                                                                                    value: double
                                                                                        .parse(
                                                                                            value))
                                                                              ]),
                                                                          SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(15)),
                                                                          Container(
                                                                            width: MediaQuery.of(
                                                                                        context)
                                                                                    .size
                                                                                    .width *
                                                                                0.6, // Will take 50% of screen space
                                                                            child: ElevatedButton(
                                                                              style: ElevatedButton
                                                                                  .styleFrom(
                                                                                primary:
                                                                                    colorForStatus(
                                                                                        'Normal'),
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              5.0),
                                                                                ),
                                                                              ),
                                                                              child: Text(
                                                                                'Healthy : Less than 200',
                                                                                style: TextStyle(
                                                                                    color: Colors
                                                                                        .white),
                                                                              ),
                                                                              onPressed: () {
                                                                                //  Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            width: MediaQuery.of(
                                                                                        context)
                                                                                    .size
                                                                                    .width *
                                                                                0.6,
                                                                            // Will take 50% of screen space
                                                                            child: ElevatedButton(
                                                                              style: ElevatedButton
                                                                                  .styleFrom(
                                                                                primary:
                                                                                    colorForStatus(
                                                                                        'Border Line'),
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              5.0),
                                                                                ),
                                                                              ),
                                                                              child: Text(
                                                                                'BorderLine high : 200 to 239',
                                                                                style: TextStyle(
                                                                                  color:
                                                                                      Colors.white,
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                //  Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            width: MediaQuery.of(
                                                                                        context)
                                                                                    .size
                                                                                    .width *
                                                                                0.6,
                                                                            // Will take 50% of screen space
                                                                            child: ElevatedButton(
                                                                              style: ElevatedButton
                                                                                  .styleFrom(
                                                                                primary:
                                                                                    colorForStatus(
                                                                                        'Obese'),
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              5.0),
                                                                                ),
                                                                              ),
                                                                              child: Text(
                                                                                'high : above 240',
                                                                                style: TextStyle(
                                                                                  color:
                                                                                      Colors.white,
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                // Navigator.pop(context);
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(15)),
                                                                        ],
                                                                      )
                                                                    : _switchVitalData(
                                                                        data: vitalsUI[vitalType]
                                                                            ['acr'],
                                                                        value: value,
                                                                        context: context,
                                                                      ),
                                                  ),

                                                  /*  Center(
                                                    child: Container(
                                                      child: ButtonTheme(
                                                        child: ElevatedButton(
                                                          onPressed: () async {},
                                                          child:
                                                              Text("Dashboard"),
                                                          style: TextButton
                                                              .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30)),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 15,
                                                                    horizontal:
                                                                        25),
                                                            backgroundColor: AppColors
                                                                .primaryAccentColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                */
                                                  SizedBox(height: 5),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      //: Container(),

                                      /*  Center(
                                                    child: Container(
                                                      child: ButtonTheme(
                                                        child: ElevatedButton(
                                                          onPressed: () async {},
                                                          child:
                                                              Text("Dashboard"),
                                                          style: TextButton
                                                              .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30)),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 15,
                                                                    horizontal:
                                                                        25),
                                                            backgroundColor: AppColors
                                                                .primaryAccentColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                */
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScUtil().setSp(20),
                                    color: AppColors.lightTextColor,
                                  ),
                                ),
                              ),
                              Column(
                                children: data.reversed.map((f) {
                                  return JournalEntry(
                                      date: f['date'],
                                      icon: vitalsUI[vitalType]['icon'],
                                      statusColor: cardTheme1['text'][f['status']] == null
                                          ? Colors.blueAccent
                                          : (vitalsUI[vitalType]['acr'] == "BMR")
                                              ? AppColors.primaryColor
                                              : cardTheme1['text'][f['status']],
                                      value: f['value'].toString(),
                                      status:
                                          (vitalsUI[vitalType]['acr'] == "BMR") ? '' : f['status'],
                                      unit: vitalsUI[vitalType]['unit'],
                                      data: f['moreData'],
                                      bottom: scrolltoBottom,
                                      ecgGraphData: f['graphECG']);
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
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
