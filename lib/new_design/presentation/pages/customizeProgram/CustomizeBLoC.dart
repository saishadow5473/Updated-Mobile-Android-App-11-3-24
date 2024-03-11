import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/providers/network/apis/selectedProgramApi.dart';
import 'customizeProgramEvnet.dart';
import 'customizeProgramState.dart';
import 'selectedProgramDashboard.dart';

class SelectedProgramBloc extends Bloc<ProgramEvent, SelectedprogramState> {
  final List<String> fetchedPrograms;

  final Map storeData;
  SelectedProgramBloc({this.fetchedPrograms, this.storeData})
      : super(SelectedprogramState(programSelected: fetchedPrograms, storeData: storeData)) {
    on<ProgramEvent>(mapEventToState);
  }
  String selectedProgram = " ";
  Map<String, List> availPrograms = {
    "Manage Health": [],
    "Online Services": [],
    "Health Program": [],
    "Social": []
  };
  List programSelected = [];

  void mapEventToState(ProgramEvent event, Emitter<SelectedprogramState> emit) async {
    programSelected = fetchedPrograms ?? [];
    storeData.forEach((key, value) {
      availPrograms[key] = value;
    });

    if (event is SelectProgramEvent) {
      selectedProgram = event.selecetedProgram;
      if (event.subPrograms != null) {
        programSelected.add(event.subPrograms);
        availPrograms[selectedProgram].add(event.subPrograms);
      }

      /// emiting the state after a program is selected
      emit(getProgram());
    } else if (event is UnSelectProgramEvent) {
      selectedProgram = event.unselecetedProgram;
      programSelected.remove(event.removedSubProgram);
      availPrograms[selectedProgram].remove(event.removedSubProgram);
      if (event.removedSubProgram == null) {
        selectedProgram = "";
      }

      /// emiting the state after a program is unselected
      emit(getProgram());
    }
  }

  /// return the map and program lists of selected.
  SelectedprogramState getProgram() {
    return SelectedprogramState(
        selectedProgram: selectedProgram,
        programSelected: programSelected,
        storeData: availPrograms);
  }
}

///bloc for fetching the selected program
class FetchSelectedProgramBloc extends Bloc<DashboardEvent, SelectedDashboardState> {
  final SelectedDashboard _selectedDasboard;
  FetchSelectedProgramBloc(this._selectedDasboard) : super(ProgramLoadingState()) {
    ///initial state
    on<LoadDashboardEvent>((LoadDashboardEvent event, Emitter<SelectedDashboardState> emit) async {
      /// indicating UI that the data is loading
      GetUserSelectedDashboard dashboardProgram;
      final GetStorage box = GetStorage();
      dynamic tempData = box.read('program');
      GetUserSelectedDashboard prevData;
      if (tempData is! Map) {
        prevData = box.read('program');
      }
      try {
        ///api call to fetch the selected program
        // Check if the data is null
        if (prevData == null) {
          emit(ProgramLoadingState());
          // Get the data from the server
          dashboardProgram = await _selectedDasboard.getSelectedPrograms();
          box.write('program', dashboardProgram);
          emit(ProgramLoadedState(dashboardProgram));
        } else {
          // Get the data from the box
          prevData = box.read('program') as GetUserSelectedDashboard;
          dashboardProgram = prevData;
          emit(ProgramLoadedState(dashboardProgram));
          // Get the data from the server
          dashboardProgram = await _selectedDasboard.getSelectedPrograms();
          box.write('program', dashboardProgram);
        }

        /// indicating UI that the data is loaded
      } catch (e) {
        /// indicating UI that the data is not loaded
        emit(ProgramErrorState(e.toString()));
      }
    });
  }
}

///bloc for the button stages and api call to store data
class ButtonBloc extends Bloc<ButtonEvent, ButtonState> {
  ButtonBloc() : super(ButtonInitialState()) {
    ///initial State
    on<ButtonEvent>((ButtonEvent event, Emitter<ButtonState> emit) async {
      if (event is ButtonPressedEvent) {
        if (event.storeData != null) {
          /// indicating UI that the data is loading
          emit(ButtonLoadingState());
          try {
            /// api call to store the selected program data
            var response = await SelectedDashboard().postSelectedPrograms(event.storeData);

            /// indicating UI that the data is loaded
            emit(ButtonLoadedState(response));
          } catch (e) {
            print(e);
            emit(ButtonErrorState());
          }
        } else {
          emit(ButtonErrorState());
        }
      } else if (event is ButtonWarningEvent) {
        emit(ButtonWarningState());
      }
      // else{
      //   emit(ButtonInitialState(fetchType: "completed"));
      // }
      // emit(ButtonLoadedState("Success"));
    });
  }
}
