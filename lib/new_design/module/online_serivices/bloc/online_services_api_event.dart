import 'package:equatable/equatable.dart';

class OnlineServicesEvent {}

class OnlineServicesApiEvent<Api> extends OnlineServicesEvent {
  final String data;
  OnlineServicesApiEvent({this.data});
}
class StreamOnlineServicesEvent {}

class StreamOnlineServicesApiEvent<Api> extends StreamOnlineServicesEvent {
  final String data;
  StreamOnlineServicesApiEvent({this.data});
}
// class SubscriptionFilterEvent{
//
// }
//
// class FilterSubscriptionEvent extends SubscriptionFilterEvent{
//   final String filterType;
//   final int endIndex;
//   FilterSubscriptionEvent({this.filterType,this.endIndex});
// }