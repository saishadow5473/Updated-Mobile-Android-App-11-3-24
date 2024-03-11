import 'package:flutter/material.dart';

import '../../../../constants/api.dart';
import '../../../../utils/CrossbarUtil.dart';

class FirestoreServices {
  static Future<bool> FirestoreKioskLogin({@required String kiosId}) async {
    Map q = {};
    Map x = {};
    var userId = await getUserID();
    //String dataToFindHashKiosk= '$' + saltKiosk;
    //String decKiosk=encryptAes(kioskCode);
    String decKiosk = decryptAes(kiosId); //decrypting the kiosk ID with web key
    String sessionToken = await getSessionTokenKiosk(userId); // getting session token
    if (sessionToken == "failed" || sessionToken == "") {
      return false;
    }
    String sessionTokenEncrypt = encryptAes(sessionToken); // encrypt sessionToken
    String calculatedHashKiosk = encryptAes(decKiosk); // encrypt kioskId with mobile key
    String calculatedHashUserId = encryptAes(userId);
    x['cmd'] = "loginDetails";
    x['token'] = sessionTokenEncrypt;
    q['sender_id'] = calculatedHashUserId;
    q['sender_session_id'] = session.id;
    q['receiver_ids'] = calculatedHashKiosk;
    q['data'] = x;
    try {
      await FireStoreCollections.kioskServices.doc(kiosId).set(q);
      return true;
    } catch (e) {
      return false;
    }
  }
}
