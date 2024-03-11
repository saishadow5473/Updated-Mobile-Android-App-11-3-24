import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'consultantstatus_bloc.dart';

class GetConsultantStatus {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot> _subscription;
  consultantStatusFromFirebase(s, id) async {
    //003a17e3ba6549789606885463eed4a5
    final DocumentReference<Map<String, dynamic>> userDoc =
        _firestore.collection('testconsultantOnlineStatus').doc(id);
    _subscription = userDoc.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        print(snapshot.data()['status']);
        final trainerBloc = s<ConsultantstatusBloc>();
        trainerBloc
            .add(ListenConsultantStatusEvent(snapshot.data()['status'] == 'Online' ? true : false,id));
      }
    });
  }
}
