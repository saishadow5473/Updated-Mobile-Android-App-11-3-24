import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'selectedProgramDashboard.dart';

class SelectedprogramState {
  final List programSelected;
  final String selectedProgram;
  final Map storeData;

  SelectedprogramState({@required this.storeData, this.selectedProgram, this.programSelected});

  String get program => selectedProgram;
  List get programList {
    return programSelected ?? [];
  }

  Map get storedData => storeData ?? {};
}

abstract class SelectedDashboardState extends Equatable {}

class ProgramLoadingState extends SelectedDashboardState {
  @override
  List<Object> get props => [];
}

class ProgramLoadedState extends SelectedDashboardState {
  final GetUserSelectedDashboard _getUserSelectedDashboard;

  ProgramLoadedState(this._getUserSelectedDashboard);

  @override
  List<Map<String, dynamic>> get props {
    if (_getUserSelectedDashboard.status == "success") {
      return [_getUserSelectedDashboard.data[0].content];
    } else {
      return [
        {
          "Manage Health": [
            "Vitals",
            "Calorie Tracker"
          ],
          "Online Services": ["Teleconsultations", "Online Class"],
          "Health Program": ["Heart Health"],
          "Social": ["Health Challenge","Health Tips"],
        }
      ];
    }
  }

  List<String> get listOfPrograms {
    if (_getUserSelectedDashboard.status == "success") {
      Map<String, dynamic> temp = _getUserSelectedDashboard.data[0].content;
      List<String> list = <String>['Home'];
      temp.forEach((String key, value) {
        value.removeWhere((ele) =>
            ele == "My Vitals" ||
            ele == "Step Tracker" ||
            ele == "Health Journal" ||
            ele == "Set Your Goals" ||
            ele == "Weight Management" ||
            ele == "Hpod Locations" ||
            ele == "hPod Locations" ||
            ele == "News Letter" ||
            ele == "Ask IHL");
        value.forEach((ele) => list.add(ele));
      });
      return list;
    } else {
      return <String>[
        'Home',
        'Health Challenge',
        'Calorie Tracker',
        'Health Tips',
        'Teleconsultations',
        'Online Class',
        'Heart Health',
        'Vitals',
      ];
    }
  }
}

class ProgramErrorState extends SelectedDashboardState {
  final String error;

  ProgramErrorState(this.error);

  @override
  List<Object> get props => [error];
}

abstract class ButtonState extends Equatable {}

class ButtonInitialState extends ButtonState {
  ButtonInitialState({this.fetchType});
  final String fetchType;
  @override
  // TODO: implement props
  List<Object> get props => [fetchType];
}

class ButtonLoadingState extends ButtonState {
  @override
  // TODO: implement props
  List<Object> get props => ["true"];
}

class ButtonLoadedState extends ButtonState {
  final String response;

  ButtonLoadedState(this.response);

  @override
  List<Object> get props => [response];
}

class ButtonWarningState extends ButtonState {
  @override
  // TODO: implement props
  List<Object> get props => [false];
}

class ButtonErrorState extends ButtonState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}
