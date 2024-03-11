import 'package:flutter/material.dart';
import 'package:ihl/views/dietDashboard/gain_weight.dart';
import 'package:ihl/views/dietDashboard/lose_weight.dart';
import 'package:ihl/views/dietDashboard/maintain_weight.dart';

class GoalSetting extends StatefulWidget {

  @override
  _GoalSettingState createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Icon(Icons.arrow_back_ios_sharp,color: Colors.black,),
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: Text('What\'s your Goal ?',style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w500),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  side: BorderSide(

                    color: Colors.black,
                    width: 2.0,
                  ),),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20),
                  title: Text('Lose Weight'),
                  subtitle: Text('Lorem ipsum is a placeholder'),
                  onTap: (){
                     Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoseWeight()),
                          );
                  },
                ),
                
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  side: BorderSide(

                    color: Colors.black,
                    width: 2.0,
                  ),),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20),
                  title: Text('Maintain Weight'),
                  subtitle: Text('Lorem ipsum is a placeholder'),
                  onTap: (){
                     Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MaintainWeight()),
                          );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  side: BorderSide(

                    color: Colors.black,
                    width: 2.0,
                  ),),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20),
                  title: Text('Gain Weight'),
                  subtitle: Text('Lorem ipsum is a placeholder'),
                  onTap: (){
                     Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GainWeight()),
                          );
                  },
                ),
              ),
            ),
            
          ],
        ),
      );
  }
}