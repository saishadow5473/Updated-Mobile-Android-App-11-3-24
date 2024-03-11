import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

/// ECG Calculator
class ECGCalc {
  Map allECGData;
  List graphsToShow;
  bool isLeadThree = false;
  List ecgData1;
  List ecgData2;
  List ecgData3;

  ECGCalc({String data1, String data2, String data3, this.isLeadThree}) {
    try{
    if (data1 != null && data1 != '') {
      data1 = data1.replaceAll(',,', ',');
      ecgData1 = jsonDecode('[$data1]');
    }}catch(e){
      if(data1[0]==",") {
        data1 = data1.replaceAll(',,', ',');
        data1 = "0" + data1;
        ecgData1 = jsonDecode('[$data1]');
      }
    }
    try {
      if (data2 != null && data2 != '') {
        data2 = data2.replaceAll(',,', ',');
        ecgData2 = jsonDecode('[$data2]');
      }
    }catch(e){
      if (data2 != null && data2 != '') {
        data2 = data2.replaceAll(',,', ',');
        if(data2[0]==",") {
          data2 = "0" + data2;
          ecgData2 = jsonDecode('[$data2]');
        }
      }
    }
    try{
    if (data3 != null && data3 != '') {
      data3 = data3.replaceAll(',,', ',');
      ecgData3 = jsonDecode('[$data3]');
      isLeadThree = true;
    }}catch(e){
      if (data3 != null && data3 != ''){
        data3 = data3.replaceAll(',,', ',');
        if(data3[0]==","){
          data3="0"+data3;
          ecgData3 = jsonDecode('[$data3]');
          isLeadThree = true;
        }
      }
    }
  }

  /// returns a map with keys as title/type of graph and value a graph spots 🚀🚀
  Map getMap() {
    Map toSend = {};

    if (ecgData1 != null) {
      toSend['Lead 1'] = {};
      toSend['Lead 1']['spots'] = getFlSimple(ecgData1);
      toSend['Lead 1']['max'] = getMax(toSend['Lead 1']['spots']);
      toSend['Lead 1']['min'] = getMin(toSend['Lead 1']['spots']);
    }
    if (ecgData2 != null) {
      toSend['Lead 2'] = {};
      toSend['Lead 2']['spots'] = getFlSimple(ecgData2);
      toSend['Lead 2']['max'] = getMax(toSend['Lead 2']['spots']);
      toSend['Lead 2']['min'] = getMin(toSend['Lead 2']['spots']);
    }
    // return toSend;
    if (isLeadThree) {
      toSend['Lead 3'] = {};
      toSend['Lead 3']['spots'] = getFlSimple(ecgData3);
      toSend['Lead 3']['max'] = getMax(toSend['Lead 3']['spots']);
      toSend['Lead 3']['min'] = getMin(toSend['Lead 3']['spots']);

      return toSend;
    }
    if (ecgData2 != null && ecgData1 != null) {
      toSend['Lead 3'] = {};
      toSend['AVR'] = {};
      toSend['AVL'] = {};
      toSend['AVF'] = {};
      //lead3
      toSend['Lead 3']['spots'] = getLead3(ecg: ecgData1, ecg2: ecgData2);
      toSend['Lead 3']['max'] = getMax(toSend['Lead 3']['spots']);
      toSend['Lead 3']['min'] = getMin(toSend['Lead 3']['spots']);
      //avr
      toSend['AVR']['spots'] = getAVR(ecg: ecgData1, ecg2: ecgData2);
      toSend['AVR']['max'] = getMax(toSend['AVR']['spots']);
      toSend['AVR']['min'] = getMin(toSend['AVR']['spots']);
      //AVL
      toSend['AVL']['spots'] = getAVL(ecg: ecgData1, ecg2: ecgData2);
      toSend['AVL']['max'] = getMax(toSend['AVL']['spots']);
      toSend['AVL']['min'] = getMin(toSend['AVL']['spots']);
      //AVF
      toSend['AVF']['spots'] = getAVF(ecg: ecgData1, ecg2: ecgData2);
      toSend['AVF']['max'] = getMax(toSend['AVF']['spots']);
      toSend['AVF']['min'] = getMin(toSend['AVF']['spots']);
    }
    return toSend;
  }

  /// rounding values 🎈
  double near500Max(double val) {
    int sign = val.compareTo(0);
    double toSend = 0;
    if (sign == 0) {
      return val;
    }
    if (sign == -1) {
      while (toSend > val) {
        toSend -= 500;
      }
      toSend += 500;
    }

    if (sign == 1) {
      while (toSend <= val) {
        toSend += 500;
      }
    }

    return toSend;
  }

  /// rounding values 🎈
  double near500Min(double val) {
    int sign = val.compareTo(0);
    double toSend = 0;
    if (sign == 0) {
      return val;
    }
    if (sign == -1) {
      while (toSend > val) {
        toSend -= 500;
      }
    }

    if (sign == 1) {
      while (toSend <= val) {
        toSend += 500;
      }
      toSend -= 500;
    }

    return toSend;
  }

  /// get maxima to nearest 500 🐦
  double getMax(List<FlSpot> spots) {
    FlSpot maxSpot =
        spots.reduce((value, element) => value.y > element.y ? value : element);
    return near500Max(maxSpot.y);
  }

  /// get minima to nearest 500 🐦
  double getMin(List<FlSpot> spots) {
    FlSpot minSpot =
        spots.reduce((value, element) => value.y < element.y ? value : element);
    return near500Min(minSpot.y);
  }

  /// calculate LEAD 3 for 6 point ❤
  List<FlSpot> getLead3({List ecg, List ecg2}) {
    List<FlSpot> listToSend = [];

    for (var i = 0; i < [ecg.length, ecg2.length].reduce(min); i++) {
      if (ecg[i] != null && ecg2[i] != null) {
        listToSend.add(FlSpot(i.toDouble(), (ecg2[i] - ecg[i]).toDouble()));
      }
    }
    return listToSend;
  }

  /// returns spots for given list ❤
  List<FlSpot> getFlSimple(List ecg) {
    List<FlSpot> listToSend = [];
    for (var i = 0; i < ecg.length; i++) {
      if (ecg[i] != null) {
        listToSend.add(FlSpot(i.toDouble(), ecg[i].toDouble()));
      }
    }
    return listToSend;
  }

  /// calculate AVL from lead 1 and 2 ❤
  List<FlSpot> getAVL({List ecg, List ecg2}) {
    List<FlSpot> listToSend = [];
    for (var i = 0; i < [ecg.length, ecg2.length].reduce(min); i++) {
      if (ecg[i] != null) {
        listToSend
            .add(FlSpot(i.toDouble(), (ecg2[i] - (ecg[i] / 2)).toDouble()));
      }
    }
    return listToSend;
  }
}

/// calculate AVF from lead 1 and 2 ❤
List<FlSpot> getAVF({List ecg, List ecg2}) {
  List<FlSpot> listToSend = [];
  for (var i = 0; i < [ecg.length, ecg2.length].reduce(min); i++) {
    if (ecg[i] != null) {
      listToSend.add(FlSpot(i.toDouble(), (ecg[i] - (ecg2[i] / 2)).toDouble()));
    }
  }
  return listToSend;
}

/// calculate AVR from lead 1 and 2 ❤
List<FlSpot> getAVR({List ecg, List ecg2}) {
  List<FlSpot> listToSend = [];
  for (var i = 0; i < [ecg.length, ecg2.length].reduce(min); i++) {
    if (ecg[i] != null) {
      listToSend
          .add(FlSpot(i.toDouble(), -((ecg[i] + ecg2[i]) / 2).toDouble()));
    }
  }
  return listToSend;
}
