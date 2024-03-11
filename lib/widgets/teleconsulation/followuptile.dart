import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';

/// FollowUp Tile 😁😁
class FollowUpTile extends StatelessWidget {
  String name;
  String date;
  String fees;
  FollowUpTile({Key key, this.date, this.fees, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            /*Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                 FontAwesomeIcons.video,
                color: AppColors.startConsult,
              ),
            ),*/
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString(),
                    ),
                    Text(date.toString()),
                    Text(fees.toString())
                  ],
                ),
              ),
            ),
            TextButton(
              child: Text('Book'),
              style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              textStyle: TextStyle(color:Colors.white),),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
