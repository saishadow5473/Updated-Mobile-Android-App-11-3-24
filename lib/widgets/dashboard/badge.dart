import 'package:flutter/material.dart';
import 'package:ihl/constants/vitalUI.dart';

/// badge on top of card 🔴
class Badge extends StatelessWidget {
  String status;
  Color color;
  Badge({this.status, this.color});
  @override
  Widget build(BuildContext context) {
    if (unhealthyStatuses.contains(status)) {
      return CircleAvatar(
        child: Icon(
          Icons.remove_circle,
          color: color,
        ),
        radius: 12,
        backgroundColor: Colors.white,
      );
    }
    return CircleAvatar(
      child: Icon(
        Icons.check_circle,
        color: color,
      ),
      radius: 12,
      backgroundColor: Colors.white,
    );
  }
}
