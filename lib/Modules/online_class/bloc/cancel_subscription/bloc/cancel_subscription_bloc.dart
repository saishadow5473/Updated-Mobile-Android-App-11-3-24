import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'cancel_subscription_event.dart';
part 'cancel_subscription_state.dart';

class CancelSubscriptionBloc extends Bloc<CancelSubscriptionEvent, CancelSubscriptionState> {
  CancelSubscriptionBloc() : super(CancelSubscriptionInitial()) {
    on<CancelSubscriptionEvent>((event, emit) {
   
    });
  }
}
