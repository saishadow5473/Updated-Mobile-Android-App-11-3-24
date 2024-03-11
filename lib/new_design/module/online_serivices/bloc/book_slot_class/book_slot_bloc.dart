import 'package:flutter_bloc/flutter_bloc.dart';

class SlotButtonEvent {}

class SlotButtonSelectionEvent extends SlotButtonEvent {
  String slotTime;
  List<String> timeSlotList;
  SlotButtonSelectionEvent({this.slotTime,this.timeSlotList});
}

class SlotButtonUnSelectionEvent extends SlotButtonEvent {
  String slotTime;
  SlotButtonUnSelectionEvent({this.slotTime});
}

class SlotButtonState {}

class SlotButtonSelectedState extends SlotButtonState {
  String slotTime;
  List<String> timeSlotList;
  SlotButtonSelectedState({this.slotTime,this.timeSlotList});
}

class SlotButtonUnSelectedState extends SlotButtonState {
  String slotTime;
  SlotButtonUnSelectedState({this.slotTime});
}

class SelectSlotButtonBloc extends Bloc<SlotButtonEvent, SlotButtonState> {
  SelectSlotButtonBloc() : super(SlotButtonState()) {
    on<SlotButtonEvent>(mapEventToState);
  }
  void mapEventToState(SlotButtonEvent event, Emitter<SlotButtonState> emit) {
    if (event is SlotButtonSelectionEvent) {
      emit(SlotButtonSelectedState(timeSlotList:event.timeSlotList,slotTime: event.slotTime));
    } else if (event is SlotButtonUnSelectionEvent) {
      emit(SlotButtonUnSelectedState(slotTime: event.slotTime));
    }
  }
}
class ConfimrButtonEvent{

}
class ConfirmButtonApiCallEvnet extends ConfimrButtonEvent{

}
class ConfirmButtonApiResponse extends ConfimrButtonEvent{
  String apiResponse;
  ConfirmButtonApiResponse({this.apiResponse});
}
class ConfirmButtonState{}
class ConfirmButtonLoadedState extends ConfirmButtonState{
  String apiResponse;
  ConfirmButtonLoadedState({this.apiResponse});
}
class ConfimrButtonInitialState extends ConfirmButtonState{

}
class ConfirmSubscriptionBloc extends Bloc<ConfimrButtonEvent,ConfirmButtonState>{
  ConfirmSubscriptionBloc() : super(ConfirmButtonState()) {
    on<ConfimrButtonEvent>(mapEventToState);
  }
  mapEventToState(ConfimrButtonEvent event, Emitter<ConfirmButtonState> emit){
    if(event is ConfirmButtonApiResponse){
      emit(ConfirmButtonLoadedState(apiResponse:event.apiResponse));
    }
    else{
      emit(ConfimrButtonInitialState());
    }
  }
}