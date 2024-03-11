import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/models/appointment_pagination_model.dart';

class RemoteApi {
  http.Client _client = http.Client(); //3gb
  // static const headers = {
  //   'ApiToken':
  //   'pvO5rLjT4t9z+lXfYJ9Qi61hrhVitpeWoGiSi/JDPKXvLeluWa1DbkeBmsmXftLSaGFS0HPV0ogX3OD+28ZOPH2ZJNHCa4te26i5+2oeisABAA==',
  //   'Token':
  //   'hJ+XkQlHfFLvkshHTFDkQFUwf89ScTfhvCXy4yAU0k9IANUtHc263LwCRkX1aO+4q9y29VYCiwxOR7g7V7fwrbJcWTfjR082vE9I3Q8nTeqlQy6e2dTHtCgqdql+IJIbyUJztBbMo06SflBgqorB9Oj8zE2CIOvbkDbuhHfE8zc6Z9XL8o/DTeiA8jerKFt7AQA=',
  //   'Content-Type': 'application/json'
  // };
  static var headers = {
    'Content-Type': 'application/json',
    'ApiToken': '${API.headerr['ApiToken']}',
    'Token': '${API.headerr['Token']}',
  };
  // static Future<List<CharacterSummary>>
  static var endIndex = 10;
  static getCharacterList(pageKey, conultantId, {end_index}) async {
    endIndex = pageKey + 10;
    if (end_index != null) {
      endIndex = end_index;
    }
    http.Client _client1 = http.Client(); //3gb
    final response = await _client1.post(
        Uri.parse(
            // Api.baseUrl+'/consult/view_all_book_appointment_pagination'),
            API.iHLUrl +
                '/consult/view_all_book_appointment_pagination_mobile'),
        headers: headers,
        body: json.encode({
// "consultant_id": "335aad6f96454425b25df675d9786b0a",
          "consultant_id":
              conultantId.toString(), //"38726ba5bfcd42f08189e5e84a4105ca",
          "start_index": "$pageKey",
          // "end_index": "${pageKey+10}"
          "end_index": "$endIndex"
        }));
    try {
      // final response = await this;
      if (response.statusCode == 200) {
        var reasonForVisit = [];
        String value = response.body;

        var lastStartIndex = 0;
        var lastEndIndex = 0;
        var reasonLastEndIndex = 0;
        var alergyLastEndIndex = 0;
        for (int i = 0; i < value.length; i++) {
          if (value.contains("reason_for_visit")) {
            var start = "appointment_id";
            var end = "booked_date_time";
            var startIndex = value.indexOf(start, lastStartIndex);
            var endIndex = value.indexOf(end, lastEndIndex);
            lastStartIndex = value.indexOf(start, startIndex) + start.length;
            lastEndIndex = value.indexOf(end, endIndex) + end.length;
            var reasonStart = "reason_for_visit";
            var reasonEnd = "notes";
            var reasonStartIndex = value.indexOf(
              reasonStart,
            );
            var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
            reasonLastEndIndex =
                value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
            var alergyStart = "alergy";
            var alergyEnd = "appointment_start_time";
            var alergyStartIndex = value.indexOf(alergyStart);
            var alergyEndIndex = value.indexOf(alergyEnd, alergyLastEndIndex);
            alergyLastEndIndex = alergyEndIndex + alergyEnd.length;
            // rest.add(value.substring(startIndex+start.length , endIndex));
            String a = value.substring(startIndex + start.length, endIndex);
            var parseda1 = a.replaceAll('\\&quot', '"');
            var parseda2 = parseda1.replaceAll('\\";:\\";', '');
            var parseda2a = parseda2.replaceAll('&quot;:&quot;', '"');
            var parseda2b = parseda2a.replaceAll('&quot;,&quot;', '"');
            var parseda2c = parseda2b.replaceAll('\"', '');
            var parseda3 = parseda2c.replaceAll('\\";,\\";', '');
            String b = value.substring(
                reasonStartIndex + reasonStart.length, reasonEndIndex);
            var parsedb1 = b.replaceAll('\\&quot', '"');
            var parsedb2 = parsedb1.replaceAll('\\";:\\";', '');
            var parsedb2a = parsedb2.replaceAll('&quot;:&quot;', '"');
            var parsedb2b = parsedb2a.replaceAll('&quot;,&quot;', '"');
            var parsedb2c = parsedb2b.replaceAll('\"', '');
            var parsedb3 = parsedb2c.replaceAll('\\";,\\";', '');
            String c = value.substring(
                alergyStartIndex + alergyStart.length, alergyEndIndex);
            var parsedc1 = c.replaceAll('&quot;', '"');
            var parsedc2 = parsedc1.replaceAll('\\\\",\\\\"', '');
            var parsedc2a = parsedc2.replaceAll('&quot;:&quot;', '"');
            var parsedc2b = parsedc2a.replaceAll('&quot;,&quot;', '"');
            var parsedc2c = parsedc2b.replaceAll('\"', '');
            var parsedc2d = parsedc2c.replaceAll(':', '');
            var parsedc2e = parsedc2d.replaceAll(',', '');
            var parsedc3 = parsedc2e.replaceAll('\\\\":\\\\"', ''); //\":\"\",\"

            Map<String, String> app = {};
            app['appointment_id'] = parseda3;
            app['reason_for_visit'] = parsedb3;
            app["alergy"] = parsedc3;
            reasonForVisit.add(app);
            // print(app);
            // print(value.length);

            var temp1 = value.substring(0, reasonStartIndex);
            var temp2 = value.substring(reasonEndIndex, value.length);
            value = temp1 + temp2;
            temp1 = value.substring(0, alergyStartIndex);
            temp2 = value.substring(alergyEndIndex, value.length);
            value = temp1 + temp2;
          } else {
            i = value.length;
          }
        }
        // var v = jsonEncode(value);
        var b = jsonDecode(value);
        // var v = b.toString();
        // var v = json.encode(b);
        var key = 'fina_json';
        if (b['fina_json'] == null) {
          //TODO b.contains key method and change it to that method instead of this
          key = 'json';
        }
        var parsedString = b['$key'].toString().replaceAll('\\&quot;', '');

        var parsedString2 = parsedString.replaceAll('&quot;', '"');
        var parsedString2a = parsedString2.replaceAll('\\', '');

        // var finalOutput = json.encode(parsedString2a);
        // if(b['json']!=null){
        //  var  jsonparsedString2a = jsonDecode(parsedString2a);
        //  parsedString2a = jsonparsedString2a;
        //  print(jsonparsedString2a);
        // }\
        var finalOutput = parsedString2a;
        var xa = jsonDecode(finalOutput);
        // var y = b['json']!=null?jsonDecode(xa): xa;
        var y = xa;
        //     .where((i) =>
        // // (i['Book_Apointment']["appointment_status"] == "Approved" ||
        // //     i['Book_Apointment']["appointment_status"] == "Approved" ||
        // //     i['Book_Apointment']["appointment_status"] == "Requested" ||
        // //     i['Book_Apointment']["appointment_status"] == "requested") &&
        //     (i['Book_Apointment']["call_status"] != "completed"))
        //     .toList();
        for (int i = 0; i < y.length; i++) {
          if (y[i]['Book_Apointment']['kiosk_checkin_history']
                  .toString()
                  .length >
              5) {
            var ksokValue = await manipulationOfKisokData(
                y[i]['Book_Apointment']['kiosk_checkin_history']);
            y[i]['Book_Apointment']['kiosk_checkin_history'] = ksokValue;
          }
        }
        var encodedY = jsonEncode(y);
        // print(encodedY);finalOutput = {_GrowableList} size = 4
        var modelData = await characterSummaryFromJson(encodedY);
        modelData.removeWhere((element) => element == null);
        // return [modelData,b['status'],reasonForVisit];
        return [y, b['status'], reasonForVisit, finalOutput];
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }

  static manipulateTheJsonStringforCommas(str) {
    String copyStr = str;
    var colon = false;
    var comma = false;
    var jIndex = 0;
    for (int i = 0; i < str.length; i++) {
      if (colon == false) {
        if (str[i] == ',') {
          copyStr = copyStr.replaceRange(jIndex, jIndex + 1, ' ');
        }
      }
      if (str[i] == ':') {
        colon = true;
      }
      if (colon == true) {
        if (str[i] == ',') {
          jIndex = i;
          comma = false;
          colon = false;
        }
      }
    }
    return copyStr;
  }

  static manipulationOfKisokData(strr) async {
    // var aaaa = "{dateTime:2021-10-05T10:02:48.468Z,weightKG:98.88,percent_body_fat:43.91,heightMeters:1.75,systolic:119.0,diastolic:79.0,pulseBpm:72.0,spo2:100.0,temperature:36.6,bmi:32.1761627,bmiClass:obese,bpClass:Normal,spo2Class:Healthy,temperatureClass:Normal}";
    var aaaa = await manipulateTheJsonStringforCommas(strr);
    var splitt = aaaa.split(',');
    splitt.removeWhere((element) => !element.toString().contains(':'));

    ///element. ->  :
    // print(splitt);
    var jsonListForMap = [];
    Map jsonMapOfKisok = {};
    forDateTimeInKisokCheckinHistory(strr) {
      var valuee = '';
      for (int i = 1; i < strr.length; i++) {
        valuee = valuee + '${strr[i]}';
      }
      jsonListForMap.add('"${strr[0]}":"$valuee"');
      jsonMapOfKisok['${strr[0]}'] = "$valuee";
    }

    logic(str) {
      if (str[0] == 'dateTime' || str.length > 2) {
        forDateTimeInKisokCheckinHistory(str);
      } else {
        jsonListForMap.add('"${str[0]}":"${str[1]}"');
        jsonMapOfKisok['${str[0]}'] = "${str[1]}";
      }
    }

    for (int i = 0; i < splitt.length; i++) {
      if (i == 0) {
        var q = splitt[0].replaceFirst('{', '');
        var str = q.split(':');
        logic(str);
      } else if (i == splitt.length - 1) {
        var q = splitt[i].replaceFirst('}', '');
        var str = q.split(':');
        logic(str);
      } else {
        var str = splitt[i].split(':');
        logic(str);
      }
    }
//   print(jsonListForMap);
    String jsonStrForMap =
        jsonListForMap.toString().replaceAll('[', '{').replaceAll(']', '}');
    // print((jsonStrForMap));
    // print(jsonMapOfKisok);
    return jsonMapOfKisok;
    //   print(jsonDecode("{dateTime:2021-10-05T10:02:48.468Z,weightKG:98.88,percent_body_fat:43.91,heightMeters:1.75,systolic:119.0,diastolic:79.0,pulseBpm:72.0,spo2:100.0,temperature:36.6,bmi:32.1761627,bmiClass:obese,bpClass:Normal,spo2Class:Healthy,temperatureClass:Normal}"));
  }
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}
