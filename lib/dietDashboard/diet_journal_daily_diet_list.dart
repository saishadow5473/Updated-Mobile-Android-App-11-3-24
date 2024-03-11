import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/addFood.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:table_calendar/table_calendar.dart';

class DietJournalDashboardList extends StatefulWidget {
  @override
  _DietJournalDashboardListState createState() => _DietJournalDashboardListState();
}

class _DietJournalDashboardListState extends State<DietJournalDashboardList> {
  DateTime dt = DateTime.now();
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      // appBar: Column(
      //   children: [
      //     SizedBox(
      //       width: 30,
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         IconButton(
      //           key: Key('journalCalendarBackButton'),
      //           icon: Icon(Icons.arrow_back_ios),
      //           onPressed: () => Navigator.pushAndRemoveUntil(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => DietJournal()),
      //                   (Route<dynamic> route) => false),
      //           color: Colors.white,
      //           tooltip: 'Back',
      //         ),
      //         Flexible(
      //           child: Center(
      //             child: Text(
      //               'Journal',
      //               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      //               textAlign: TextAlign.center,
      //             ),
      //           ),
      //         ),
      //         SizedBox(
      //           width: 40,
      //         )
      //       ],
      //     ),
      //    Padding(
      //      padding: const EdgeInsets.all(8.0),
      //      child: TableCalendar(
      //        onDaySelected: (date, events, e) {
      //          setState(() {
      //            dt = date;
      //          });
      //        },
      //        startingDayOfWeek: StartingDayOfWeek.monday,
      //        initialCalendarFormat: CalendarFormat.week,
      //        headerVisible: false,
      //        calendarStyle: CalendarStyle(
      //          weekdayStyle: TextStyle(
      //            color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //          weekendStyle: TextStyle(
      //            color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //          selectedColor: Colors.white,
      //          selectedStyle: TextStyle(),
      //          todayColor: AppColors.dietJournalOrange,
      //          markersColor: Colors.white,
      //          outsideDaysVisible: false,
      //          outsideStyle: TextStyle(
      //              color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //          outsideWeekendStyle: TextStyle(
      //              color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //          outsideHolidayStyle: TextStyle(
      //              color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //        ),
      //        daysOfWeekStyle: DaysOfWeekStyle(
      //          weekdayStyle: TextStyle(
      //            color: Colors.white, fontWeight: FontWeight.bold
      //          ),
      //          weekendStyle: TextStyle(
      //            color: Colors.white, fontWeight: FontWeight.bold
      //          )
      //        ),
      //        headerStyle: HeaderStyle(
      //          titleTextStyle: TextStyle(
      //            color: Colors.white
      //          ),
      //          formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
      //          formatButtonDecoration: BoxDecoration(
      //            color: Colors.white,
      //            borderRadius: BorderRadius.circular(16.0),
      //          ),
      //        ),
      //        calendarController: _calendarController,
      //        availableCalendarFormats: const {
      //          CalendarFormat.week: '',
      //        },

      //      ),
      //    ),
      //     SizedBox(

      //     )
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: dt.isAtSameMomentAs(now)
              ? Column(
                  children: <Widget>[
                    breakfastCard(),
                    SizedBox(
                      height: 15.0,
                    ),
                    lunchCard(),
                    SizedBox(
                      height: 15.0,
                    ),
                    dinnerCard(),
                    SizedBox(
                      height: 15.0,
                    ),
                    snacksCard(),
                    SizedBox(
                      height: 15.0,
                    ),
                    extrasCard(),
                  ],
                )
              : dt.isAfter(now)
                  ? Column(
                      children: <Widget>[
                        breakfastCardNext(),
                        SizedBox(
                          height: 15.0,
                        ),
                        lunchCardNext(),
                        SizedBox(
                          height: 15.0,
                        ),
                        dinnerCardNext(),
                        SizedBox(
                          height: 15.0,
                        ),
                        snacksCardNext(),
                        SizedBox(
                          height: 15.0,
                        ),
                        extrasCardNext(),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        breakfastCard(),
                        SizedBox(
                          height: 15.0,
                        ),
                        lunchCard(),
                        SizedBox(
                          height: 15.0,
                        ),
                        dinnerCard(),
                        SizedBox(
                          height: 15.0,
                        ),
                        snacksCard(),
                        SizedBox(
                          height: 15.0,
                        ),
                        extrasCard(),
                      ],
                    ),
        ),
      ),
      backgroundColor: AppColors.cardColor,
    );
  }

  Widget breakfastCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Breakfast",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: Color(0xfffc6111),
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: Color(0xfffc6111),
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '120 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                key: Key('journalAddBreakfast'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Breakfast")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: Color(0xfffc6111),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Salad with soup",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '105 cals',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://images.unsplash.com/photo-1498837167922-ddd27525d352?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&w=1000&q=80'),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Salad with white egg",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '200 cals',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 8.0),
          //   child: ListTile(
          //     leading: ConstrainedBox(
          //       constraints: BoxConstraints(
          //         minWidth: 75,
          //         minHeight: 75,
          //         maxWidth: 100,
          //         maxHeight: 100,
          //       ),
          //       child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80", fit: BoxFit.cover),
          //     ),
          //     // ClipRRect(
          //     //   borderRadius: BorderRadius.circular(8.0),
          //     //   child: Image.network(
          //     //     // "https://img.webmd.com/dtmcms/live/webmd/consumer_assets/site_images/article_thumbnails/other/1800x1200_potassium_foods_other.jpg",
          //     //     "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80",
          //     //     ),
          //     // ),
          //     title: Text("Salad with soup", style: TextStyle(
          //       color: AppColors.appTextColor,
          //         fontWeight: FontWeight.bold, fontSize: 18.0
          //     ),),
          //     subtitle: Padding(
          //       padding: const EdgeInsets.only(top: 8.0),
          //       child: Text("105 cals", style: TextStyle(
          //           color: AppColors.appTextColor,
          //           fontSize: 16.0
          //       ),),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 8.0),
          //   child: ListTile(
          //     leading: ClipRRect(
          //       borderRadius: BorderRadius.circular(8.0),
          //       child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //       ),
          //     ),
          //     title: Text("Salad with white egg", style: TextStyle(
          //         color: AppColors.appTextColor,
          //         fontWeight: FontWeight.bold, fontSize: 18.0
          //     ),),
          //     subtitle: Padding(
          //       padding: const EdgeInsets.only(top: 8.0),
          //       child: Text("200 cals", style: TextStyle(
          //           color: AppColors.appTextColor,
          //           fontSize: 16.0
          //       ),),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget lunchCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Lunch",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '420 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                key: Key('journalAddLunch'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Lunch")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://upload.wikimedia.org/wikipedia/commons/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg"),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Food Item 1",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '105 cals',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(8.0),
          //         child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //       ),
          //       title: Text("Salad with wheat and white egg", style: TextStyle(
          //           color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //       ),),
          //       subtitle: Padding(
          //         padding: const EdgeInsets.only(top: 8.0),
          //         child: Text("200 cals"),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(8.0),
          //         child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //       ),
          //       title: Text("Salad with wheat and white egg", style: TextStyle(
          //           color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //       ),),
          //       subtitle: Padding(
          //         padding: const EdgeInsets.only(top: 8.0),
          //         child: Text("200 cals"),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget dinnerCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Dinner",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '120 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                key: Key('journalAddDinner'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Dinner")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://media.istockphoto.com/photos/top-view-table-full-of-food-picture-id1220017909?b=1&k=6&m=1220017909&s=170667a&w=0&h=yqVHUpGRq-vldcbdMjSbaDV9j52Vq8AaGUNpYBGklXs="),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Food Item 2",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '400 cals',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://images2.minutemediacdn.com/image/upload/c_crop,h_1126,w_2000,x_0,y_181/f_auto,q_auto,w_1100/v1554932288/shape/mentalfloss/12531-istock-637790866.jpg"),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Food Item 3",
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '155 cals',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(8.0),
          //         child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //       ),
          //       title: Text("Salad with wheat and white egg", style: TextStyle(
          //           color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //       ),),
          //       subtitle: Padding(
          //         padding: const EdgeInsets.only(top: 8.0),
          //         child: Text("200 cals"),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(8.0),
          //         child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //       ),
          //       title: Text("Salad with wheat and white egg", style: TextStyle(
          //           color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //       ),),
          //       subtitle: Padding(
          //         padding: const EdgeInsets.only(top: 8.0),
          //         child: Text("200 cals"),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget snacksCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Snacks",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '120 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                key: Key('journalAddSnack'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Snacks")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              height: 80,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://post.healthline.com/wp-content/uploads/2020/07/pizza-beer-1200x628-facebook-1200x628.jpg"),
                            fit: BoxFit.fill)),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text("Food Item 4",
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              '120 cals',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ListTile(
          //       leading: ClipRRect(
          //         borderRadius: BorderRadius.circular(8.0),
          //         child: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //       ),
          //       title: Text("Salad with wheat and white egg", style: TextStyle(
          //           color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //       ),),
          //       subtitle: Padding(
          //         padding: const EdgeInsets.only(top: 8.0),
          //         child: Text("200 cals"),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Card(
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(8.0),
          //       child: ListTile(
          //         leading: Image.network(
          //           "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNhbGFkfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"
          //           ,),
          //         title: Text("Salad with wheat and white egg", style: TextStyle(
          //             color: AppColors.appTextColor, fontWeight: FontWeight.bold
          //         ),),
          //         subtitle: Padding(
          //           padding: const EdgeInsets.only(top: 8.0),
          //           child: Text("200 cals"),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget extrasCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Extras",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Extras")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget breakfastCardNext() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Breakfast",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Breakfast")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget lunchCardNext() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Lunch",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Lunch")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget dinnerCardNext() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Dinner",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Dinner")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget snacksCardNext() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Snacks",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Snacks")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget extrasCardNext() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Extras",
                style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.dietJournalOrange,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: AppColors.dietJournalOrange,
                ),
                SizedBox(
                  width: 5.0,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '0 ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appTextColor),
                      ),
                      TextSpan(
                        text: "Cal ",
                        style: TextStyle(color: AppColors.appTextColor, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 40.0,
              height: 40.0,
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AddFood(mealType: "Extras")),
                      (Route<dynamic> route) => false);
                },
                elevation: 1.0,
                fillColor: Color(0xffe5cac2),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: AppColors.dietJournalOrange,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
