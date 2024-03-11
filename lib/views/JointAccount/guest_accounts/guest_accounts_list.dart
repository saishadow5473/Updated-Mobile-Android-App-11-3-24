import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_name.dart';
import 'package:ihl/views/JointAccount/link_existing_account/enter_email.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';

class GuestAccountList extends StatefulWidget {
  GuestAccountList({Key key}) : super(key: key);

  @override
  _GuestAccountListState createState() => _GuestAccountListState();
}

class _GuestAccountListState extends State<GuestAccountList> {
  static get apiRepository => Apirepository();

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: BasicPageUI(
        appBar: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                // onPressed: () {
                // Navigator.of(context).pop();
                // back
                // },
                // onPressed: () => Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ProfileSettingScreen(),
                //     ),
                //     (Route<dynamic> route) => false),
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.JointAccount, arguments: false),

                color: Colors.white,
                tooltip: 'Back',
              ),
              centerTitle: true,
              title: Text(
                'Guest Accounts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScUtil().setSp(30),
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   // height: MediaQuery.of(context).size.height /
                //   //     1.2, // bottom white space fot the teledashboard
                //   child: ListView.builder(
                //     physics: const ScrollPhysics(),
                //     primary: false,
                //     shrinkWrap: true,
                //     itemCount: 0,
                //     itemBuilder: (BuildContext context, int index) {
                //       return jointAccountCard(
                //         // return card(
                //         context,
                //         options[index]['text'],
                //         options[index]['icon'],
                //         options[index]['iconSize'],
                //         options[index]['color'],
                //         options[index]['onTap'],
                //       );
                //     },
                //   ),
                // ),
                Container(
                  child: Text(
                    'Linked Accounts will be listed here...\nSimilar to My appointments tiles',
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<Map> options = [
    {
      'text': "Create New Account",
      'icon': FontAwesomeIcons.userPlus,
      'iconSize': 24.0,
      'onTap': () {
        Get.to(
          CreateName(),
        );
      },
      'color': AppColors.startConsult,
    },
    {
      'text': 'Link Existing Account',
      'icon': FontAwesomeIcons.staylinked,
      'iconSize': 24.0,
      'onTap': () {
        // Get.to(LinkExistAccount());
        Get.to(
          EnterEmail(apiRepository: apiRepository),
        );
      },
      'color': AppColors.greenColor,
    },
    {
      'text': "Guest Accounts",
      'icon': FontAwesomeIcons.userPlus,
      'iconSize': 24.0,
      'onTap': () {
        // Get.to(create_new_account());
      },
      'color': AppColors.primaryAccentColor,
    },
    {
      'text': 'Linked Account Setting',
      'icon': FontAwesomeIcons.userCog,
      'iconSize': 24.0,
      'onTap': () {
        // Get.to(create_new_account());
      },
      'color': AppColors.dietJournalPrimary,
    },
  ];

  Widget jointAccountCard(BuildContext context, var _title, var _icon,
      var _iconSize, var _bgColor, final Function onTap) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        color: AppColors.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          splashColor: _bgColor.withOpacity(0.5),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: ScUtil().setHeight(3.0),
            ),
            Center(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(11.0),
                    height: ScUtil().setHeight(30.0),
                    width: ScUtil().setWidth(50.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _icon,
                      color: _bgColor,
                      size: _iconSize,
                    ),
                  ),
                  SizedBox(
                    // width: ScUtil().setWidth(30.0),
                    width: ScUtil().setWidth(10.0),
                  ),
                  Flexible(
                    child: Text(
                      _title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(3.0),
            ),
          ]),
        ),
      ),
    );
  }
}
