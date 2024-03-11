import 'package:flutter/material.dart';

import '../../../Modules/online_class/data/model/getClassSpecalityModel.dart';
import '../../../Modules/searchbloc.dart';

class SearchBarWidget extends StatefulWidget {
  final SearchBloc searchBloc;
  final List<dynamic> specList;

  SearchBarWidget({this.searchBloc, this.specList});

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: PhysicalModel(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        elevation: 2.0,
        child: TextField(
          onChanged: (query) {
            widget.searchBloc.setSearchQuery(query);
          },
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              hintText: 'Search by specialities',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ),
    );
  }
}
