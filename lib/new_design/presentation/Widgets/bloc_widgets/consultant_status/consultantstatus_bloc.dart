import 'package:bloc/bloc.dart';

part 'consultantstatus_event.dart';
part 'consultantstatus_state.dart';

class ConsultantstatusBloc extends Bloc<ConsultantstatusEvent, ConsultantstatusState> {
  ConsultantstatusBloc() : super(InitialConsultantsState()) {
    on<ConsultantstatusEvent>(fetchConsultantStatus);
  }
  fetchConsultantStatus(ConsultantstatusEvent event, Emitter<ConsultantstatusState> emit) {
    if (event is ListenConsultantStatusEvent) {
      try {
        emit(UpdatedConsultantsState(event.isOnline,event.id));
      } catch (e) {
        emit(StatusError('Failed to listen to status changes: $e'));
      }
    } else {
      emit(InitialConsultantsState());
    }
  }
}
