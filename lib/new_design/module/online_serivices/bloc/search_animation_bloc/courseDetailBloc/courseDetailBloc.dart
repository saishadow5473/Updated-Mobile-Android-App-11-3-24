import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../../data/model/get_course_detail.dart';
import '../../../data/repositories/online_services_api.dart';

class CourseDetailEvent {}

class CourseEventTrigger extends CourseDetailEvent {
  String courseID;
  CourseEventTrigger({this.courseID});
}

class CourseDetailState {}

class CourseDetailInitialState extends CourseDetailState {}

class CourseDetailLoadedState extends CourseDetailState {
  GetCourseDetail courseDetail;
  int courseFees;
  CourseDetailLoadedState({this.courseDetail,this.courseFees});
}

class CourseDetailErrorState extends CourseDetailState {
  String courseDetailError;
  CourseDetailErrorState({this.courseDetailError});
}

class CourseDetailBloc extends Bloc<CourseDetailEvent,CourseDetailState>{
  CourseDetailBloc():super(CourseDetailState()){
    on<CourseDetailEvent>(mapToEvent);
  }
  final String selectedAffi = selectedAffiliationfromuniquenameDashboard ?? "global_services";
  final OnlineServicesApiCall _onlineClassApiCall = OnlineServicesApiCall();
  mapToEvent(CourseDetailEvent event, Emitter<CourseDetailState> emit)async{
    emit(CourseDetailInitialState());
    if(event is CourseEventTrigger){
      try {
        GetCourseDetail courseDetail = await _onlineClassApiCall.getCourseDetail(
            courseId: event.courseID);
        var affiprice = 0;
        courseDetail.affilationExcusiveData.affilationArray.forEach((AffilationArray element) {
          if (element.affilationUniqueName == selectedAffi) {
            affiprice = int.parse(element.affilationPrice);
          }
        });
        print(affiprice);
        emit(CourseDetailLoadedState(courseDetail: courseDetail,courseFees: affiprice));
      }
      catch(e){
        print(e);
        emit(CourseDetailErrorState(courseDetailError: "Failed to get course detail: $e"));
      }
    }
  }
}