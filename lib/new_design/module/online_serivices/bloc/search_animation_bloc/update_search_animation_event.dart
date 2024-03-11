import 'package:flutter/material.dart';

class SearchAnimationEvent{}

class UpdateSearchAnimationEvent extends SearchAnimationEvent{
  String updatedSearchString;
  UpdateSearchAnimationEvent({this.updatedSearchString});
}

class SelectSpecEvent{

}

class UpdatedSpecSelectedEvent extends SelectSpecEvent{
  String selectedString;
  String selectedAffi;
  String searchString;
  UpdatedSpecSelectedEvent({@required this.searchString,this.selectedString,this.selectedAffi});
}