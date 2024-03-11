import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ihl/constants/api.dart';
import 'package:ihl/views/marathon/marathon_details.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class MarathonEventApi{
http.Client _client = http.Client(); //3gb

Future<Map> isUserEnrolledApi({ihl_user_id, event_id}) async {
  var finalOutput;
  try {
    // var request = http.Request('GET', Uri.parse(API.iHLUrl+'/consult/user_enrolled?ihl_user_id=T7rJ6xjlXk2sXLEjTJkxIA&event_id=123'));
    var response = await _client.get(
      Uri.parse(API.iHLUrl +
          '/consult/user_enrolled?ihl_user_id=$ihl_user_id&event_id=$event_id'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      finalOutput = await json.decode(response.body);
      return finalOutput;
    } else {
      print(response.reasonPhrase);
      return finalOutput;
    }
  } catch (e) {
    print(e.toString());
    return finalOutput;
  }
}

Future<List> eventDetailApi() async {
  var finalOutput;
  try {
    // var request = http.Request('GET', Uri.parse(API.iHLUrl+'/consult/user_enrolled?ihl_user_id=T7rJ6xjlXk2sXLEjTJkxIA&event_id=123'));
    var response = await _client.get(
      Uri.parse(API.iHLUrl + '/consult/event_details'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );

    // final response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      // finalOutput = await json.decode(response.body);
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString2 = parsedString.replaceAll("\\\\\\", "");
      // var parsedString2 = parsedString.replaceAll("", "");
      var parsedString3 = parsedString2.replaceAll("\\", "");
      // var parsedString3 = parsedString2.replaceAll("", "");
      var parsedString4 = parsedString3.replaceAll(";", "");
      var parsedString5 = parsedString4.replaceAll('""', '"');
      var parsedString6 = parsedString5.replaceAll('"[', '[');
      var parsedString7 = parsedString6.replaceAll(']"', ']');
      var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
      var pasrseString9 = pasrseString8.replaceAll('"{', '{');
      var parseString10 = pasrseString9.replaceAll('}"', '}');
      var parseString11 = parseString10.replaceAll('System.String[]', '');
      // var parseString12 = parseString11.replaceAll('/"', '/');
      var parseString12 = parseString11.replaceAll('', '');
      var parsedString13 = parseString12.replaceAll("rn", "");
      var parsedString14 = parsedString13.replaceAll(': ",', ': "",');
      var parsedString15 = parsedString14.replaceAll('nttt', '');
      var parsedString16 = parsedString15.replaceAll('{nt', '{');
      var parsedString17 = parsedString16.replaceAll('ntt', '');
      var parsedString18 = parsedString17.replaceAll('nt]n', ']');
      var parsedString19 = parsedString18.replaceAll('}}', '}');
      var parsedString20 = parsedString19.replaceAll('[nt', '[');
      var parsedString21 = parsedString20.replaceAll(',n', ',');
      var parsedString22 = parsedString21.replaceAll('ttt', '');
      var parsedString23 = parsedString22.replaceAll('}n]', '}]');
      // var p = parsedString14.replaceAll('"goal_sub_type": "', '"goal_sub_type": ""');
      ///;,nttt    {nt"
      // var parsedString17 = parsedString16.replaceAll(':",', ':"",');
      finalOutput = json.decode(parsedString23);

      return finalOutput;

      // return finalOutput;
    } else {
      print(response.reasonPhrase);
      return finalOutput;
    }
  } catch (e) {
    print(e.toString());
    return finalOutput;
  }
}

trackProgressApi(
    {event_id,
    ihl_user_id,
    steps,
    distance_covered,
    event_status,
    start_time,
    progress_time}) async {
  print(
      '===========,.,.,.,.,.,<>>><><><<><>///////////////    ' + event_status);
  distance_covered = double.parse(distance_covered);
  //here we can check if event status is complete or stop
  ///then => add this two params
  ///    "closed_time_by_user":"2021-12-18 01:30:20",
  ///     "variant_covered_selected_by_user":"7 km"
  var closed_time_by_user = DateTime.now();
  var variant_covered_selected_by_user = '';
  if (event_status == 'stop' || event_status == 'complete') {
    closed_time_by_user = DateTime.now();
    //total distance , and covered distance and total Variants
    if (event_status == 'complete')
      variant_covered_selected_by_user = totalDistance.toString() + ' Km';
    if (distance_covered >= totalDistance) {
      variant_covered_selected_by_user = totalDistance.toString() + ' Km';
    } else {
      var availableVariant;
      variantsList.forEach((element) {
        if (element < totalDistance && distance_covered >= element) {
          variant_covered_selected_by_user = element.toString() + ' Km';
        }
      });
      if (variant_covered_selected_by_user == '') {
        variant_covered_selected_by_user = distance_covered.toString() + ' Km';
      }
    }
  }
  final DateFormat fff = DateFormat('yyyy-MM-dd HH:mm:ss');
  // final DateFormat fff = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
  final String fmt = fff.format(closed_time_by_user);
  var dateTime = fff.format(closed_time_by_user);
  String completed_time =
      DateFormat('hh:mm a').format(DateTime.parse(fmt.toString()));
  print('===========,@@@@@@@@@@@@@@@@@@@@@@@@   ' + completed_time);

  var finalOutput;
  try {
    // var request = http.Request('GET', Uri.parse(API.iHLUrl+'/consult/user_enrolled?ihl_user_id=T7rJ6xjlXk2sXLEjTJkxIA&event_id=123'));
    var response =
        await _client.post(Uri.parse(API.iHLUrl + '/consult/store_steps'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: json.encode({
              "event_id": event_id.toString(), //"event_id_0001",
              "ihl_user_id": ihl_user_id.toString(), //"T7rJ6xjlXk2sXLEjTJkxIA",
              "steps": steps.toString(), //"300",
              "distance_covered": distance_covered.toString(), //"",
              "event_status": event_status.toString(), //"started",
              "start_time": start_time.toString(), //"2021-12-18 05:30:20",
              "progress_time": progress_time.toString(), //"2021-12-18 05:30:20"
              "closed_time_by_user": fmt.toString(),
              "variant_covered_selected_by_user":
                  variant_covered_selected_by_user
            }));
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      // finalOutput = await json.decode(response.body);
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString2 = parsedString.replaceAll("\\\\\\", "");
      // var parsedString2 = parsedString.replaceAll("", "");
      var parsedString3 = parsedString2.replaceAll("\\", "");
      // var parsedString3 = parsedString2.replaceAll("", "");
      var parsedString4 = parsedString3.replaceAll(";", "");
      var parsedString5 = parsedString4.replaceAll('""', '"');
      var parsedString6 = parsedString5.replaceAll('"[', '[');
      var parsedString7 = parsedString6.replaceAll(']"', ']');
      var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
      var pasrseString9 = pasrseString8.replaceAll('"{', '{');
      var parseString10 = pasrseString9.replaceAll('}"', '}');
      var parseString11 = parseString10.replaceAll('System.String[]', '');
      // var parseString12 = parseString11.replaceAll('/"', '/');
      var parseString12 = parseString11.replaceAll('', '');
      var parsedString13 = parseString12.replaceAll("rn", "");
      var parsedString14 = parsedString13.replaceAll(': ",', ': "",');
      var parsedString15 = parsedString14.replaceAll('nttt', '');
      var parsedString16 = parsedString15.replaceAll('{nt', '{');
      var parsedString17 = parsedString16.replaceAll('ntt', '');
      var parsedString18 = parsedString17.replaceAll('nt]n', ']');
      var parsedString19 = parsedString18.replaceAll('}}', '}');
      var parsedString20 = parsedString19.replaceAll('[nt', '[');
      var parsedString21 = parsedString20.replaceAll(',n', ',');
      var parsedString22 = parsedString21.replaceAll('ttt', '');
      var parsedString23 = parsedString22.replaceAll('}n]', '}]');
      // var p = parsedString14.replaceAll('"goal_sub_type": "', '"goal_sub_type": ""');
      ///;,nttt    {nt"
      // var parsedString17 = parsedString16.replaceAll(':",', ':"",');
      finalOutput = json.decode(parsedString23);
      print(finalOutput);
      return finalOutput;
      // return finalOutput;
    } else {
      print(response.reasonPhrase);
      print(finalOutput);
      return finalOutput;
    }
  } catch (e) {
    print(e.toString());
    print(finalOutput);
    return finalOutput;
  }
}

Future<String> marathonRegisterUser(
    {varientSelected,
    eventName,
    locationSelected,
    usingIhlapp,
    userName,
    age,
    gender,
    organization,
    otherSource,
    employeeId,
    eventId,
    varientId,
    pathCount,
    eventStatus}) async {
  SharedPreferences prefs1 = await SharedPreferences.getInstance();
  var data1 = prefs1.get('data');
  Map res = jsonDecode(data1);
  var iHLUserId = res['User']['id'];
  print(res);
  final registerUserResponse =
      await _client.post(Uri.parse(API.iHLUrl + '/consult/enroll_user'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, String>{
            // 'ihl_user_id': iHLUserId,
            // 'ihl_user_name': 'user3',
            // 'status': 'requested',
            // 'vital_read': 'false',
            // 'vital_write': 'false',
            // 'teleconsult_read': 'false',
            // 'teleconsult_write': 'false',
            "ihl_user_id": iHLUserId,
            "varient_selected": "$varientSelected",
            "event_name": "$eventName",
            "location_selected": "$locationSelected",
            "using_ihlapp": "$usingIhlapp",
            "user_name": "$userName",
            "age": "$age",
            "gender": "$gender",
            "organization": "$organization",
            "other_source": "$otherSource",
            "employee_id": "$employeeId",
            "event_id": "$eventId",
            "varient_id": "$varientId",
            "path_count": "$pathCount",
            "event_status": "$eventStatus"
          }));
  if (registerUserResponse.statusCode == 200) {
    if (registerUserResponse.body != null) {
      print(registerUserResponse.body);
    }
  }
  return registerUserResponse.body;
}

// var request = http.MultipartRequest('POST', uri);
// for (int i = 0; i < f.length; i++) {
// request.files.add(
// await http.MultipartFile.fromPath(
// 'attachments$i',
// f[i].path,
// filename: f[i].path,
// ),
// );
// }

Future uploadImagesAfterEvent(
    String ihlUserId, String eventId, String path, source,
    {image_list}) async {
  // print(image_list.length);
  print('uploadDocuments apicalll');
  var request;
  if (source == 'camera') {
    request = http.MultipartRequest(
      'POST',
      Uri.parse(API.iHLUrl + '/consult/upload_event_documents'),
    );
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'data',
        path,
        filename: 'path$path',
      ),
    );
    request.fields.addAll(await {
      "ihl_user_id": "$ihlUserId",
      "event_id": "$eventId",
    });
  } else {
    request = http.MultipartRequest(
      'POST',
      Uri.parse(API.iHLUrl + '/consult/upload_event_documents'),
    );
    for (int i = 0; i < image_list.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'data$i',
          image_list[i].path,
          filename: 'path${image_list[i].path}',
        ),
      );
    }
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    request.fields.addAll(await {
      "ihl_user_id": "$ihlUserId",
      "event_id": "$eventId",
    });
  }
  var res = await request.send();

  if (res.statusCode == 200) {
    print('success api ++');
    // print(res.body);
    var uploadResponse = await res.stream.bytesToString();
    print(uploadResponse);
    final finalOutput = json.decode(uploadResponse);
    print(finalOutput['status']);
    if (finalOutput['status'] == 'pictures uploaded successfully') {
      // Navigator.of(context).pop();
      //snackbar
      return true;
    } else {
      var uploadResponse = await res.stream.bytesToString();
      print('$uploadResponse');
      return false;
    }
  } else {
    print('failed => ${res.statusCode}');
    var uploadResponse = await res.stream.bytesToString();
    print('$uploadResponse');
    return false;
  }
}
