import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/utils/app_colors.dart';

class ConsultantTile extends StatefulWidget {

  final String name;
  final String appointmentStartTime;
  final String appointmentStatus;
  final bool isCompleted;

  ConsultantTile({this.name, this.appointmentStartTime, this.appointmentStatus, this.isCompleted});

  @override
  _ConsultantTileState createState() => _ConsultantTileState();
}

class _ConsultantTileState extends State<ConsultantTile> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isCompleted ? true : false,
      child: Column(
        children: [
          Card(
            color: AppColors.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FontAwesomeIcons.userMd,
                          color: AppColors.startConsult,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name.toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(widget.appointmentStartTime.toString()),
                              Text("Appointment Completed", style: TextStyle(
                                color: Colors.green
                              ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
