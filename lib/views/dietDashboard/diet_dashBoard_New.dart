import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/views/dietDashboard/diet_and_activity_journal.dart';
import 'package:ihl/views/dietDashboard/goal_setting.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:ihl/views/dietDashboard/profile_screen.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/profileScreen/photo.dart';

class DietDashBoard extends StatefulWidget {
  @override
  _DietDashBoardState createState() => _DietDashBoardState();
}

class _DietDashBoardState extends State<DietDashBoard> {
  double currentIndexPage = 0;
  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.pop(context);
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 25,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: drawer(),
            drawerEnableOpenDragGesture: true,
            body: body(),
          ),
        ),
      ),
    );
  }

  var items = [
    //1st Image of Slider
    Container(
      margin: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1627350100115-089365de942c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80"),
          fit: BoxFit.cover,
        ),
      ),
    ),

    //2nd Image of Slider
    Container(
      margin: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1627350100115-089365de942c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80"),
          fit: BoxFit.cover,
        ),
      ),
    ),

    //3rd Image of Slider
    Container(
      margin: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1627350100115-089365de942c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80"),
          fit: BoxFit.cover,
        ),
      ),
    ),
  ];
  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPaint(
            painter: CustomBackgroundPainter(
              primary: AppColors.primaryColor.withOpacity(0.7),
              secondary: AppColors.primaryColor,
            ),
            child: Container(),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Hello',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 28,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Firstname Lastname',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: ScUtil().setHeight(10),
          ),
          CarouselSlider(
            items: items,
            //Slider Container properties
            options: CarouselOptions(
                height: 180.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
                // initialPage: currentIndexPage.toInt(),
                onPageChanged: (index, reason) {
                  print('$index' + '      $reason');
                  if (this.mounted) {
                    setState(() {
                      currentIndexPage = index.toDouble();
                    });
                  }
                }),
          ),
          Center(
            child: DotsIndicator(
              dotsCount: items.length,
              position: currentIndexPage,
              decorator: DotsDecorator(
                size: const Size.square(9.0),
                activeSize: const Size(18.0, 9.0),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            color: CardColors.bgColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      // mainAxisAlignment:
                      //     MainAxisAlignment.spaceEvenly,
                      // crossAxisAlignment:
                      //     CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 2,
                          ),
                          width: ScUtil().setWidth(100),
                          height: ScUtil().setHeight(120),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1627350100115-089365de942c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Set Your Goal \n' + 'Get Your Diet \n' + '& fitness Plan',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 100.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: AppColors.primaryColor,
                            ),
                            child: Text('Try Now',
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget drawer() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          elevation: 0.0,
          child: SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    child: Container(
                      height: 140,
                      padding: EdgeInsets.only(bottom: 10),
                      margin: EdgeInsets.all(0),
                      color: AppColors.primaryAccentColor,
                      child: Column(
                        children: [
                          ListTile(
                            trailing: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          ListTile(
                            leading: DrawerProfilePhoto(),
                            title: Text(
                              'Test User',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'IHL score ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ProfileScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.cardColor,
                      child: ListView(
                        children: [
                          ListTile(
                            //  dense:true,
                            // visualDensity: VisualDensity(vertical: -4,),
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'All-in-one place to have a tab of your health',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Home",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          // SizedBox(height: 10,),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Instant consult, book appointments etc.,',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Tele-Consultation",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Track Your Diet, Excercises, Activities etc.',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Calorie Tracker",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DietAndActivityJournal()),
                              );
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Engage in Yoga and Wellness Classes etc.,',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Health-E-Market",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Enjoy and manage Your exclusive Memebership benefits',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Membership Services",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Set and manage goals that reflects your lifestyle',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("Weight Management",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GoalSetting()),
                              );
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_sharp),
                            subtitle: Text(
                              'Know and Connect with us',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            title: Text("About IHL",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textitemTitleColor)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Container(
                      height: 60,
                      // width: 100,
                      color: AppColors.cardColor,
                      child: ListTile(
                        title: Text(
                          'Log Out',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        leading: Icon(Icons.exit_to_app_sharp, color: Colors.red),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryAccentColor,
//         actions: [
//           IconButton(
//               icon: Icon(
//                 Icons.notifications,
//               ),
//               onPressed: () {}),
//         ],
//       ),
//       drawer: Drawer(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: ScUtil().setHeight(20),
//             ),
//             Row(
//               children: [
//                 SizedBox(
//                   width: ScUtil().setWidth(40),
//                 ),
//                 Text('Hello ,',
//                     style: TextStyle(
//                       fontSize: 25,
//                     )),
//               ],
//             ),
//             Row(
//               children: [
//                 SizedBox(
//                   width: ScUtil().setWidth(40),
//                 ),
//                 Text('Test User', style: TextStyle(fontSize: 18)),
//               ],
//             ),
//             SizedBox(
//               height: ScUtil().setHeight(10),
//             ),
//             CarouselSlider(
//               items: items,

//               //Slider Container properties
//               options: CarouselOptions(
//                   height: 180.0,
//                   enlargeCenterPage: true,
//                   autoPlay: true,
//                   aspectRatio: 16 / 9,
//                   autoPlayCurve: Curves.fastOutSlowIn,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: Duration(milliseconds: 800),
//                   viewportFraction: 0.8,
//                   // initialPage: currentIndexPage.toInt(),
//                   onPageChanged: (index, reason) {
//                     print('$index' + '      $reason');
//                     setState(() {
//                       currentIndexPage = index.toDouble();
//                     });
//                   }),
//             ),
//             Center(
//               child: DotsIndicator(
//                 dotsCount: items.length,
//                 position: currentIndexPage,
//                 decorator: DotsDecorator(
//                   size: const Size.square(9.0),
//                   activeSize: const Size(18.0, 9.0),
//                   activeShape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5.0)),
//                 ),
//               ),
//             ),
//             Card(
//               margin: EdgeInsets.all(10),
//               color: CardColors.bgColor,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         // mainAxisAlignment:
//                         //     MainAxisAlignment.spaceEvenly,
//                         // crossAxisAlignment:
//                         //     CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Container(
//                             margin: EdgeInsets.only(top:2,),
//                             width: ScUtil().setWidth(100),
//                             height: ScUtil().setHeight(120),
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                 image: NetworkImage(
//                                   'https://images.unsplash.com/photo-1627350100115-089365de942c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=925&q=80',
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             'Set Your Goal \n' +
//                                 'Get Your Diet \n' +
//                                 '& fitness Plan',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                           ButtonTheme(
//                             minWidth: 100.0,
//                             child: ElevatedButton(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20.0),
//                               ),
//                               color: AppColors.primaryColor,
//                               textColor: Colors.white,
//                               child: Text('Try Now',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                   )),
//                                   onPressed: (){},
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
