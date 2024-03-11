import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc() : super(CoursesInitialState()) {
    on<CoursesEvent>((event, emit) {
      
    });
  }
}
