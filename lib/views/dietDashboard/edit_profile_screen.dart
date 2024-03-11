import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/profileScreen/personal.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({this.kisokAccountWithoutWeight});
  final bool kisokAccountWithoutWeight;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextStyle headerStyle = TextStyle(
    color: AppColors.primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  bool isJoinAccount;

  @override
  showDoctorBusyDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text('Info'),
      content: Text(
          'Please Setup Your Profile.'),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.primaryColor,
          ),
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  willpopFunction(ctx){
    if(widget.kisokAccountWithoutWeight){
      showDoctorBusyDialog(ctx);
    }
    else {
      Get.back();
    }
  }
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        willpopFunction(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: (){
              willpopFunction(context);
            },
          ),
          title: Text(
            'Edit Profile Info',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins',
                color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Container(
            color: AppColors.bgColorTab,
            child: CustomPaint(
              painter: BackgroundPainter(
                  primary: Colors.blue.withOpacity(0.8), secondary: Colors.blue),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 10.0),
                                PersonalProfileDetails(kisokAccountWithoutWeight: widget.kisokAccountWithoutWeight,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
