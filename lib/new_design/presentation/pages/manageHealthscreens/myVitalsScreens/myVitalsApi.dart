import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ihl/new_design/data/providers/network/api_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/vitals/myVitalWidgets.dart';

class MyvitalsGraphData {
  final dio = Dio();
  Future<List<dynamic>> getVitalsdata(
      DateTime startDate, DateTime endDate, String vitalName) async {
    // NewMyVitalGraph.loader = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlUserId = prefs.get("ihlUserId");
    String Start = DateFormat('MM/dd/yyyy HH:mm:ss').format(startDate);
    String End = DateFormat('MM/dd/yyyy HH:mm:ss').format(endDate);
    vitalName = vitalName == "WAIST HIP" ? "waist hip" : vitalName.toLowerCase();
    try {
      var response = await dio.post(
        '${API.iHLUrl}/platformservice/get_vital_data_date_range',
        data: json.encode({
          "user_id": ihlUserId, "vital": vitalName,
          "date_from": Start, "date_to": End
          // "date_from": "07/02/2022 01:00:00",

          // "date_to": "07/05/2023 23:00:00"
        }),
      );
      // NewMyVitalGraph.loader = false;
      if (vitalName.toLowerCase() == 'ecg') {
        List<dynamic> ecgList = [];
        List<dynamic> jsonData = response.data['status'];
        ecgList = jsonData.map((e) {
          String timestamp = e['Timestamp'];
          int unixTimestamp = int.parse(timestamp.substring(6, timestamp.length - 2));
          print(unixTimestamp);
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp);
          return {
            "date": dateTime,
            "value": e['ECGBpm'],
            "Checkin_id": e['Checkin_id'],
            "leadmode": e['leadmode'],
            'status': e['ECGStatus'],
            "kiosk_info": e["kiosk_info"],
          };
        }).toList();
        print(response.data);
        return ecgList;
      } else if (vitalName.toLowerCase().toString().contains('bp')) {
        List<dynamic> bpList = [];
        print(response.data);
        List<dynamic> jsonData = response.data['status'];
        bpList = jsonData.map((data) {
          String timestamp = data['Timestamp'];
          int unixTimestamp = int.parse(timestamp.substring(6, timestamp.length - 2));
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp);
          return {
            "date": dateTime,
            "value": data["systolic"].toString() + "/" + data["diastlotic"].toString(),
            "kiosk_info": data["kiosk_info"],
            "status": data[vitalName.trim() + "_class"]
          };
        }).toList();
        return bpList ?? [];
      } else {
        List<dynamic> jsonData = response.data['status'];
        List<dynamic> modifiedData = jsonData.map((data) {
          String timestamp = data['Timestamp'];
          int unixTimestamp = int.parse(timestamp.substring(6, timestamp.length - 2));
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp);
          dynamic value;
          String status =
              vitalName=="waist hip"?data["waist_hip_class"]: vitalName == "weight" ? data["bmi_class"] : data["${vitalName.trim()}_class"];
          if (data != null) {
            if (vitalName == "pulse" && data.containsKey('pulse_bpm')) {
              value = double.parse(data['pulse_bpm'].toStringAsFixed(2));
            } else if (vitalName == "vf" ||
                vitalName == "ECG" ||
                vitalName == "bmr" ||
                vitalName == "spo2") {
              value = data[vitalName].toStringAsFixed(0);
            }
            else if(vitalName=="waist hip"){
              value = double.parse(data["waist_hip"].toStringAsFixed(2));
            }
            else {
              value = double.parse(data[vitalName].toStringAsFixed(2));
            }
          }

          return {
            "date": dateTime,
            "value": value,
            "kiosk_info": data["kiosk_info"],
            "status": status
          };
        }).toList();
        return modifiedData ?? [];
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  getEcgGraph(String checkinid) async {
    try {
      var response = await dio.get(
        API.iHLUrl + '/platformservice/get_ecg_data',
        queryParameters: {
          'checkin_id': checkinid,
        },
      );
      return response.data['status'];
    } catch (e) {
      print(e);
    }
  }
}
