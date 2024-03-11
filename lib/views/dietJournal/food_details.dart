// import 'package:customgauge/customgauge.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
// import 'package:pdf/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:strings/strings.dart';

class FoodDetail extends StatefulWidget {
  final favouriteItemList;
  final index;
  FoodDetail({this.favouriteItemList, this.index});
  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  @override
  bool selected = false;
  ExpandableController _expandableController;
  bool expanded = true;

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController(
      initialExpanded: false,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasicPageUI(
      backgroundColor: AppColors.cardColor,
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => FavoriteMeal()),//DietJournal(navigateIndex: 4,)),
                //         (Route<dynamic> route) => false),
                color: Colors.white,
                tooltip: 'Back',
              ),
              Flexible(
                child: Center(
                  child: Text(
                    'Meal Detail',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              ),
              // Container(
              //   width: 50.0,
              //   height: 50.0,
              //   child: RawMaterialButton(
              //     onPressed: () {},
              //     elevation: 1.0,
              //     fillColor: Colors.white,
              //     child: Icon(
              //       FontAwesomeIcons.solidHeart,
              //       size: 30.0,
              //       color: AppColors.primaryAccentColor,
              //     ),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0)
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: true, //selected ? true : false,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          camelize(
                              widget.favouriteItemList[widget.index]['item']),
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_outlined,
                              color: AppColors.primaryAccentColor,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.favouriteItemList[widget.index]
                                            ['calories']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appTextColor),
                                  ),
                                  TextSpan(
                                    text: " cal",
                                    style: TextStyle(
                                        color: AppColors.appTextColor,
                                        fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, right: 18.0),

                        //ignore: missing_required_param
                        child: ExpandablePanel(
                          controller: _expandableController,
                          theme: ExpandableThemeData(
                              hasIcon: false,
                              animationDuration: Duration(milliseconds: 100)),
                          header: Card(
                            color: Color(0xffF4F6FA),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            child: ListTile(
                              leading: Text("1"),
                              title: Text("Serving - 2,000 g"),
                              trailing: expanded
                                  ? Icon(Icons.keyboard_arrow_up)
                                  : Icon(Icons.keyboard_arrow_down),
                              onTap: () {
                                _expandableController.toggle();
                              },
                            ),
                          ),
                          expanded: serving(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            height: 50.0,
                            width: 200.0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF19a9e5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        "Add to Journal",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: true, //selected ? true : false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      Text("Nutrition Fact",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: AppColors.primaryAccentColor,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "78%",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Carbs",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xff7FE3F0),
                          ),
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "13%",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Proteins",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xffAF8EFF),
                          ),
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "9%",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Fats",
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xff1F87FE),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xffAF8EFF),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Protein",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['proteins']
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff7FE3F0),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Carbs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]
                                      ['total_carbohydrates']
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child:
                              Text("Fibers", style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['fiber']
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child:
                              Text("Sugars", style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['sugar']
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff1F87FE),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Fats",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['total_fat']
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child: Text("Saturated fat",
                              style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]
                                      ['saturated_fats']
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child: Text("Unsaturated fat",
                              style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          (widget.favouriteItemList[widget.index]
                                          ['monounsaturated_fats'] +
                                      widget.favouriteItemList[widget.index]
                                          ['polyunsaturated_fats'])
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff1F87FE),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Vitamins",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          (widget.favouriteItemList[widget.index]['vitamin_a'] +
                                      widget.favouriteItemList[widget.index]
                                          ['vitamin_c'])
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child: Text("Vitamin a",
                              style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          (widget.favouriteItemList[widget.index]['vitamin_a'])
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 57.0),
                          child: Text("Vitamin c",
                              style: TextStyle(fontSize: 19.0)),
                        ),
                        trailing: Text(
                          (widget.favouriteItemList[widget.index]['vitamin_c'])
                                  .toString() +
                              " g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff7FE3F0),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Calcium",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['calcium']
                                  .toString() +
                              " ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff7FE3F0),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Sodium",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['sodium']
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 20.0,
                            minWidth: 20.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: Color(0xff7FE3F0),
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                        title: Text("Potassium",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          widget.favouriteItemList[widget.index]['potassium']
                                  .toString() +
                              " g",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget serving() {
    return AlertDialog(
      content: Column(
        children: [
          Text("Serving - 3000 g"),
          Text("Serving - 4000 g"),
        ],
      ),
    );
  }
}

























































//   Widget build(BuildContext context) {
//     return BasicPageUI(
//       appBar: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom:10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back_ios),
//                   onPressed: () => 
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => DietJournal()),
//                           // (introDone: true)),
//                           (Route<dynamic> route) => false),
//                   color: Colors.white,
//                   tooltip: 'Back',
//                 ),
//                 // Flexible(
//                 //   child: Center(
//                 //     child: Text(
//                 //       'Favourite Meal',
//                 //       style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//                 //       textAlign: TextAlign.center,
//                 //     ),
//                 //   ),
//                 // ),
//                 Text(
//                   'Meal Detail',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: ScUtil().setSp(22),
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 40,
//                 )
//               ],
//             ),
//           ),
          
//         ],
//       ),
//       body: SingleChildScrollView(
//               child: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height-150,
//               child: Padding(
//                       padding: const EdgeInsets.all(7.0),
//                       child: Card(
//                         elevation: 2,
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8.0),
//                             child: Image.network(
//                               "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
//                               ),
//                           ),
//                           title: Text(widget.favouriteItemList[0]['item'], style: TextStyle(
//                             color: AppColors.appTextColor,
//                               fontWeight: FontWeight.bold
//                           ),),
//                           subtitle: Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.local_fire_department_outlined,color: AppColors.primaryAccentColor,size: 15,),
//                                 SizedBox(width: 5,),
//                                 Text(widget.favouriteItemList[0]['calories'].toString()+'cal'),
//                               ],
//                             ),
//                           ),
//               //             onTap: (){
//               //               Navigator.push(
//               // context,
//               // MaterialPageRoute(
//               //     builder: (context) => foodDetail(
//               //       course: widget.consultant,
                    
//               //     )));
//               //             },
//                         ),
//                       ),
//                     ),
              
//             ),
//           // Container(height: 100,color: Colors.blue,)
//           ],
//         ),
//       ),
      
//     );
//   }



// }
