import 'package:flutter/material.dart';

class ReasonForVisit extends StatelessWidget {
  final reasonforVisit;

  ReasonForVisit({this.reasonforVisit});
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Reason for visit   " + "  :  " + reasonforVisit, style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
        ]
    );
  }
}
