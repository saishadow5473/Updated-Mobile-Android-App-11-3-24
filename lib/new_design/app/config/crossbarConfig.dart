// ignore_for_file: file_names

import 'dart:async';

import 'package:get/get.dart';
import '../../data/providers/network/api_provider.dart';

class CrossBarConnect extends GetxController {
  RxString status = 'Offline'.obs;
  StreamSubscription stream;
  consultantStatus(String doctorID) async {
    try {
      stream ??= FireStoreCollections.consultantOnlineStatus
          .doc(doctorID)
          .snapshots()
          .listen((dynamic event) {
        if (event.exists) {
          Map<String, dynamic> data = event.data() as Map<String, dynamic>;
          if (data != null) {
            status.value = data['status'];
          }
        } else {
          FireStoreCollections.consultantOnlineStatus
              .doc(doctorID)
              .set(<String, dynamic>{'consultantId': doctorID, 'status': "Offline"});
        }
        print(status.value);
      });
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}
// //old crossbar integrated ✅
// import 'package:connectanum/connectanum.dart';
// import 'package:connectanum/json.dart';
// import 'package:get/get.dart';
// import '../../data/providers/network/api_provider.dart';

// import '../../presentation/controllers/dashboardControllers/ststusCheckController.dart';

// class CrossBarConnect extends GetxController {
//   // void onInit() {
//   //   consultantStatus(String doctorID)
//   //   super.onInit();
//   // }
//   Client clientInit;
//   void connectInit() async {
//     clientInit = Client(
//         realm: 'crossbardemo',
//         transport: WebSocketTransport(
//           API.crossbarUrl,
//           Serializer(),
//           WebSocketSerialization.SERIALIZATION_JSON,
//         ));
//   }

//   RxString status = 'Offline'.obs;
//   Session session1Init;
//   consultantStatus(String doctorID) async {
//     // if (session1 != null) {
//     //   session1.close();
//     // }
//     connectInit();
//     session1Init = await clientInit
//         .connect(
//             options: ClientConnectOptions(
//                 reconnectCount: 10, reconnectTime: Duration(milliseconds: 200)))
//         .first;
//     print(session1Init);
//     try {
//       final subscription = await session1Init.subscribe('ihl_update_doctor_status_channel',
//           options: SubscribeOptions(get_retained: true));
//       // CrossBarConnect().statusCheck(doctorID);
//       subscription.eventStream.listen((event) {
//         Map data = event.arguments[0];
//         var docStatus = data['data']['status'];
//         if (data['sender_id'] == doctorID) {
//           status.value = docStatus;
//           StatusController().apiStatus;
//         }
//       });
//     } on Abort catch (abort) {
//       print(abort.message.message);
//     }
//   }
// }
