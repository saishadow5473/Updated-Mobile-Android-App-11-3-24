part of 'consultantstatus_bloc.dart';

class ConsultantstatusEvent {}

class ListenConsultantStatusEvent extends ConsultantstatusEvent {
  final bool isOnline;
  final String id;

  ListenConsultantStatusEvent(this.isOnline,this.id);
}
