part of 'trainer_bloc.dart';

class TrainerAvailabilityState {}

class InitialTrainerState extends TrainerAvailabilityState {}

class UpdatedTrainerState extends TrainerAvailabilityState {
  final bool isOnline;

  UpdatedTrainerState(this.isOnline);
}

class StatusError extends TrainerAvailabilityState {
  final String error;

  StatusError(this.error);
}
