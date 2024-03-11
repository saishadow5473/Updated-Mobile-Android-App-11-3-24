import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OfflineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Lottie.asset(
              'assets/icons/offline.json',
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 150
                      : 250,
            ),
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          Center(
            child: Text(
              'No Internet Connection!\nPlease Connect to resume',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(padding: EdgeInsets.all(5.0)),
        ],
      ),
    );
  }
}
