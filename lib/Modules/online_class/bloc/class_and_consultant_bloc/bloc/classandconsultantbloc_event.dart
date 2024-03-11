part of 'classandconsultantbloc_bloc.dart';

class ClassandconsultantblocEvent {}

class GetClassandConsultantEvent extends ClassandconsultantblocEvent {
  String category;
  GetClassandConsultantEvent(this.category);
}

class GetClassandConsPaginationEvent extends ClassandconsultantblocEvent {
  String category;
  ClassAndConsultantListModel data;
  GetClassandConsPaginationEvent(this.category, this.data);
}
