import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';

class FavoriteMeal extends StatefulWidget {
  @override
  _FavoriteMealState createState() => _FavoriteMealState();
}

class _FavoriteMealState extends State<FavoriteMeal> {
  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
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
                key: Key('journalCalendarBackButton'),
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DietJournal()),
                    (Route<dynamic> route) => false),
                color: Colors.white,
                tooltip: 'Back',
              ),
              Flexible(
                child: Center(
                  child: Text(
                    'Favourites',
                    style:
                        TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
          SizedBox()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0),
        child: Column(children: [
          Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 20.0),
                        child: Text(
                          "Rice",
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_outlined,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '345 ',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appTextColor),
                                  ),
                                  TextSpan(
                                    text: "Cal",
                                    style: TextStyle(color: AppColors.appTextColor, fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showPicker(context);
                          },
                          icon: Icon(Icons.add),
                          label: Text("Add"),
                          style: ElevatedButton.styleFrom(
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            primary: AppColors.primaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   top: 20.0,
              //   left: 320,
              //   child: Container(
              //     width: 40.0,
              //     height: 40.0,
              //     child: RawMaterialButton(
              //       key: Key('addToFav'),
              //       onPressed: () {},
              //       elevation: 1.0,
              //       fillColor: Color(0xffe5cac2),
              //       child: Icon(
              //         Icons.star,
              //         size: 30.0,
              //         color: AppColors.dietJournalOrange,
              //       ),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0)
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                top: 30,
                left: 200,
                child: Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
                              ))),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          // Stack(
          //   overflow: Overflow.visible,
          //   children: <Widget>[
          //     Padding(
          //       padding: EdgeInsets.only(top: 10.0),
          //       child: Card(
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.only(
          //                 topLeft: Radius.circular(20.0),
          //                 bottomLeft: Radius.circular(20.0),
          //                 bottomRight: Radius.circular(20.0),
          //                 topRight: Radius.circular(20.0))),
          //         color: Colors.white,
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Padding(
          //               padding: const EdgeInsets.only(left: 15.0, top: 20.0),
          //               child: Text(
          //                 "White Rice",
          //                 style: TextStyle(
          //                     fontSize: 24.0, fontWeight: FontWeight.bold),
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: Row(
          //                 children: [
          //                   Icon(
          //                     Icons.local_fire_department_outlined,
          //                     color: AppColors.primaryColor,
          //                   ),
          //                   SizedBox(
          //                     width: 5.0,
          //                   ),
          //                   RichText(
          //                     text: TextSpan(
          //                       children: [
          //                         TextSpan(
          //                           text: '125 ',
          //                           style: TextStyle(
          //                               fontSize: 20.0,
          //                               fontWeight: FontWeight.bold,
          //                               color: AppColors.appTextColor),
          //                         ),
          //                         TextSpan(
          //                           text: "kcal",
          //                           style: TextStyle(
          //                               color: AppColors.appTextColor,
          //                               fontSize: 12.0),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: ElevatedButton.icon(
          //                 onPressed: () {
          //                   _showPicker(context);
          //                 },
          //                 icon: Icon(Icons.add),
          //                 label: Text("Add"),
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10.0)),
          //                 color: AppColors.primaryColor,
          //                 textColor: Colors.white,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //     // Positioned(
          //     //   top: 20.0,
          //     //   left: 320,
          //     //   child: Container(
          //     //     width: 40.0,
          //     //     height: 40.0,
          //     //     child: RawMaterialButton(
          //     //       key: Key('addToFav'),
          //     //       onPressed: () {},
          //     //       elevation: 1.0,
          //     //       fillColor: Color(0xffe5cac2),
          //     //       child: Icon(
          //     //         Icons.star,
          //     //         size: 30.0,
          //     //         color: AppColors.dietJournalOrange,
          //     //       ),
          //     //       shape: RoundedRectangleBorder(
          //     //           borderRadius: BorderRadius.circular(10.0)
          //     //       ),
          //     //     ),
          //     //   ),
          //     // ),
          //     Positioned(
          //       top: 30,
          //       left: 200,
          //       child: Container(
          //         width: 120.0,
          //         height: 120.0,
          //         decoration: ShapeDecoration(
          //           shape: CircleBorder(),
          //         ),
          //         child: Padding(
          //           padding: EdgeInsets.all(0.0),
          //           child: DecoratedBox(
          //             decoration: ShapeDecoration(
          //                 shape: CircleBorder(),
          //                 image: DecorationImage(
          //                     fit: BoxFit.cover,
          //                     image: NetworkImage(
          //                       'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
          //                     ))),
          //           ),
          //         ),
          //       ),
          //     )
          //   ],
          // ),

          //Custom Card
          Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "White Rice",
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 11.0,
                          ),
                          Row(
                            children: [
                              // SizedBox(
                              //   width: 18.0,
                              // ),
                              Icon(
                                Icons.local_fire_department_outlined,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '125 ',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appTextColor),
                                    ),
                                    TextSpan(
                                      text: "Cal",
                                      style:
                                          TextStyle(color: AppColors.appTextColor, fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 11.0,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showPicker(context);
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add"),
                            style: ElevatedButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              primary: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 11.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                            ),
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),

          //listTile
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            color: Colors.white,
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    "White Rice",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                    ),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: CircleBorder(),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '125 ',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.appTextColor),
                            ),
                            TextSpan(
                              text: "Cal",
                              style: TextStyle(color: AppColors.appTextColor, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 200.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showPicker(context);
                      },
                      icon: Icon(Icons.add),
                      label: Text("Add"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        primary: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              // trailing: CircleAvatar(
              //   radius: 70,
              //   backgroundImage: NetworkImage(
              //             'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
              //           ),
              // )
              // Container(
              //   width: 120.0,
              //   height: 120.0,
              //   decoration: ShapeDecoration(
              //     shape: CircleBorder(),
              //   ),
              //   child: DecoratedBox(

              //     decoration: ShapeDecoration(
              //         shape: CircleBorder(),
              //         image: DecorationImage(
              //           fit: BoxFit.cover,
              //           image: NetworkImage(
              //             'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
              //           ),
              //         ),
              //         ),
              //   ),
              // ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: Icon(Icons.free_breakfast_outlined),
                      title: new Text('Add to Breakfast'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: Icon(Icons.lunch_dining),
                      title: new Text('Add to Lunch'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: Icon(Icons.dinner_dining),
                      title: new Text('Add to Dinner'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                      leading: Icon(Icons.fastfood_outlined),
                      title: new Text('Add to Snacks'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }
}
