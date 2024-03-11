import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ProgramEvent{}

class SelectProgramEvent extends ProgramEvent{
  SelectProgramEvent({this.selecetedProgram,this.subPrograms});
  final String selecetedProgram;
  final String subPrograms;
}
class UnSelectProgramEvent extends ProgramEvent{
  UnSelectProgramEvent({this.unselecetedProgram,this.removedSubProgram});
  final String unselecetedProgram;
  final String removedSubProgram;
}
abstract class ButtonEvent extends Equatable{

}
class ButtonInitialEvent extends ButtonEvent{
  ButtonInitialEvent();


  @override
  // TODO: implement props
  List<Object> get props => [];
}
class ButtonPressedEvent extends ButtonEvent{
  ButtonPressedEvent({this.storeData});
  final Map storeData;

  @override
  // TODO: implement props
  List<Object>  get props => [storeData];
}
class ButtonWarningEvent extends ButtonEvent{
  ButtonWarningEvent();

  @override
  // TODO: implement props
  List<Object> get props => [false];
}


@immutable
abstract class DashboardEvent extends Equatable {

}

class LoadDashboardEvent extends DashboardEvent {

  @override
  List<Object> get props => [];


}
