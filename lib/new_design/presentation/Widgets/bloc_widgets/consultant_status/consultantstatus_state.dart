part of 'consultantstatus_bloc.dart';

class ConsultantstatusState {}

class InitialConsultantsState extends ConsultantstatusState {}

class UpdatedConsultantsState extends ConsultantstatusState {
  final bool isOnline;
  final String id;

  UpdatedConsultantsState(this.isOnline,this.id);
}

class StatusError extends ConsultantstatusState {
  final String error;

  StatusError(this.error);
}
