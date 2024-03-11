import 'package:flutter/material.dart';

class HomeDashBoard extends StatefulWidget {
  final bool introDone;
  static const String id = 'home_dashboard';
  HomeDashBoard({Key key, this.introDone}) : super(key: key);

  @override
  _HomeDashBoardState createState() => _HomeDashBoardState();
}

class _HomeDashBoardState extends State<HomeDashBoard> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: Text('data'),
    ));
  }
}
