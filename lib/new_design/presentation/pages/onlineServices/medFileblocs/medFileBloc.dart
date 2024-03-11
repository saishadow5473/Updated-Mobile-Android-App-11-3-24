import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/onlineServices/medFileblocs/medFileEvent.dart';
import 'package:ihl/new_design/presentation/pages/onlineServices/medFileblocs/medFileState.dart';

class MedFileBloc extends Bloc<MedFileEvent, MedFileState> {
  MedFileBloc() : super(MedFileState()) {
    state.selectedDocIdList ??= [];
    on<AddMedFileEvent>((event, emit) {
      ///add functionality of adding Medfile
      emit(MedFileState(selectedDocIdList: state.selectedDocIdList..add(event.docid)));
      // state.selectedDocIdList.add(event.docid);
    });

    on<RemoveMedFileEvent>((event, emit) {
      ///remove functionality of removing Medfile
      emit(MedFileState(selectedDocIdList: state.selectedDocIdList..remove(event.docid)));
      // state.selectedDocIdList.remove(event.docid);
    });
    // on<RefreshEvent>((event, emit) {});
  }
}
