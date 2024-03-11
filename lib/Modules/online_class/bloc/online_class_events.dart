import 'package:equatable/equatable.dart';

class OnlineClassEvent {}

class OnlineClassApiEvent<Api> extends OnlineClassEvent {
  final String data;
  OnlineClassApiEvent({this.data});
}
class StreamOnlineClassEvent {}

class StreamOnlineClassApiEvent<Api> extends StreamOnlineClassEvent {
  final String data;
  StreamOnlineClassApiEvent({this.data});
}
 class SubscriptionFilterEvent{

 }

class FilterSubscriptionEvent extends SubscriptionFilterEvent{
  final String filterType;
  final int endIndex;
  FilterSubscriptionEvent({this.filterType,this.endIndex});
}