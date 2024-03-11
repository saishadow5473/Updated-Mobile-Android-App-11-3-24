import 'dart:convert';

import 'package:crisp/crisp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/askIhlControllers/askIhlControllers.dart';

import 'package:sizer/sizer.dart';

import '../../../../utils/SpUtil.dart';

class AskIHL extends StatefulWidget {
  const AskIHL({Key key}) : super(key: key);

  @override
  State<AskIHL> createState() => _AskIHLState();
}

class _AskIHLState extends State<AskIHL> {
  CrispMain crispMain;
  bool _isLoading = true;
  final askIhlControllers _askIhlControllers = Get.put(askIhlControllers());
  @override
  void initState() {
    setValue();
    super.initState();
  }

  setValue() async {
    crispMain = CrispMain(
      websiteId: 'cd2470a0-af57-46ef-9e05-8441dd73e827',
      locale: 'en',
    );
    try {
      var raw = jsonDecode(SpUtil.getString(LSKeys.userDetail));
      print(raw);
      print(raw.runtimeType);

      String name = raw['firstName'];
      String email = raw['email'];
      String phoneNumber = raw['mobileNumber'];

      if (name == '') {
        crispMain.register(
          user: CrispUser(
            email: "user@gmail.com",
            avatar: 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4',
            nickname: "IHL USER",
            phone: "000000000",
          ),
        );
      } else {
        String photo = 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4';
        crispMain.register(
          user: CrispUser(
            email: email,
            avatar: photo,
            nickname: name,
            phone: phoneNumber,
          ),
        );
        crispMain.userToken = email;
      }
    } catch (e) {
      crispMain.register(
        user: CrispUser(
          email: "user@gmail.com",
          avatar: 'https://avatars2.githubusercontent.com/u/16270189?s=200&v=4',
          nickname: "IHL USER",
          phone: "000000000",
        ),
      );
    }

    crispMain.setMessage("Hello");

    crispMain.setSessionData({
      "order_id": "11231",
      "app_version": "0.1.1",
    });
    setState(() {
      _isLoading = false;
    });

    _askIhlControllers.updateCurrentState(val: _isLoading);
  }

  bool aff = false;
  @override
  Widget build(BuildContext context) {
    if (!Tabss.featureSettings.askIhl) {
      return const Center(child: Text("No Ask IHL Available"));
    } else {
      return
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   toolbarOpacity: 0,
          //   toolbarHeight: 6.h,
          //   flexibleSpace: const CustomeAppBar(screen: ProgramLists.commonList),
          //   backgroundColor: Colors.white,
          //   elevation: aff ? 0 : 2,
          //   shadowColor: AppColors.unSelectedColor,
          // ),
          SingleChildScrollView(
        child: Column(
          children: [
            // const OfferedPrograms(
            //   screen: ProgramLists.commonList,
            //   screenTitle: "Social",
            // ),
            SizedBox(
              height: 70.h,
              child: ClipRRect(
                  child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child:
                    //  Obx(
                    //   () =>
                    Container(
                  child: _isLoading
                      //_askIhlControllers.dataLoaded.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : CrispView(
                          crispMain: crispMain,
                          clearCache: false,
                        ),
                ),
              )),
              // ),
            ),
            SizedBox(
              height: 7.h,
            )
          ],
        ),
      );
    }
  }
}
