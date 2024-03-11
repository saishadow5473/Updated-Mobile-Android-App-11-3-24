import 'package:flutter/material.dart';

class Details2 extends StatelessWidget {
  final duration;
  final from;
  final mode;
  final dateTime;
  final consultCharges;
  final paymentMode;


  Details2({this.duration, this.from, this.mode, this.dateTime, this.consultCharges, this.paymentMode});
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Duration" + ":" + duration, style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
          Text("From" + ":" + "IHL User Portal", style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
          Text("Mode" + ":" + "Video Consultation", style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
          Text("Date & Time" + ":" + dateTime, style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
          Text("Consultation Charges" + ":" + consultCharges, style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
          Text("Payment Mode" + ":" + paymentMode, style: TextStyle(height: 2),
            textAlign: TextAlign.justify,),
        ]
    );
  }
}