import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/abha/views/abha_account.dart';
import 'package:ihl/abha/views/abha_id_download.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:sizer/sizer.dart';

class AbhaMappedAccounts extends StatefulWidget {
  const AbhaMappedAccounts({Key key, @required this.screen}) : super(key: key);
  final String screen;

  @override
  State<AbhaMappedAccounts> createState() => _AbhaMappedAccountsState();
}

class _AbhaMappedAccountsState extends State<AbhaMappedAccounts> {
  String txnid = '';
  var mappedAddress = [];
  bool loader = false;
  String mobileNo = '';
  String requestId = '';
  String dropdownvalue = '';
  @override
  void initState() {
    getAllData();
    super.initState();
  }

  final box = GetStorage();
  void getAllData() {
    var response = box.read("AbhaMappedAccounts");
    print(response.toString() + " /");
    mappedAddress = response != null ? response['mappedPhrAddress'] : [];
    txnid = response['transactionId'];
    dropdownvalue = mappedAddress[0];
    setState(() {
      loader = true;
    });
    print(mappedAddress);
  }

  var items = ['item 1', 'item 2'];
  bool isLoading = false;
  authconfirmation() async {
    setState(() {
      isLoading = true;
    });
    abhaRegistraion = false;
    var response = await NetworkCallsAbha().confirmAuth(txnid, dropdownvalue);
    print(response);
    box.write('selectedAbhaId', dropdownvalue.toString());
    box.write('LoginToken', response['token']);
    if (widget.screen == 'beforeLogIn') {
      Navigator.of(context).pushNamed(Routes.Sdob);
      setState(() {
        isLoading = false;
      });
    } else {
      await NetworkCallsAbha().storeAbhaDetails();
      dynamic response = await NetworkCallsAbha().viewAbhadetails();
      print(response.isEmpty);
      if (response.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbhaAccountLogin(abhaTextField: "phonenumber")));
      } else {
        print(response);
        var healthid = response[0]['abha_address'];
        var abhaNumber = response[0]['abha_number'];
        String abhaCard = await NetworkCallsAbha().viewAbhaCard(healthid);
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbhaIdDownloadScreen(
                      abhaAddress: healthid,
                      abhaCard: abhaCard,
                      abhaNumber: abhaNumber,
                    )));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 5,
                child: LinearProgressIndicator(
                  value: 0.5, // percent filled
                  backgroundColor: Color(0xffDBEEFC),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
            color: Colors.black,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {},
              child: Text(AppTexts.next,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  )),
              style: TextButton.styleFrom(
                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                  textStyle: TextStyle(color: Color(0xFF19a9e5))),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 5.0,
              ),
              Center(
                  child: Text(
                'STEP 6/9',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              )),
              SizedBox(
                width: 100.w,
                height: 60.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SizedBox(
                    //   height: 5.0,
                    // ),
                    // Center(
                    //     child: Text(
                    //   'STEP 6/9',
                    //   style: TextStyle(
                    //     color: AppColors.primaryColor,
                    //     fontSize: 16.sp,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // )),

                    Container(
                      child: Text('Select your account to continue',
                          maxLines: 3,
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'Poppins',
                              color: Color.fromRGBO(74, 75, 77, 1),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 25.sp,
                    ),
                    loader
                        ? Container(
                            height: 60,
                            width: 70.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(),
                            ),
                            child: Center(
                              child: DropdownButton(
                                value: dropdownvalue.isNotEmpty ? dropdownvalue : null,
                                //  icon: const Icon(Icons.keyboard_arrow_down),
                                items: mappedAddress.map((dynamic item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: Color(0xff6d6e71),
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (dynamic newValue) {
                                  setState(() {
                                    dropdownvalue = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        : CircularProgressIndicator(),
                    SizedBox(
                      height: 30.sp,
                    ),
                    GestureDetector(
                      onTap: () {
                        authconfirmation();
                      },
                      child: Container(
                        height: 7.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                            color: Color(0xFF19a9e5), borderRadius: BorderRadius.circular(19.sp)),
                        child: !isLoading
                            ? Center(
                                child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                            : Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
