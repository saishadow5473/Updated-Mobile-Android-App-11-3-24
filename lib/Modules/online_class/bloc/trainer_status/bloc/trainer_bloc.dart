import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trainer_event.dart';
part 'trainer_state.dart';

class TrainerBloc extends Bloc<TrainerEvent, TrainerAvailabilityState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot> _subscription;

  TrainerBloc() : super(InitialTrainerState()) {
    on<TrainerEvent>(fetchTrainerStatus);
  }
  fetchTrainerStatus(TrainerEvent event, Emitter<TrainerAvailabilityState> emit) {
    if (event is ListenTrainerStatusEvent) {
      try {
        emit(UpdatedTrainerState(event.isOnline));
      } catch (e) {
        emit(StatusError('Failed to listen to status changes: $e'));
      }
    } else {
      emit(InitialTrainerState());
    }
  }
}
