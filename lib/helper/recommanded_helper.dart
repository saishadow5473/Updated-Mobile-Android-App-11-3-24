// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/CrossbarUtil.dart';

class RecommandedHealper {
  spliter(Map res) {
    List types = res['consult_type'];
    List type1 = [];
    List type2 = [];
    List type3 = [];
    List spec = [];
    List recommended = [];
    // List type4 = [];
    for (int i = 0; i < types.length; i++) {
      String type = types[i]['consultation_type_name'];
      spec.clear();
      spec = types[i]['specality'];

      if (type == "Medical Consultation") {
        for (int j = 0; j < spec.length; j++) {
          if (spec[j]['consultant_list'].length != 0) {
            for (int k = 0; k < spec[j]['consultant_list'].length; k++) {
              type1.add(spec[j]['consultant_list'][k]);
            }
          }
        }
      }
      // if (type == "Fitness Class") {
      //   type2.add(types[i]);
      // }
      if (type == "Health Consultation") {
        for (int j = 0; j < spec.length; j++) {
          if (spec[j]['consultant_list'].length != 0) {
            for (int k = 0; k < spec[j]['consultant_list'].length; k++) {
              type2.add(spec[j]['consultant_list'][k]);
            }
          }
        }
      }
      if (type == "Alternative Theraphy") {
        for (int j = 0; j < spec.length; j++) {
          if (spec[j]['consultant_list'].length != 0) {
            for (int k = 0; k < spec[j]['consultant_list'].length; k++) {
              type3.add(spec[j]['consultant_list'][k]);
            }
          }
        }
      }
    }
    for (int i = 0; i < type1.length; i++) {
      type1[i]['recommended'] != null ? recommended.add(type1[i]) : print('nothing to show');
    }
    for (int i = 0; i < type2.length; i++) {
      type2[i]['recommended'] != null ? recommended.add(type2[i]) : print('nothing to show');
    }
    for (int i = 0; i < type3.length; i++) {
      type3[i]['recommended'] != null ? recommended.add(type3[i]) : print('nothing to show');
    }
    return recommended;
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
  void update(Map doctor) async {
    if (session1 != null) {
      session1.close();
    }
    connect();
    var doctorId = doctor['ihl_consultant_id'];
    session1 = await client.connect().first;
    try {
      final subscription = await session1.subscribe('ihl_update_doctor_status_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var docStatus = data['data']['status'];
        if (data['sender_id'] == doctorId) {
          // if (this.mounted) {
          // setState(() {
          status = docStatus;
          doctor['availabilityStatus'] = docStatus;
          // });
          // }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }
}
