import '../../data/model/get_spec_class_list.dart';

class SearchAnimationState{
  String searchString;
  SearchAnimationState( {this.searchString});
}

class SelectSpecState{}
class ClassListLoaderState extends SelectSpecState{

}
class UpdateSelectSpecState extends SelectSpecState{
  String selectedSpeCurrent;
  List<SpecialityClassList> classList;
  String onProgressSearch;
  UpdateSelectSpecState({this.selectedSpeCurrent,this.classList,this.onProgressSearch});
}