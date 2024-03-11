import 'dart:async';

class SearchBloc {
  final _searchQueryController = StreamController<String>();

  Stream<String> get searchQuery => _searchQueryController.stream;

  void setSearchQuery(String query) {
    _searchQueryController.sink.add(query);
  }

  void dispose() {
    _searchQueryController.close();
  }
}
