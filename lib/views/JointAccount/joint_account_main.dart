import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:expandable/expandable.dart';
import 'package:expansion_card/expansion_card.dart';
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
import 'package:ihl/views/JointAccount/guest_accounts/guest_accounts_list.dart';
import 'package:ihl/views/JointAccount/link_existing_account/enter_email.dart';
import 'package:ihl/views/JointAccount/linked_account_setting/model/notification_model.dart';
import 'package:ihl/views/JointAccount/linked_account_setting/myDialog_page.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';

class JointAccount extends StatefulWidget {
  JointAccount({Key key}) : super(key: key);

  @override
  _JointAccountState createState() => _JointAccountState();
}

class _JointAccountState extends State<JointAccount> {
  final allowNotifications = NotificationSetting(title: 'Allow Notifications');

  bool loading = true;
  // bool value = false;
  static get apiRepository => Apirepository();
  ExpandableController _expandableController;
  bool hasSubscription = false;
  bool expanded = true;
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  final notifications = [
    NotificationSetting(title: 'Read Vitals'),
    NotificationSetting(title: 'Write Vitals'),
    NotificationSetting(title: 'Read teleconsultation details'),
    NotificationSetting(title: 'Write teleconsultation'),
  ];

  Widget buildSingleCheckbox(NotificationSetting notifications) {
    return _buildCheckBox(
        notifications: notifications,
        onClicked: () {
          setState(() {
            final newValue = !notifications.value;
            notifications.value = newValue;
          });
        });
  }

  Widget _buildCheckBox({
    @required NotificationSetting notifications,
    @required VoidCallback onClicked,
  }) {
    return ListTile(
      onTap: onClicked,
      leading: Checkbox(value: notifications.value, onChanged: (value) => onClicked()),
      title: Text(notifications.title),
    );
  }

  @override
  void initState() {
    super.initState();
    _initAsync();

    _expandableController = ExpandableController(
      initialExpanded: true,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        {
          setState(() {
            expanded = _expandableController.expanded;
          });
        }
      }
    });
  }

  // bool checkboxValueCity = false;
  static List<String> allAccess = [
    'Read Vitals',
    'Write Vitals',
    'Read teleconsultation details',
    'Write teleconsultation'
  ];
  static List<String> selectedAccess = [];

  bool isExpandedLAS = false;
  bool isExpandedUHA = false;
  bool isExpandedUGA = false;
  bool isExpandedGAs = false;

  static Widget userHaveAccessWidget({String title, Icon icon}) {
    return ListTile(
      // minVerticalPadding: 2,
      contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
      leading: Text(
        title,
        style: TextStyle(color: AppColors.primaryAccentColor, fontSize: 18),
      ),
      trailing: icon,
    );
  }

  static Widget userGivenAccessWidget({String title, Icon icon, VoidCallback ontap}) {
    return ListTile(
      // minVerticalPadding: 2,
      contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
      leading: Text(
        title,
        style: TextStyle(color: AppColors.primaryAccentColor, fontSize: 18),
      ),
      trailing: icon,
      // onTap: ontap,
    );
  }

  List<Widget> userHaveAccessList = [
    userHaveAccessWidget(
        title: 'Sumithra',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
    userHaveAccessWidget(
        title: 'Siva Mani',
        icon: Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
        )),
  ];

  List<Widget> userGivenAccessList = [
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 1');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 2');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 3');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 4');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 5');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 6');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 7');
      },
    ),
    userGivenAccessWidget(
      title: 'Siva Mani',
      icon: Icon(
        Icons.info_outline,
        color: Colors.blueAccent,
      ),
      ontap: () {
        print('ontapped 8');
      },
    ),
  ];

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
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.ProfileScreenSettings, arguments: false),
                color: Colors.white,
                tooltip: 'Back',
              ),
              centerTitle: true,
              title: Text(
                'Joint Accounts',
                style: TextStyle(color: Colors.white, fontSize: ScUtil().setSp(20.0)),
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
              children: [
                // create new account starts
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        Get.to(
                          CreateName(),
                        );
                      },
                      splashColor: Colors.grey.withOpacity(0.5),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(
                          height: ScUtil().setHeight(3.0),
                        ),
                        Center(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(11.0),
                                height: ScUtil().setHeight(60.0),
                                width: ScUtil().setWidth(50.0),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.userPlus,
                                  size: 35.0,
                                  color: AppColors.startConsult,
                                ),
                              ),
                              SizedBox(
                                // width: ScUtil().setWidth(30.0),
                                width: ScUtil().setWidth(30.0),
                              ),
                              Flexible(
                                child: Text(
                                  // 'Create Account',
                                  'Add a Family Account',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: ScUtil().setSp(18.0),
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
                ),

                // create new account ends
                SizedBox(
                  height: ScUtil().setWidth(6.0),
                ),
                // Link account starts
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        Get.to(EnterEmail(
                          apiRepository: apiRepository,
                        ));
                      },
                      splashColor: Colors.grey.withOpacity(0.5),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(
                          height: ScUtil().setHeight(3.0),
                        ),
                        Center(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(11.0),
                                height: ScUtil().setHeight(60.0),
                                width: ScUtil().setWidth(50.0),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.link,
                                  size: 35.0,
                                  color: AppColors.greenColor,
                                ),
                              ),
                              SizedBox(
                                // width: ScUtil().setWidth(30.0),
                                width: ScUtil().setWidth(30.0),
                              ),
                              Flexible(
                                child: Text(
                                  'Link Account',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: ScUtil().setSp(18.0),
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
                ),
                // Link account ends
                SizedBox(
                  height: ScUtil().setWidth(6.0),
                ),
                // Guest account starts
                Container(
                  // height: MediaQuery.of(context).size.height / 6.9,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: ExpansionCard(
                      margin: const EdgeInsets.only(bottom: 0.0, top: 28.0),
                      // initiallyExpanded: true,
                      onExpansionChanged: (v) {
                        setState(() {
                          isExpandedGAs = v;
                        });
                      },
                      trailing: isExpandedGAs
                          ? Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.blueAccent,
                              size: 28.0,
                            )
                          : Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.blueAccent,
                              size: 28.0,
                            ),
                      borderRadius: 20,
                      title: Column(
                        children: [
                          SizedBox(
                            height: ScUtil().setHeight(6.0),
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: ScUtil().setWidth(5.0),
                              ),
                              Container(
                                child: Icon(
                                  FontAwesomeIcons.userFriends,
                                  color: AppColors.primaryAccentColor,
                                  size: 35.0,
                                ),
                              ),
                              SizedBox(
                                width: ScUtil().setWidth(53.0),
                              ),
                              Text(
                                'Guest Accounts',
                                overflow: TextOverflow.ellipsis,
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                  //fontWeight: FontWeight.w600,
                                  fontSize: ScUtil().setSp(19.0),
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ScUtil().setHeight(24.0),
                          ),
                        ],
                      ),

                      children: <Widget>[
                        // content goes here
                        SizedBox(
                          height: ScUtil().setHeight(8.0),
                        ),
                        Container(
                          height: ScUtil().setHeight(150.0),
                          width: ScUtil().setWidth(315.0),
                          // height: MediaQuery.of(context).size.height / 4.2,
                          // width: MediaQuery.of(context).size.width / 1.21,
                          child: Card(
                            color: AppColors.cardColor,
                            elevation: 2.0,
                            child: ListView.builder(
                              itemCount: userHaveAccessList.length,
                              itemBuilder: (context, index) {
                                return userHaveAccessList[index];
                              },
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ScUtil().setHeight(5.0),
                        ),
                      ],
                    ),
                  ),
                ),

                // Guest account ends
                SizedBox(
                  height: ScUtil().setWidth(6.0),
                ),
                // Linked account setting starts

                Container(
                  // height: MediaQuery.of(context).size.height / 6.9,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: ExpansionCard(
                      margin: const EdgeInsets.only(bottom: 0.0, top: 28.0),
                      // initiallyExpanded: true,
                      onExpansionChanged: (v) {
                        setState(() {
                          isExpandedLAS = v;
                        });
                      },
                      trailing: isExpandedLAS
                          ? Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.blueAccent,
                              size: 28.0,
                            )
                          : Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.blueAccent,
                              size: 28.0,
                            ),
                      borderRadius: 20,
                      title: Column(
                        children: [
                          SizedBox(
                            height: ScUtil().setHeight(6.0),
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: ScUtil().setWidth(5.0),
                              ),
                              Container(
                                child: Icon(
                                  FontAwesomeIcons.userCog,
                                  color: AppColors.failure,
                                  size: 35.0,
                                ),
                              ),
                              SizedBox(
                                width: ScUtil().setWidth(53.0),
                              ),
                              Text(
                                'Account Settings',
                                overflow: TextOverflow.ellipsis,
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                  //fontWeight: FontWeight.w600,
                                  fontSize: ScUtil().setSp(19.0),
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ScUtil().setHeight(24.0),
                          ),
                        ],
                      ),

                      children: <Widget>[
                        // content goes here

                        // Users I have Access starts

                        Container(
                          // height: MediaQuery.of(context).size.height / 2.9,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            color: AppColors.cardColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () {
                                // Get.to(UserListWithAccess());
                                // showAccessibleUserDialog(context);
                              },
                              splashColor: Colors.grey.withOpacity(0.5),
                              child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ExpansionCard(
                                      margin: const EdgeInsets.only(bottom: 0.0, top: 0.0),
                                      onExpansionChanged: (v) {
                                        setState(() {
                                          isExpandedUHA = v;
                                        });
                                      },
                                      trailing: isExpandedUHA
                                          ? Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.blueAccent,
                                              size: 28.0,
                                            )
                                          : Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.blueAccent,
                                              size: 28.0,
                                            ),
                                      title: ListTile(
                                        leading: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.universalAccess,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        title: Container(
                                          child: Text(
                                            'Users I have Access',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              //fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(17.0),
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          height: ScUtil().setHeight(150.0),
                                          width: ScUtil().setWidth(315.0),
                                          // height: MediaQuery.of(context)
                                          //         .size
                                          //         .height /
                                          //     4.2,
                                          // width: MediaQuery.of(context)
                                          //         .size
                                          //         .width /
                                          //     1.21,
                                          child: Card(
                                            color: AppColors.cardColor,
                                            elevation: 2.0,
                                            child: ListView.builder(
                                              itemCount: userHaveAccessList.length,
                                              itemBuilder: (context, index) {
                                                return userHaveAccessList[index];
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: ScUtil().setHeight(5.0),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        // Linked account setting ends
                        SizedBox(
                          height: ScUtil().setHeight(8.0),
                        ),
                        // User whom I given Access starts
                        Container(
                          // height: MediaQuery.of(context).size.height / 2.9,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            color: AppColors.cardColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () {
                                // Get.to(UserListWithAccess());
                                // showAccessibleUserDialog(context);
                              },
                              splashColor: Colors.grey.withOpacity(0.5),
                              child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ExpansionCard(
                                      margin: const EdgeInsets.only(bottom: 0.0, top: 0.0),
                                      onExpansionChanged: (v) {
                                        setState(() {
                                          isExpandedUGA = v;
                                        });
                                      },
                                      trailing: isExpandedUGA
                                          ? Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.blueAccent,
                                              size: 28.0,
                                            )
                                          : Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.blueAccent,
                                              size: 28.0,
                                            ),
                                      title: ListTile(
                                        leading: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.userEdit,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        title: Container(
                                          child: Text(
                                            'Users I given Access',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              //fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(17.0),
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height / 4.2,
                                          width: MediaQuery.of(context).size.width / 1.21,
                                          child: Card(
                                            color: AppColors.cardColor,
                                            elevation: 2.0,
                                            child: InkWell(
                                              onTap: () {
                                                AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: false,
                                                    dialogType: DialogType.INFO,
                                                    dismissOnTouchOutside: false,
                                                    // title:
                                                    //     'Accessed Users!',
                                                    // desc:
                                                    //     'Registration failed\nTry Again!',
                                                    body: MyDialog(
                                                        access: allAccess,
                                                        selectedAccess: selectedAccess,
                                                        onSelectedAccessListChanged: (access) {
                                                          selectedAccess = access;
                                                          print(selectedAccess);
                                                        }),
                                                    onDismissCallback: (_) {
                                                      debugPrint('Dialog Dissmiss from callback');
                                                    }).show();
                                              },
                                              child: ListView.builder(
                                                itemCount: userGivenAccessList.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    child: userGivenAccessList[index],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: ScUtil().setHeight(5.0),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ScUtil().setHeight(5.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget jointAccountCard(BuildContext context, var _title, var _icon, var _iconSize, var _bgColor,
      final Function onTap) {
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
                    height: ScUtil().setHeight(60.0),
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
                    width: ScUtil().setWidth(30.0),
                  ),
                  Flexible(
                    child: Text(
                      _title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: ScUtil().setSp(18.0),
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
