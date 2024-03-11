part of 'classandconsultantbloc_bloc.dart';

class ClassandconsultantblocState {}

class ClassandconsultantblocInitial extends ClassandconsultantblocState {}

class ClassandconsultantUpdated extends ClassandconsultantblocState {
  ClassAndConsultantListModel data;
  ClassandconsultantUpdated(this.data);
}

class ClassandconsultantPagination extends ClassandconsultantblocState {
  ClassAndConsultantListModel datas;
  ClassandconsultantPagination(this.datas);
}
